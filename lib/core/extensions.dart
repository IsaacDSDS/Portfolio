import 'package:flutter/material.dart';

extension CustomText on Text {
  Text get withOutline {
    return Text(
      data ?? '',
      style: TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black,
      ),
    );
  }
}
