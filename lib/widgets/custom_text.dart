import 'package:flutter/material.dart';

class CustomText extends Text {
  CustomText(String data, {scaleFactor: 2.0, color: Colors.black, textAlign: TextAlign.center})
      : super(data,
        textAlign: textAlign,
        textScaleFactor: scaleFactor,
        style: new TextStyle(color: color)
      );
}