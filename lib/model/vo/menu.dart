
import 'dart:ui';

import 'package:flutter/material.dart';

import 'image.dart';

class MenuVO {
  int id = 0;
  String text = '';
  String date = '';
  String time = '';
  int count = 0;
  Color textColor = Colors.red[800];
  Color shadowColor = Colors.red[300];
  Color backColor = Colors.red[200];
  List<Color> colors = [
    Colors.red[200],
    Colors.red[400],
    Colors.red[600],
  ];
  IconData icon = Icons.inbox;
  ImageVO image = ImageVO(path: "", type: 0);

  MenuVO({
    this.id,
    this.text,
    this.date,
    this.time,
    this.count,
    this.textColor,
    this.shadowColor,
    this.backColor,
    this.colors,
    this.icon,
    this.image,
  });
}
