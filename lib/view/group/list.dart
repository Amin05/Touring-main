import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:touring/constant/color.dart';
import 'package:touring/constant/constant.dart';
import 'package:touring/helper/clipper.dart';
import 'package:touring/layout/layout.dart';
import 'package:touring/layout/model/vo/screen.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/group.dart';
import 'package:touring/model/vo/user.dart';

class ListGroupPage extends StatefulWidget {
  ListGroupPage({Key key}) : super(key: key);
  @override
  ListGroupPageState createState() => ListGroupPageState();
}

class ListGroupPageState extends State<ListGroupPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  UserVO _userLogin;

  CollectionReference _queryGroup;
  final List<GroupVO> _groupIndexes = [];

  bool _isRefresh = false;

  @override
  void initState() {
    super.initState();
    _queryGroup = FirebaseFirestore.instance.collection('groups');
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getUser() async {
    var _userCfg = UserConfig();
    _userLogin = await _userCfg.getUser();
    setState(() {
      if (_userLogin != null){
        _getListGroup();
      }
    });
  }

  void _getListGroup() async {
    if (_userLogin != null){
      var _snapshotGroup = await _queryGroup.get();
      if (_snapshotGroup.size > 0){
        setState(() {
          _groupIndexes.clear();
          for (var i = 0; i < _snapshotGroup.docs.length; i++){
            var element = _snapshotGroup.docs[i];
            var group = GroupVO.fromJson(element.data());
            _groupIndexes.add(group);
          }
        });
      }
    }
  }

  Widget _itemGroup(int index) {
    var group = _groupIndexes[index];
    var text = group.name;

    var textColor = Colors.green[800];
    var shadowColor = Colors.green[300];
    var backColor = Colors.green[200];
    var colors = [
      Colors.green[200],
      Colors.green[400],
      Colors.green[600],
    ];

    var type = group.type;

    if (type == '1'){
      textColor = Colors.green[800];
      shadowColor = Colors.green[300];
      backColor = Colors.green[200];
      colors = [
        Colors.green[200],
        Colors.green[400],
        Colors.green[600],
      ];
    }

    Widget icon = Icon(
      Icons.group_rounded,
      size: 40.0,
      color: textColor,
    );

    Widget content = Container(
      padding: EdgeInsets.all(0.0),
      height: double.infinity,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(
            width: 5.0,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 20.0,
              color: textColor,
              shadows: [
                Shadow(
                  color: shadowColor,
                  blurRadius: 4.0,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.all(kItemSpace),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(0),
            elevation: 4.0,
            color: backColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(0),
              ),
              side: BorderSide(
                color: backColor,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Material(
              color: backColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(0),
                ),
                child: content,
                onTap: () {
                  _menuClick(index);
                },
              ),
            ),
          ),
          ClipPath(
            clipper: CurveSmall(),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment(1, 1),
                  tileMode: TileMode.repeated,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(0),
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: CurveBottom(),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topRight,
                  end: Alignment(1, 1),
                  tileMode: TileMode.repeated,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _menuClick(int index){
    switch(index){
      case 0:

        break;
      case 1:

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //_initAction(context);
    //_initMenu();

    Widget _appBar = SliverAppBar(
      toolbarHeight: 80.0,
      elevation: 1.0,
      backgroundColor: kColorPrimary,
      iconTheme: IconThemeData(color: Colors.black),
      title: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                'Daftar Grup',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              child: Text(
                'Daftar Grup yang Dapat Diikuti',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
      floating: true,
      pinned: true,
    );

    Widget _listGroup = SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 100.0,
        maxCrossAxisExtent: 360.0,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index)
        {
          return _itemGroup(index);
        },
        childCount: _groupIndexes.length,
      ),
    );

    var _bodyList = <Widget>[
      _appBar,
      _listGroup,
    ];

    Widget _listGroupPage =
    WillPopScope(
      onWillPop: () {
        Navigator.pop(context, _isRefresh);
        return Future(() => true);
      },
      child: Scaffold(
        body: LayoutUI(
          screen: ScreenVO(
            template: Templates.home,
            body: _bodyList,
          ),
        ),
      ),
    );
    return _listGroupPage;
  }
}
