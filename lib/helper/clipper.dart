import 'package:flutter/material.dart';
import 'dart:math' as math;

class CurveOne extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(size.width / 4, size.height - 36, size.width / 2, size.height - 12);
    path.quadraticBezierTo(size.width * 3 / 4, size.height + 12, size.width, size.height - 12);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveTwo extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(size.width / 4, size.height - 36, size.width / 2, size.height - 12);
    path.quadraticBezierTo(size.width * 3 / 4, size.height + 12, size.width, size.height - 12);
    path.lineTo(size.width, size.height - 12);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveThree extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(size.width / 4, size.height - 36, size.width / 2, size.height - 12);
    path.quadraticBezierTo(size.width * 3 / 4, size.height + 12, size.width, size.height - 12);
    path.lineTo(size.width, size.height - 12);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveSmall extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(size.width / 4, size.height - 25, size.width / 2, size.height - 12);
    path.quadraticBezierTo(size.width * 3 / 4, size.height, size.width, size.height - 12);
    path.lineTo(size.width, size.height - 12);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    /*
    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(size.width / 4, size.height - 25, size.width / 2, size.height - 12);
    path.quadraticBezierTo(size.width * 3 / 4, size.height, size.width, size.height - 12);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    */

    //path.lineTo(0, size.height - 25);
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(size.width / 2, size.height - 25, size.width, size.height - 12);
    //path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 12);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottomOne extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(size.width / 4, size.height - 50, size.width / 2, size.height - 15);
    path.quadraticBezierTo(size.width * 3 / 4, size.height + 15, size.width, size.height - 25);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottomTwo extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 4, size.height - 70, size.width / 2, size.height - 15);
    path.quadraticBezierTo(size.width * 3 / 4, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottomThree extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 4, size.height - 90, size.width / 2, size.height - 20);
    path.quadraticBezierTo(size.width * 3 / 4, size.height + 35, size.width, size.height - 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottomCircleOne extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width * 2 / 3, size.height + 10), radius: 50));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottomCircleTwo extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width * 2 / 3, size.height + 5), radius: 55));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class CurveBottomCircleThree extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width * 2 / 3, size.height), radius: 60));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
     this.minHeight,
     this.maxHeight,
     this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent)
  {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
