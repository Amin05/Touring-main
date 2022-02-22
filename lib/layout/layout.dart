
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:touring/constant/color.dart';

import 'model/vo/screen.dart';

class LayoutUI extends StatelessWidget {
  final ScreenVO screen;
  LayoutUI({Key key, this.screen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _appBar = Container();
    var _slivers = <Widget>[];

    switch(screen.template){
      case Templates.normal:
        _appBar = SliverAppBar(
          backgroundColor: kColorPrimary,
          elevation: 0,
          centerTitle: false,
          pinned: true,
          title: Text(screen.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        );
        _slivers.add(_appBar);
        break;
      case Templates.home:
        break;
      case Templates.page:
        // TODO: Handle this case.
        break;
      case Templates.user:
        // TODO: Handle this case.
        break;
      case Templates.search:
        _appBar = SliverAppBar(
          backgroundColor: kColorPrimary,
          elevation: 0,
          centerTitle: true,
          pinned: true,
          title: Text(screen.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        );
        _slivers.add(_appBar);
        _slivers.add(screen.header);
        break;
      case Templates.report:

        break;
      case Templates.detail:
        // TODO: Handle this case.
        break;
      case Templates.map:
        // TODO: Handle this case.
        break;
      case Templates.chat:
        // TODO: Handle this case.
        break;
      default:
        // TODO: Handle this case.
        break;
    }

    if (screen.body != null) {
      if (screen.body.isNotEmpty) {
        _slivers.addAll(screen.body);
      }
    }

    return Container(
      padding: EdgeInsets.all(0),
      width: double.infinity,
      height: double.infinity,
      color: kColorPrimary,
      child: CustomScrollView(
        slivers: _slivers,
      ),
    );
  }
}
