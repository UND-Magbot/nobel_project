import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/flutter_flow/flutter_flow_theme.dart';
import 'package:test_novel_i_r_i_s3/flutter_flow/flutter_flow_util.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import 'package:test_novel_i_r_i_s3/utils/const.dart';
import '../../utils/functions.dart';

class ClickableContainer extends StatefulWidget {
  final String name;
  final String text;
  final double scaleFactor;

  const ClickableContainer(
      {super.key,
      required this.scaleFactor,
      required this.name,
      required this.text});

  @override
  _ClickableContainerState createState() => _ClickableContainerState();
}

class _ClickableContainerState extends State<ClickableContainer> {
  bool _isHovered = false;
  static var logger = AppLogger.instance;

  @override
  Widget build(BuildContext context) {
    List checkNumList = Constants.getDataParams(widget.name)[2];
    if (checkNumList.contains(widget.text)) {
      return InkWell(
        onTap: () {
          AppLogger.instance.i('클릭 성공!');
          AppLogger.instance.i('widget.name : ${widget.name}');
          var jsonData = toJsonFromCurrentMonth(widget.name);
          if (jsonData.length == 0) {
            showDialog(
              context: context,
              builder: (alertDialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text(
                    '데이터 없음.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    '해당 월에 데이터가 존재하지 않습니다.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(alertDialogContext),
                      child: const Text('Ok'),
                    ),
                  ],
                );
              },
            );
            return;
          } else {
            context.push(
              '/monthManagement',
              extra: {
                'widget.name': widget.name,
                'checkNum': widget.text,
                'month': FFAppState().getCurrentMonth(),
                'jsonMap': jsonData,
              },
            );
          }
        },
        child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isHovered = false;
              });
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.05,
              height: MediaQuery.sizeOf(context).height * 0.04,
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0x201E3A5F)
                    : const Color(0x121E3A5F),
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                ),
              ),
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Text(
                  widget.text,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        fontSize: 25.0 * widget.scaleFactor,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            )),
      );
    } else {
      return Container(
        width: MediaQuery.sizeOf(context).width * 0.05,
        height: MediaQuery.sizeOf(context).height * 0.04,
        decoration: BoxDecoration(
          color: const Color(0x0A1E3A5F),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
          ),
        ),
        child: Align(
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Text(
            widget.text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  fontSize: 25.0 * widget.scaleFactor,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }
  }
}
