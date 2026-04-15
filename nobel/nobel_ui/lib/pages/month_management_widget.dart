import 'dart:io';

import 'package:flutter/services.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import 'package:test_novel_i_r_i_s3/utils/functions.dart';
import 'package:test_novel_i_r_i_s3/widgets/autoSizedText.dart';
import 'dart:ui';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'month_management_model.dart';

class MonthManagementPage extends StatefulWidget {
  // 1️⃣ 생성자에 필수 매개변수 추가
  const MonthManagementPage({
    super.key,
    required this.name,
    required this.checkNum,
    required this.month,
    required this.jsonMap,
  });

  // 2️⃣ 매개변수 선언
  final String name;
  final String checkNum;
  final String month;
  final dynamic jsonMap;

  @override
  State<MonthManagementPage> createState() => _MonthManagementPage();
}

class _MonthManagementPage extends State<MonthManagementPage>
    with TickerProviderStateMixin {
  late MonthManagementModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int tabIndex = 0;
  final bool _isConnected = false;
  List<List> values = [];

  double allAverage = 0;
  double diffAverave = 0;
  static const double baseWidth = 1920.0;

  static var logger = AppLogger.instance;

  double screenWidth = 0;
  double scaleFactor = 1;
  Map<String, String> inputDatas1 = {
    'model': 'model',
    '품명': 'test',
    'Code No.': 'codeno',
    '관리항목': 'test',
    'SPEC': '2.0',
    '공차상한': '2.1',
    '공차하한': '1.9',
    'preCL': '2.123',
    'preUCL': '2.012',
    'preLCL': '1.999',
    'CL': '2.001',
    'UCL': '2.132',
  };
  Map<String, String> inputDatas = {
    'model': '',
    '품명': '',
    'Code No.': '',
    '관리항목': '',
    'SPEC': '',
    '공차상한': '',
    '공차하한': '',
    'preCL': '',
    'preUCL': '',
    'preLCL': '',
    'CL': '',
    'UCL': '',
  };

  String userInput = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MonthManagementModel());
    // name = widget.name;
    List dateList;
    double average;
    double value;
    List<double> subList;
    double maxVal;
    double minVal;
    double difference;

    List<double> allValues = [];
    List<double> xbarValues = [];
    List<double> rValues = [];

    FFAppState().initOutputDatas();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });
    if (widget.jsonMap.length == 0) {
      return;
    }

    for (int i = 0; i < widget.jsonMap['data_list'].length; i++) {
      values.add([]);
      dateList = widget.jsonMap['data_list'].keys.toList();
      average = 0.0 * scaleFactor;
      values[i].add(dateList[i]);
      List<dynamic>? dataList =
          widget.jsonMap['data_list'][dateList[i]][widget.checkNum];

      if (dataList != null) {
        for (int j = 0; j < dataList.length; j++) {
          if (dataList[j] is int) {
            value = dataList[j].toDouble();
          } else {
            value = dataList[j];
          }
          values[i].add(value);
          average += value;
          if (value != null) {
            allValues.add(value); // ✅ 여기서 누적 수집
          }
        }
      }
      average /= 3;
      allAverage += average;
      values[i].add(average);

      subList = values[i].sublist(1, values[i].length).cast<double>();
      maxVal = subList.reduce((a, b) => a > b ? a : b);
      minVal = subList.reduce((a, b) => a < b ? a : b);
      difference = maxVal - minVal;
      diffAverave += difference;

      xbarValues.add(average);
      rValues.add(difference);

      values[i].add(difference);
    }

    allAverage /= widget.jsonMap['data_list'].length;
    diffAverave /= widget.jsonMap['data_list'].length;

    if (xbarValues.isNotEmpty) {
      double min = xbarValues.reduce((a, b) => a < b ? a : b);
      double max = xbarValues.reduce((a, b) => a > b ? a : b);
      double range = (max - min) * 0.1;
      if (range < 0.1) range = 0.1;

      double yMin = min - range;
      if (yMin < 0) yMin = 0;

      inputDatas['xbar_yMin'] = yMin.toStringAsFixed(2);
      inputDatas['xbar_yMax'] = (max + range).toStringAsFixed(2);
    }

    if (rValues.isNotEmpty) {
      double min = rValues.reduce((a, b) => a < b ? a : b);
      double max = rValues.reduce((a, b) => a > b ? a : b);
      double range = (max - min) * 0.2;
      if (range < 0.1) range = 0.1;

      double yMin = min - range;
      if (yMin < 0) yMin = 0;

      inputDatas['r_yMin'] = yMin.toStringAsFixed(2);
      inputDatas['r_yMax'] = (max + range).toStringAsFixed(2);
    }

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FFAppState().setIsLoading(false);
    context.watch<FFAppState>();

    // IndexedContainer.initState();

    return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: LayoutBuilder(builder: (context, constraints) {
          screenWidth = constraints.maxWidth;
          scaleFactor = screenWidth / baseWidth;

          return SafeArea(
              top: true,
              child: Stack(children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0 * scaleFactor,
                                16.0 * scaleFactor,
                                16.0 * scaleFactor,
                                16.0 * scaleFactor),
                            child: InkWell(
                              onTap: () {
                                context.pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF1E3A5F)),
                                    SizedBox(width: 4),
                                    Text('이전', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                4.0 * scaleFactor,
                                4.0 * scaleFactor,
                                4.0 * scaleFactor,
                                4.0 * scaleFactor),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8.0 * scaleFactor),
                              child: Image.asset(
                                'assets/images/33wa1_.jpg',
                                width: MediaQuery.sizeOf(context).width * 0.23,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                32.0 * scaleFactor,
                                0.0 * scaleFactor,
                                0.0 * scaleFactor,
                                0.0 * scaleFactor),
                            child: Container(
                              decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    64.0 * scaleFactor,
                                    4.0 * scaleFactor,
                                    64.0 * scaleFactor,
                                    4.0 * scaleFactor),
                                child: Text(
                                  '${FFAppState().getCurrentyear()}년 ${FFAppState().getCurrentMonth()}월 Xbar-R 관리도',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            scaleFactor * 50.0 * scaleFactor,
                                        color: Colors.white,
                                        letterSpacing: 0.0 * scaleFactor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                64.0 * scaleFactor,
                                4.0 * scaleFactor,
                                1.0 * scaleFactor,
                                4.0 * scaleFactor),
                            child: Text(FFAppState().CurrentName,
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      fontSize:
                                          scaleFactor * 40.0 * scaleFactor,
                                      color: Colors.black,
                                      letterSpacing: 0.0 * scaleFactor,
                                      fontWeight: FontWeight.w600,
                                    )),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            32.0 * scaleFactor,
                            4.0 * scaleFactor,
                            16.0 * scaleFactor,
                            4.0 * scaleFactor),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child:
                                          _buildHeaderCell('차종', height: 70)),
                                  Expanded(
                                      flex: 2,
                                      child: _buildEmptyCell(name: 'model')),
                                  Expanded(
                                      flex: 1,
                                      child:
                                          _buildHeaderCell('품명', height: 70)),
                                  Expanded(
                                      flex: 2,
                                      child: _buildEmptyCell(name: '품명')),
                                  Expanded(
                                      flex: 1,
                                      child:
                                          _buildHeaderCell('품번', height: 70)),
                                  Expanded(
                                      flex: 2,
                                      child: _buildEmptyCell(name: 'Code No.')),
                                  Expanded(
                                      flex: 1,
                                      child:
                                          _buildHeaderCell('SPEC', height: 70)),
                                  Expanded(
                                      flex: 2,
                                      child: _buildEmptyCell(
                                          name: 'SPEC', type: 'double')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.all(8.0 * scaleFactor),
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: Map.fromIterables(
                            List.generate(
                                27, (index) => index), // 0~26 (헤더 열 포함)
                            List.generate(
                                27,
                                (index) =>
                                    const FlexColumnWidth(1)), // 모든 열 동일한 비율
                          ),

                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            // 헤더 행 (첫 번째 열 포함)
                            TableRow(
                              children: [
                                _buildCell(text: "군번호", isHeader: true),
                                for (var i = 0; i < 25; i++)
                                  _buildCell(
                                      text: '${i + 1}',
                                      isHeader: true), // 'A' ~ 'Z'
                                _buildCell(text: "No", isTransparent: true),
                              ],
                            ),
                            // 데이터 행 (높이 조절 + 마지막 열 일부 투명 처리)
                            TableRow(
                              children: [
                                // 첫 번째 열 (헤더 열)
                                _buildCell(text: "일자", isHeader: true),
                                // 나머지 열
                                for (var j = 0; j < 26; j++)
                                  j < widget.jsonMap['data_list'].keys.length
                                      ? _buildCell(
                                          text:
                                              "${values[j][0].substring(5).replaceFirst('-', '/')}",
                                          isTransparent:
                                              (j == 25), // 마지막 열 위 3칸 투명
                                        )
                                      : _buildCell(
                                          text: "",
                                          isTransparent:
                                              (j == 25), // 마지막 열 위 3칸 투명
                                        )
                              ],
                            ),
                            for (var i = 2; i <= 4; i++)
                              TableRow(
                                children: [
                                  // 첫 번째 열 (헤더 열)
                                  _buildCell(text: "X${i - 1}", isHeader: true),
                                  // 나머지 열

                                  for (var j = 0;
                                      j < widget.jsonMap['data_list'].length;
                                      j++)
                                    i < 7
                                        ? _buildCell(
                                            text: i - 1 < values[j].length - 2
                                                ? "${values[j][i - 1]}"
                                                : "",
                                            isTransparent: (j == 25 &&
                                                i <= 6), // 마지막 열 위 3칸 투명
                                          )
                                        : _buildCell(
                                            text: "",
                                            isTransparent: (j == 25 &&
                                                i <= 6), // 마지막 열 위 3칸 투명
                                          ),
                                  for (var j =
                                          widget.jsonMap['data_list'].length;
                                      j < 26;
                                      j++)
                                    _buildCell(
                                        text: "",
                                        isTransparent: (j == 25 && i <= 6))
                                ],
                              ),
                            TableRow(
                              children: [
                                // 첫 번째 열 (헤더 열)
                                _buildCell(text: "평균", isHeader: true),
                                // 나머지 열
                                for (var j = 0;
                                    j < widget.jsonMap['data_list'].length;
                                    j++)
                                  _buildCell(
                                      text:
                                          "${values[j][values[j].length - 2].toStringAsFixed(4)}"),
                                for (var j = widget.jsonMap['data_list'].length;
                                    j < 26;
                                    j++)
                                  _buildCell(
                                    text: j == 25
                                        ? allAverage.toStringAsFixed(4)
                                        : "",
                                  )
                              ],
                            ),
                            TableRow(
                              children: [
                                // 첫 번째 열 (헤더 열)
                                _buildCell(text: "범위", isHeader: true),
                                // 나머지 열
                                for (var j = 0;
                                    j < widget.jsonMap['data_list'].length;
                                    j++)
                                  _buildCell(
                                      text:
                                          "${values[j][values[j].length - 1].toStringAsFixed(4)}"),
                                for (var j = widget.jsonMap['data_list'].length;
                                    j < 26;
                                    j++)
                                  _buildCell(
                                    text: j == 25
                                        ? diffAverave.toStringAsFixed(4)
                                        : "",
                                  )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            32.0 * scaleFactor,
                            4.0 * scaleFactor,
                            4.0 * scaleFactor,
                            4.0 * scaleFactor),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: Map.fromIterables(
                                        List.generate(2,
                                            (index) => index), // 0~26 (헤더 열 포함)
                                        List.generate(
                                            2,
                                            (index) => const FlexColumnWidth(
                                                1)), // 모든 열 동일한 비율
                                      ),
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        // 헤더 행 (첫 번째 열 포함)
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "통계치", isHeader: true),
                                            _buildCell(isTransparent: true),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "X_bar=", isHeader: true),
                                            _buildCell(name: 'X_bar='),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "R_bar=", isHeader: true),
                                            _buildCell(name: 'R_bar='),
                                          ],
                                        ),

                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 4.0 * scaleFactor, 0, 0),
                                              child: _buildCell(
                                                  text: "Xbar UCL=",
                                                  isHeader: true),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 4.0 * scaleFactor, 0, 0),
                                              child:
                                                  _buildCell(name: 'Xbar UCL='),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "Xbar CL=",
                                                isHeader: true),
                                            _buildCell(name: 'Xbar CL='),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "Xbar LCL=",
                                                isHeader: true),
                                            _buildCell(name: 'Xbar LCL='),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 4.0 * scaleFactor, 0, 0),
                                              child: _buildCell(
                                                  text: "R UCL=",
                                                  isHeader: true),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 4.0 * scaleFactor, 0, 0),
                                              child: _buildCell(name: 'R UCL='),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "R CL=", isHeader: true),
                                            _buildCell(name: 'R CL='),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "sigma=", isHeader: true),
                                            _buildCell(name: 'sigma='),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 4.0 * scaleFactor, 0, 0),
                                              child: _buildCell(
                                                  text: "Cp=", isHeader: true),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 4.0 * scaleFactor, 0, 0),
                                              child: _buildCell(name: 'Cp='),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            _buildCell(
                                                text: "Cpk=", isHeader: true),
                                            _buildCell(name: 'Cpk='),
                                          ],
                                        ),
                                        // TableRow(
                                        //   children: [
                                        //     Padding(
                                        //       padding: EdgeInsets.fromLTRB(
                                        //           0, 4.0 * scaleFactor, 0, 0),
                                        //       child: _buildCell(
                                        //           text: "예상불량(ppm)",
                                        //           isHeader: true,
                                        //           fontSize: 14),
                                        //     ),
                                        //     Padding(
                                        //       padding: EdgeInsets.fromLTRB(
                                        //           0, 4.0 * scaleFactor, 0, 0),
                                        //       child:
                                        //           _buildCell(name: '예상불량(ppm)'),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.all(16.0 * scaleFactor),
                                        child: InkWell(
                                          onTap: () {
                                            widget.jsonMap['inputData'] =
                                                inputDatas;
                                            widget.jsonMap['type'] =
                                                '${FFAppState().CurrentName}/${widget.checkNum}';
                                            widget.jsonMap['month'] =
                                                FFAppState().getCurrentMonth();
                                            FFAppState().setIsLoading(true);
                                            sendJsonData(
                                                FFAppState().CurrentName,
                                                jsonMap: widget.jsonMap);
                                          },
                                          // child: Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: double.infinity,
                                            height: 100 * scaleFactor,
                                            color: const Color(0xFF1E3A5F),
                                            child: Text(
                                              '엑셀/차트 생성',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20 * scaleFactor),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          // )
                                        ))
                                  ],
                                )),
                            // Expanded(
                            //     flex: 2,
                            //     child: Column(
                            //       children: [
                            //         if (FFAppState().outputDatas['X_2bar='] !=
                            //             '')
                            //           // ChartImage('C:\\nobel\\1.png'),
                            //         if (FFAppState().outputDatas['X_2bar='] !=
                            //             '')
                            //           // ChartImage('C:\\nobel\\4.png'),
                            //       ],
                            //     )),
                            Expanded(
                              flex: 5,
                              child: Builder(
                                builder: (context) {
                                  imageCache.clear(); // ✅ 모든 캐시 지우기
                                  imageCache
                                      .clearLiveImages(); // ✅ 메모리 상 이미지도 지우기

                                  return Column(
                                    children: [
                                      if (FFAppState().outputDatas['X_bar='] !=
                                          '')
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                  right:
                                                      8.0), // ✅ 텍스트 오른쪽 간격 최소화
                                              child: Text(
                                                'X-Bar 관리도',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Flexible(
                                              child: ChartImage(
                                                  'C:\\nobel\\image\\1.png'),
                                            ),
                                          ],
                                        ),
                                      if (FFAppState().outputDatas['X_bar='] !=
                                          '')
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 85.0, right: 8.0),
                                              child: Text(
                                                'R 관리도',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Flexible(
                                              child: ChartImage(
                                                  'C:\\nobel\\image\\2.png'),
                                            ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                ),
                if (FFAppState().isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5), // 배경을 반투명하게 설정
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(), // 로딩 스피너
                          SizedBox(height: 16), // 간격 조정
                          Text(
                            "엑셀 파일 생성중입니다...",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ]));
        }));
  }

  Future<String?> _showInputDialog(String title, String type) async {
    TextEditingController controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: type == 'double'
                ? const TextInputType.numberWithOptions(decimal: true)
                : null, // 숫자 + 소수점 키보드
            inputFormatters: type == 'double'
                ? [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,5}$')),
                  ]
                : null,
            decoration: const InputDecoration(hintText: "값을 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop(null); // ❌ 취소 시 null 반환
              },
            ),
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.of(context).pop(controller.text); // ✅ 입력값 반환
              },
            ),
          ],
        );
      },
    );
  }

  Widget ChartImage(String path) {
    File imageFile = File(path);
    return Padding(
      padding: EdgeInsets.all(4.0 * scaleFactor),
      child: SizedBox(
        height: 280 * scaleFactor,
        child: imageFile.existsSync()
            ? Image.file(
                imageFile,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _chartPlaceholder(),
              )
            : _chartPlaceholder(),
      ),
    );
  }

  Widget _chartPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 48 * scaleFactor, color: const Color(0xFF94A3B8)),
            SizedBox(height: 8 * scaleFactor),
            Text(
              '차트 미생성',
              style: TextStyle(
                fontSize: 16 * scaleFactor,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4 * scaleFactor),
            Text(
              '[엑셀/차트 생성] 버튼을 눌러주세요',
              style: TextStyle(
                fontSize: 12 * scaleFactor,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 개별 헤더 셀
  Widget _buildHeaderCell(String text,
      {double fontSize = 20, double height = 35, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: height * scaleFactor,
        margin: EdgeInsets.all(1.0 * scaleFactor),
        color: const Color(0xFF1E3A5F),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize * scaleFactor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 빈 입력칸 (일반 셀)
  Widget _buildEmptyCell(
      {int flex = 1,
      String name = '',
      String type = 'string',
      double height = 70}) {
    String? result;
    return Expanded(
        flex: flex,
        child: InkWell(
            onTap: () async => {
                  if (name != '')
                    {
                      result = await _showInputDialog(name, type),
                      if (result != null)
                        {
                          setState(() {
                            // ✅ setState로 UI 갱신
                            inputDatas[name] = result!;
                          })
                        }
                    }
                },
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)), // 일반 셀 테두리 유지
                ),
                alignment: Alignment.center,
                height: height * scaleFactor,
                child: AutoSizedText(
                    text: inputDatas[name]!, scaleFactor: scaleFactor))));
  }

  Widget _buildCell(
      {String text = '',
      String name = '',
      double fontSize = 20,
      double height = 30,
      bool isHeader = false,
      bool isTransparent = false}) {
    return Container(
      height: height * scaleFactor,
      alignment: Alignment.center,
      decoration: isTransparent
          ? null // 테두리 제거 (투명한 셀)
          : BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)), // 일반 셀 테두리 유지
              color: isHeader ? const Color(0xFFF1F5F9) : Colors.white, // 헤더 배경색 설정
            ),
      child: Text(
        (name == '')
            ? text.toString()
            : (name != '예상불량(ppm)'
                ? (FFAppState().outputDatas[name] is double
                    ? FFAppState().outputDatas[name].toStringAsFixed(3)
                    : FFAppState().outputDatas[name].toString())
                : (FFAppState().outputDatas[name] is double
                    ? FFAppState().outputDatas[name].toStringAsFixed(0)
                    : FFAppState().outputDatas[name].toString())),
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isTransparent
                ? Colors.transparent
                : Colors.black, // 투명한 셀의 텍스트도 투명하게
            fontSize: fontSize * scaleFactor),
      ),
    );
  }
}
