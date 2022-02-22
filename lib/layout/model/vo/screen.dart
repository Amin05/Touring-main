import 'package:flutter/material.dart';

class ScreenVO {
  final int id;
  final IconData icon;
  final String title;
  final String hint;
  final String subTitle;
  final String image;
  final Color color;
  final Templates template;
  final List<Widget> body;
  final Widget header;
  final Widget footer;

  ScreenVO({
     this.id,
     this.template,
     this.icon,
     this.title,
     this.subTitle,
     this.color,
     this.image,
     this.header,
     this.footer,
     this.body,
     this.hint});
}

enum Templates {
  normal,
  home,
  user,
  search,
  report,
  detail,
  map,
  page,
  chat,
}