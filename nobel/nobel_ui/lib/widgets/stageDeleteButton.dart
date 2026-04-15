import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';
import '../data/nobel_data.dart';
import '../data/database_helper.dart';
import '../utils/const.dart';

class StageDeleteButton extends StatelessWidget {
  const StageDeleteButton({super.key, required this.nameIndex});

  final int nameIndex;

  Future<void> _saveData(Measurements m) async {
    await DatabaseHelper().saveMeasurements(m);
  }

  @override
  Widget build(BuildContext context) {
    String name = Constants.names[nameIndex];
    String currentDate = FFAppState().CurrentDate;

    int currentLength = 0;
    if (Measurements.data[name]!.containsKey(currentDate)) {
      Measurements data = Measurements.data[name]![currentDate]!;
      if (data.measurements.values.isNotEmpty) {
        currentLength = data.measurements.values.first.length;
      }
    }

    if (currentLength == 0) return const SizedBox.shrink();

    String stageName = currentLength == 1 ? '초' : (currentLength == 2 ? '중' : '종');

    // 테이블 컬럼 폭과 동일하게 맞춤
    // NO(0.05) + 초(0.07) + 중(0.07) + 종(0.07) + 평균(0.07) + R(0.07) = 0.40
    double colW = MediaQuery.sizeOf(context).width * 0.07;
    double noW = MediaQuery.sizeOf(context).width * 0.06;

    // 마지막 단계 컬럼까지의 오프셋 계산
    // currentLength=1(초): NO + 초의 중앙 → 왼쪽 패딩 = NO
    // currentLength=2(중): NO + 초 + 중의 중앙 → 왼쪽 패딩 = NO + 초
    // currentLength=3(종): NO + 초 + 중 + 종의 중앙 → 왼쪽 패딩 = NO + 초 + 중
    double leftOffset = noW + (currentLength - 1) * colW;
    // 오른쪽 남은 공간
    double rightOffset = (3 - currentLength) * colW + colW * 2; // 남은 컬럼 + 평균 + R

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: leftOffset),
          SizedBox(
            width: colW,
            child: Center(child: _buildDeleteChip(context, name, currentDate, stageName)),
          ),
          SizedBox(width: rightOffset),
        ],
      ),
    );
  }

  Widget _buildDeleteChip(BuildContext context, String name, String currentDate, String stageName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                '[$stageName] 삭제',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Text(
                '$name의 [$stageName] 측정값을 삭제하시겠습니까?',
                style: const TextStyle(fontSize: 15),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('취소', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('삭제'),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          Measurements data = Measurements.data[name]![currentDate]!;
          String? removed = data.removeLastValue();

          if (removed != null) {
            await _saveData(data);
            if (context.mounted) {
              FFAppState().forceRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name [$removed] 삭제 완료'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF1E3A5F),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.close, color: Color(0xFFDC2626), size: 14),
              const SizedBox(width: 3),
              Text(
                stageName,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
