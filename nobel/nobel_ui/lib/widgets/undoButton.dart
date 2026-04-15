import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';
import '../data/nobel_data.dart';
import '../data/database_helper.dart';
import '../utils/const.dart';

/// 오늘 데이터 전체 삭제 버튼
class UndoButton extends StatelessWidget {
  const UndoButton({super.key, required this.nameIndex});

  final int nameIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          String name = Constants.names[nameIndex];
          String currentDate = FFAppState().CurrentDate;

          if (!Measurements.data[name]!.containsKey(currentDate)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('삭제할 데이터가 없습니다.'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            return;
          }

          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                '전체 삭제',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Text(
                '$name의 오늘($currentDate) 측정값을\n전부 삭제하시겠습니까?',
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
                  child: const Text('전체 삭제'),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          // 해당 날짜의 Measurements 객체 자체를 삭제
          Measurements.data[name]!.remove(currentDate);

          // dateList에서 해당 날짜를 사용하는 다른 소재가 없으면 dateList에서도 제거
          bool dateUsedElsewhere = false;
          for (String otherName in Constants.names) {
            if (otherName != name &&
                Measurements.data[otherName]!.containsKey(currentDate)) {
              dateUsedElsewhere = true;
              break;
            }
          }
          if (!dateUsedElsewhere) {
            Measurements.dateList.remove(currentDate);
          }

          // SQLite에서 삭제
          await DatabaseHelper().deleteMeasurement(name, currentDate);

          if (context.mounted) {
            FFAppState().forceRefresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name 오늘 데이터 전체 삭제 완료'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF1E3A5F),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 22),
              SizedBox(width: 8),
              Text(
                '전체 삭제',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
