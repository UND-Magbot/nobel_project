// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';

import '../utils/app_logger.dart';
import '../utils/const.dart';
import '../utils/plc_limits.dart';

class Measurements {
  /**
   * 전체 데이터
   * 소재 이름 - 날짜 : 측정값 데이터(소재명, 데이터)
   * auther :     John
   * date :       2024-12-27
   */
  static dynamic data = Map.from(Constants.JSON_DATA_MAP);
  static List dateList = [];

  static var logger = AppLogger.instance; // 로그 출력용

  String productNum = ''; // 품번
  late String date; // 검사 일자
  late String name; // 소재 이름(ex: MS-015)
  late List<double> referenceValues; // 측정 기준값
  late List<double> errors; // 오차
  List<double> manageErrors = []; // 관리 오차
  late List<String> checkList; // 검사 항목 번호
  bool isComplete = false;
  Map<String, Map<String, double>> plcLimits = {}; // checkNum -> {min, max}
  // 사용 미정 데이터
  // String productNum = '';
  String worker = '';
  String admin = '';
  String model = '';
  String product = '';
  int numOfNondefective = 0;

  /**
   * 처음 소재에 대한 측정값을 파이썬 서버에서 받으면
   * 소재 클래스가 생성되고 전체 데이터 셋의 날짜에 
   * 소재 이름에 저장된다. Map<이름, Map<날짜, Measurements>>
   * 
   * ex) 
   * {
   *    'MS-010' : {
   *        '2024-12-27' : data,
   *        '2024-12-28' : data,...
   *    },
   *    'MS-011' : {
   *        '2024-12-27' : data,
   *        '2024-12-28' : data,...
   *    },...       
   * }
   * 
   * param 1 :  List Constants 클래스의 해당 소재 이름에
   *            해당하는 상수값 리스트
   * param 2 :  파이썬 서버로부터 전달받은 소재 측정값
   * auther :     John
   * date :       2024-12-27
   */
  Measurements.fromServer(var jsonData) {
    this.name = jsonData['name'];
    this.date = jsonData['date'];
    List values = jsonData['values'];

    Map<String, dynamic> limitsAll = jsonData['limits'] ?? {};
    Map<String, dynamic>? limitsForThisName = limitsAll[name];
    Map<String, Map<String, double>> plcLimits = {};

    if (limitsForThisName != null) {
      plcLimits = limitsForThisName.map((checkNum, limitMap) => MapEntry(
            checkNum,
            {
              "min": (limitMap['min'] as num).toDouble(),
              "max": (limitMap['max'] as num).toDouble(),
            },
          ));

      // 🔽 저장
      FFAppState().updatePlcLimits(name, plcLimits);
      savePlcLimitsToCustomPath(FFAppState().plcLimits);
    }

    measurements = {};
    List params = Constants.getDataParams(jsonData['name']);

    checkList = params[2];
    referenceValues = List<double>.from(params[1].map((e) => e.toDouble()));

    if (checkList.length == jsonData['values'].length) {
      name = params[0];
      errors = List<double>.from(params[3].map((e) => (e as num).toDouble()));

      if (name == 'MS-014' || name == 'MS-015') {
        manageErrors = List<double>.from(params[4].map((e) => e.toDouble()));
      }

      List values = jsonData['values'].map((e) => e.toDouble()).toList();
      date = jsonData['date'];
      try {
        productNum = jsonData['productNum'];
      } catch (e) {
        logger.e('품번 없음.');
      }

      writeValue(values);

      data[name]![date] = this;
    } else {
      // 길이 불일치 시 호출자가 알 수 있도록 예외 throw
      // (이전: 로그만 남기고 빈 객체 반환 → 빈 데이터가 SQLite에 저장되는 손상 유발)
      final msg =
          '검사 항목 수(${checkList.length})와 수신 데이터 수(${jsonData['values']?.length})가 일치하지 않음. name=${jsonData['name']}';
      logger.e(msg);
      throw StateError(msg);
    }
  }

  Measurements(
      {required this.date,
      required this.name,
      required this.measurements,
      this.productNum = ''}) {
    List params = Constants.getDataParams(name);

    checkList = params[2];
    referenceValues =
        (params[1] as List).map((e) => (e as num).toDouble()).toList();
    errors = (params[3] as List).map((e) => (e as num).toDouble()).toList();

    if (name == 'MS-014' || name == 'MS-015') {
      manageErrors =
          (params[4] as List).map((e) => (e as num).toDouble()).toList();
    }
    data[name]![date] = this;
  }

  factory Measurements.fromJson(Map<String, dynamic> json) {
    final parsedMeasurements =
        (json['measurements'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List).map((e) => (e as num).toDouble()).toList(),
      ),
    );

    if (json.containsKey('product num')) {
      return Measurements(
        date: json['date'],
        name: json['name'],
        measurements: parsedMeasurements,
        productNum: json['product num'],
      );
    } else {
      return Measurements(
        date: json['date'],
        name: json['name'],
        measurements: parsedMeasurements,
      );
    }
  }

  Map<String, dynamic> toJson() {
  final copiedMeasurements = <String, List<double>>{};

  for (String checkNum in measurements.keys) {
    final avg = averageByCheckNum(checkNum);
    final xbar = xbarRByCheckNum(checkNum);

    final original = measurements[checkNum]!;

    // ✅ 원본은 무조건 앞의 3개까지만
    final pureOriginal = original.length > 3
        ? original.sublist(0, 3)
        : List<double>.from(original);

    // 항상 [측정값..., avg, xbar]
    List<double> newList = [...pureOriginal, avg, xbar];

    copiedMeasurements[checkNum] = newList;
  }

  return {
    'date': date,
    'product num': productNum,
    'name': name,
    'measurements': copiedMeasurements,
    'error count': getErrorCount(),
    'worker': worker, // ✅ 작업자 이름 포함
    'admin': admin,   // ✅ 관리자 이름 포함
    'model': model,
    'product': product,
  };
}


  /**
   * 모든 측정값 데이터
   * key :        검사 항목
   * value :      List[0~2] - 초 중 종 측정값
   * auther :     John
   * date :       2024-12-26
   */
  late Map<String, List<double>> measurements;

  /**
   * 초, 중, 종 검사 중 에러가 있는지 확인
   * 측정값 - 기준값 > 오차값 : 불량
   * param 1 :    int 검사 항목 번호(checkNum)
   * param 2 :    int 초(0), 중(1), 종(2) 중 하나(index)
   * return :     true(에러가 있을 시)
   *              false(에러가 없을 시) 
   * auther :     John
   * date :       2024-12-26
   */
  bool? isErrorByCheckItemNumber(String checkNum, int index) {
    final values = measurements[checkNum];
    if (values != null && values.length > index) {
      int i = checkList.indexOf(checkNum);
      double diff = values[index] - referenceValues[i];

      if (name != 'MS-014' && name != 'MS-015') {
        return diff > errors[i * 2] || diff < errors[i * 2 + 1];
      } else {
        return diff > errors[i * 2] || diff < errors[i * 2 + 1];
      }
    }
    return null;
  }

  /**
   * 오차 범위를 벗어나는 측정값의 index와 
   * 전체 오차가 발생한 값의 갯수,
   * 오차가 발생한 소재의 갯수를 반환
   * return :     List<[index, checkNum], ..., [numOfValueError, numItemError]>
   * auther :     John
   * date :       2024-12-26
   */
  List<dynamic> getErrorData() {
    List<dynamic> result = [];
    int numOfValueError = 0;
    int numItemError = 0;

    int valueLength = measurements.values.firstOrNull?.length ?? 0;

    for (int index = 0; index < valueLength; index++) {
      bool isError = false;

      for (var checkNum in measurements.keys) {
        if (isErrorByCheckItemNumber(checkNum, index) == true) {
          numOfValueError += 1;
          result.add([index, checkNum]);
          isError = true;
        }
      }

      if (isError) {
        numItemError += 1;
      }
    }

    result.add([numOfValueError, numItemError]);
    return result;
  }

  /**
   * 오차가 발생한 소재의 갯수를 반환
   * return :     int 불량 수량
   * auther :     John
   * date :       2024-12-26
   */
  int getErrorCount() {
    int numItemError = 0;
    int valueLength = measurements.values.firstOrNull?.length ?? 0;

    for (int index = 0; index < valueLength; index++) {
      for (var checkNum in measurements.keys) {
        if (isErrorByCheckItemNumber(checkNum, index) == true) {
          numItemError += 1;
          break;
        }
      }
    }
    return numItemError;
  }

  String CheckError() {
    String numItemError = 'OK';
    int valueLength = measurements.values.firstOrNull?.length ?? 0;

    for (int index = 0; index < valueLength; index++) {
      for (var checkNum in measurements.keys) {
        if (isErrorByCheckItemNumber(checkNum, index) == true) {
          numItemError = "NG";
          break;
        }
      }
    }
    return numItemError;
  }

  /**
   * 특정 검사항목의 초, 중, 종 측정값 평균 구하기
   * param :      int 검사 항목 index 
   * return :     double 해당 검사항목의 초, 중, 종 측정값의 평균값
   * auther :     John
   * date :       2024-12-26
   */
  double averageByCheckNum(String checkNum) {
    final valueList = measurements[checkNum];
    if (valueList == null || valueList.isEmpty) return 0;

    double result = valueList.reduce((a, b) => a + b) / valueList.length;
    return ((result * 10000).roundToDouble()) / 10000;
  }

  double xbarRByCheckNum(String checkNum) {
    final valueList = measurements[checkNum];
    if (valueList == null || valueList.isEmpty) return 0;

    // 값이 2개 이상 있을 때만 오차(R) 계산 가능
    if (valueList.length >= 2) {
      final maxVal = valueList.reduce((a, b) => a > b ? a : b);
      final minVal = valueList.reduce((a, b) => a < b ? a : b);

      final range = maxVal - minVal; // 오차(R) = 최대 - 최소
      return ((range * 10000).roundToDouble()) / 10000; // 소수점 4자리
    }

    // 값이 1개만 있으면 오차는 0
    return 0;
  }

  /**
   * 모든 검사 항목의 초, 중, 종 측정값의 평균 구하기
   * return :     List<double> 각 검사 항목의 초, 중, 종 평균값 리스트
   * auther :     John
   * date :       2024-12-26
   */
  List<double> averageAllValues() {
    List<double> result = [];

    for (String checkNum in measurements.keys) {
      result.add(averageByCheckNum(checkNum));
    }

    return result;
  }

  // UI에서 값을 표시하기 위한 함수

  String getValue(String checkNum, int index) {
    final values = measurements[checkNum];
    if (values != null && values.length > index) {
      return values[index].toString();
    }
    return '';
  }

  /**
   * 파이썬 서버로부터 받은 초, 중, 종 측정값들을
   * 소재 데이터에 저장
   * param 1 :    List 파이썬 서버로부터 받은 json 데이터의
   *              측정값 리스트
   * return :     true(측정값 저장 성공)
   *              false(오류 검사 실패 시) 
   * auther :     John
   * date :       2024-12-26
   */
  bool writeValue(List values) {
    if (checkList.length != values.length) {
      logger.e('검사 항목 수와 실제 측정값의 수가 일치하지 않음.');
      return false;
    }

    int index = 0;
    for (String checkNum in checkList) {
      measurements[checkNum] ??= []; // null이면 빈 리스트로 초기화

      if (measurements[checkNum]!.length < 3) {
        measurements[checkNum]!.add(values[index++]);
      } else {
        logger.e('이미 초, 중, 종 모든 측정값이 저장됨.');
        return false;
      }
    }

    return true;
  }

  /// 오늘 데이터 전체 삭제 (초/중/종 모두)
  void removeAllValues() {
    for (String checkNum in checkList) {
      measurements[checkNum]?.clear();
    }
  }

  /// 마지막 측정값(초/중/종 중 가장 최근) 삭제
  /// return: 삭제된 단계 이름 ('초'/'중'/'종'), 삭제할 게 없으면 null
  String? removeLastValue() {
    if (measurements.isEmpty) return null;

    // 현재 저장된 측정값 개수 확인 (모든 checkNum이 동일한 길이)
    int currentLength = measurements.values.first.length;
    if (currentLength == 0) return null;

    // 각 checkNum에서 마지막 값 제거
    for (String checkNum in checkList) {
      if (measurements[checkNum] != null && measurements[checkNum]!.isNotEmpty) {
        measurements[checkNum]!.removeLast();
      }
    }

    String stage = currentLength == 1 ? '초' : (currentLength == 2 ? '중' : '종');
    return stage;
  }

  //TODO
  bool writeValueByKeyboard(String checkNum, int index) {
    return false;
  }

  /**
   * 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
   * 특정 품목의 자주검사 일일 검사 데이터를 Json 형식의 데이터로 변환
   * return :     json 현재 데이터의 json 변환 데이터
   * auther :     John
   * date :       2024-12-27
   */
  dynamic toJsonForExcel() {
    Map jsonDataMap = {
      'error_num': getErrorCount(),
      'values': Map.from(measurements),
      'error_data': getErrorData(),
    };

    // 각 검사항목 마지막에 평균값 저장
    for (String checkNum in measurements.keys) {
      jsonDataMap['values'][checkNum]!.add(averageByCheckNum(checkNum));
    }

    return jsonDataMap;
  }

  dynamic toJsonForSendToServer() {
    Map jsonDataMap = {};
  }
}
