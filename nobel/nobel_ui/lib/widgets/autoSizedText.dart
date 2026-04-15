
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AutoSizedText extends StatelessWidget{

  AutoSizedText({super.key, required this.text, required this.scaleFactor });
  String text;
  double scaleFactor;

  @override
  Widget build(BuildContext context){
    return AutoSizeText(text,
      minFontSize: 1, 
      maxLines: 1,
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 20 * scaleFactor
      ),
    );
  }
}