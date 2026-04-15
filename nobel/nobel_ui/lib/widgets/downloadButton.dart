import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import '../utils/functions.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key, required this.type});
  static var logger = AppLogger.instance;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          sendJsonData(type);
          FFAppState().setIsLoading(true);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.file_download_outlined, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                '엑셀 저장',
                style: TextStyle(
                  color: Colors.white,
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
