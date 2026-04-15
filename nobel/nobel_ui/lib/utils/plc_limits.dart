import 'package:test_novel_i_r_i_s3/flutter_flow/flutter_flow_util.dart';
import '../data/database_helper.dart';

Future<void> savePlcLimitsToCustomPath(
    Map<String, Map<String, Map<String, double>>> limits) async {
  await DatabaseHelper().savePlcLimits(limits);
  print("✅ PLC 기준값 저장 완료 (SQLite)");
}

Future<void> loadPlcLimitsFromCustomPath() async {
  FFAppState().plcLimits = await DatabaseHelper().loadPlcLimits();
  print("✅ PLC 기준값 불러오기 완료 (SQLite)");
}
