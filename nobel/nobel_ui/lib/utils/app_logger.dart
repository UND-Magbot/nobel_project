import 'dart:io';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class AppLogger {
  // 싱글톤 인스턴스
  static final Logger _logger = Logger();

  // 인스턴스 반환 메서드
  static Logger get instance => _logger;
}

/// 파일 기반 데이터 로거 - PLC 데이터 추적 및 0값 감지용
class DataFileLogger {
  static final DataFileLogger _instance = DataFileLogger._internal();
  factory DataFileLogger() => _instance;
  DataFileLogger._internal();

  static const String _logDir = 'C:\\nobel\\logs';
  IOSink? _dataSink;
  IOSink? _zeroAlertSink;
  String _currentDate = '';

  /// 로그 디렉토리 및 파일 초기화
  void init() {
    Directory(_logDir).createSync(recursive: true);
    _rotateLogs();
  }

  /// 날짜가 바뀌면 로그 파일 교체
  void _rotateLogs() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_currentDate == today) return;

    _currentDate = today;

    _dataSink?.close();
    _zeroAlertSink?.close();

    final dataFile = File('$_logDir\\flutter_data_$today.log');
    _dataSink = dataFile.openWrite(mode: FileMode.append);

    final zeroFile = File('$_logDir\\flutter_zero_alert_$today.log');
    _zeroAlertSink = zeroFile.openWrite(mode: FileMode.append);
  }

  String _timestamp() {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
  }

  /// 소켓에서 수신한 원본 데이터 로깅
  void logReceived(String name, String date, List<dynamic> values, {Map<String, dynamic>? limits}) {
    try {
      _rotateLogs();
      final msg = '[${_timestamp()}] RECV name=$name, date=$date, values=$values';
      _dataSink?.writeln(msg);
      _dataSink?.flush();
    } catch (_) {}
  }

  /// 데이터 저장(writeValue) 후 로깅
  void logWriteValue(String name, String date, String stage, List<dynamic> values) {
    _rotateLogs();
    final msg = '[${_timestamp()}] WRITE name=$name, date=$date, stage=$stage, values=$values';
    _dataSink?.writeln(msg);
    _dataSink?.flush();
  }

  /// 소켓 연결 상태 로깅
  void logConnection(String event, {String? detail}) {
    _rotateLogs();
    final msg = '[${_timestamp()}] SOCKET $event${detail != null ? " - $detail" : ""}';
    _dataSink?.writeln(msg);
    _dataSink?.flush();
  }

  /// 에러 로깅
  void logError(String context, dynamic error) {
    _rotateLogs();
    final msg = '[${_timestamp()}] ERROR [$context] $error';
    _dataSink?.writeln(msg);
    _dataSink?.flush();
  }

  /// 일반 정보 로깅
  void logInfo(String message) {
    _rotateLogs();
    final msg = '[${_timestamp()}] INFO $message';
    _dataSink?.writeln(msg);
    _dataSink?.flush();
  }

  void dispose() {
    _dataSink?.close();
    _zeroAlertSink?.close();
  }
}
