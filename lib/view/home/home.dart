
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touring/constant/color.dart';
import 'package:touring/constant/constant.dart';
import 'package:touring/helper/clipper.dart';
import 'package:touring/layout/layout.dart';
import 'package:touring/layout/model/vo/screen.dart';
import 'package:touring/model/vo/group.dart';
import 'package:touring/model/vo/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/user.dart';
import 'package:touring/view/group/create.dart';
import 'package:touring/view/group/info.dart';
import 'package:touring/view/group/join.dart';
import 'package:touring/view/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final List<MenuVO> _menuIndexes = [];
  final List<GroupVO> _groupIndexes = [];
  List<Widget> _actionList = [];

  bool _isLoading = false;
  UserVO _userLogin;
  String _userName = '';
  String _userId = '';
  bool _isLoggedIn = false;
  int _listMode = 0;


  final UserConfig _userCfg = UserConfig();
  CollectionReference _queryUser;
  CollectionReference _queryGroup;

  @override
  void initState() {
    super.initState();
    _queryUser = FirebaseFirestore.instance.collection('users');
    _queryGroup = FirebaseFirestore.instance.collection('groups');
    _initMenu();
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initMenu() {
    _menuIndexes.clear();

    var menu = MenuVO();

    menu = MenuVO();
    menu.id = 1;
    menu.count = 8;
    menu.text = 'Buat Grup';
    menu.textColor = Colors.blue[800];
    menu.shadowColor = Colors.grey[200];
    menu.backColor = Colors.white;
    menu.colors = [
      Colors.blue[200],
      Colors.blue[400],
      Colors.blue[600],
    ];
    menu.icon = Icons.group_add;
    _menuIndexes.add(menu);

    menu = MenuVO();
    menu.id = 2;
    menu.count = 6;
    menu.text = 'Gabung Grup';
    menu.textColor = Colors.yellow[800];
    menu.shadowColor = Colors.grey[200];
    menu.backColor = Colors.white;
    menu.colors = [
      Colors.yellow[200],
      Colors.yellow[400],
      Colors.yellow[600],
    ];
    menu.icon = Icons.group_work;
    _menuIndexes.add(menu);

  }

  void _getListGroup() async {
    if (_userId.isNotEmpty){
      _groupIndexes.clear();
      _queryUser.doc(_userId).collection(kGroups)
          .snapshots()
          .listen((_snapshotUser) {
        _groupIndexes.clear();

        if (_snapshotUser.docs.isNotEmpty){
          _listMode = 1;
        }

        for (var i = 0; i < _snapshotUser.docs.length; i++){
          var element = _snapshotUser.docs[i];
          var tmpGroup = GroupVO.fromJson(element.data());

          //setState(() {
          _groupIndexes.add(tmpGroup);
          //});

          var id = tmpGroup.code;
          _queryGroup.doc(id).snapshots().listen((value) {
            var group = GroupVO.fromJson(value.data());
            group.code = id;
            setState(() {
              _groupIndexes[i] = group;
            });
          });
        }
      });
    }
  }

  void _getUser() async {
    var _userCfg = UserConfig();
    _userLogin = await _userCfg.getUser();
    if (_userLogin != null){
      setState(() {
        _userName = _userLogin.name;
        _userId = _userLogin.uid;
      });

      _getListGroup();
    }
  }

  void _initAction(){
    _actionList.clear();
    _actionList = [
      IconButton(
        icon: Icon(Icons.logout,
          color: kColorsGrey800,
        ),
        tooltip: 'Keluar',
        onPressed: () {
          _logout();
        },
      ),
    ];
  }

  Widget _itemMenu(int index) {
    var menu = _menuIndexes[index];
    var text = menu.text;

    var textColor = menu.textColor;
    var textShadow = menu.shadowColor;
    var backColor = menu.backColor;

    var colors1 = menu.colors;
    var colors2 = menu.colors;

    Widget icon = Icon(
      menu.icon,
      size: 40.0,
      color: textColor,
    );

    Widget content = Container(
      padding: EdgeInsets.all(0.0),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(
            height: 5.0,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 20.0,
              color: textColor,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: textShadow,
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
                  colors: colors1,
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
                  colors: colors2,
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

  Widget _itemGroup(int index) {
    var group = _groupIndexes[index];
    var text = group.name;
    var code = group.code;
    var location = group.location;

    var textColor = Colors.green[800];
    var shadowColor = Colors.grey[300];
    var backColor = Colors.white;
    var colors = [
      Colors.green[200],
      Colors.green[400],
      Colors.green[600],
    ];

    Widget icon = Icon(
      Icons.group_rounded,
      size: 30.0,
      color: textColor,
    );

    Widget content = Container(
      padding: EdgeInsets.all(0.0),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
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
                  fontWeight: FontWeight.bold,
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
          Text(
            code,
            style: TextStyle(
              fontSize: 14.0,
              color: textColor,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            location,
            style: TextStyle(
              fontSize: 14.0,
              color: textColor,
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
                  _groupClick(index);
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateGroupPage(),
          ),
        ).then((value){
          _refreshList(value);
        });

        break;
      case 1:

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JoinGroupPage(),
          ),
        ).then((value){
          _refreshList(value);
        });

        break;
    }
  }

  void _groupClick(int index){
    var group = _groupIndexes[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoGroupPage(
          group: group,
        ),
      ),
    ).then((value){
      //_refreshList(value);
    });

  }

  void _logout() {
    googleSignIn.isSignedIn().then((value){
      googleSignIn.signOut().then((value){
        firebaseAuth.signOut().then((value){
          _userCfg.clearUser();
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        });
      });
    });
  }

  void _refreshList(bool reload){
    /*
    if (reload != null){
      if (reload){
        setState(() {
          _getListGroup();
        });
      }
    }
    */
  }

  void showAlertDialog(BuildContext context) {
    Widget cancelButton = MaterialButton(
      child: Text("Tutup"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Informasi"),
      content: Text("Maaf, saat ini menu belum tersedia"),
      actions: [
        cancelButton,
      ],
    );  // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _alert(BuildContext context, String title, String text) {
    Widget cancelButton = MaterialButton(
      child: Text("Tutup"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        cancelButton,
      ],
    );  // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  Future<File> createFileOfPdfUrl(url) async {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    _initAction();

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
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                kAppTitle,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: kColorsGrey800,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 0.0),
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                kAppDescription,
                maxLines: 2,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: kColorsGrey800,
                  fontSize: 16.0,
                ),
              ),
            ),
            /*
            Container(
              margin: EdgeInsets.only(top: 2.0),
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                'Hai $_userName',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: kColorsLightBlue200,
                  fontSize: 16.0,
                ),
              ),
            ),
            */
          ],
        ),
      ),
      floating: true,
      pinned: true,
      actions: _actionList,
    );

    final assetName = 'assets/image/destinations.svg';
    final Widget cover = SvgPicture.asset(
      assetName,
      width: MediaQuery.of(context).size.width,
      semanticsLabel: 'Dashboard',
    );

    Widget _header = SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: EdgeInsets.all(0.0,),
          color: kColorPrimary,
          child: cover,
        ),
      ),
    );

    Widget _loading = SliverToBoxAdapter(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 5.0,),
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            color: kColorsLightBlue200,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            border: Border.all(
              color: kColorPrimary,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Container(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              valueColor : AlwaysStoppedAnimation(kColorPrimary),
            ),
          ),
        ),
      ),
    );

    Widget _title = SliverToBoxAdapter(
      child: Center(
        child: Container(
          margin: EdgeInsets.only(top: 20.0,),
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 8.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  'Daftar Grup',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget _content = SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  'Daftar grup yang Anda ikuti',
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
      ),
    );

    Widget _listGroup = SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: EdgeInsets.all(10.0,),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            border: Border.all(
              color: kColorsLightBlue200,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Text('Anda belum bergabung dengan grup'),
        ),
      ),
    );

    if (_listMode == 1){
      _listGroup = SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: 140.0,
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
    }

    Widget _listMenu = SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 130.0,
        maxCrossAxisExtent: 300.0,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index)
        {
          return _itemMenu(index);
        },
        childCount: _menuIndexes.length,
      ),
    );

    var _bodyList = <Widget>[
      _appBar,
      _header,
      _listMenu,
      _title,
      _content,
      _listGroup,
    ];

    Widget _homePage = Scaffold(
      body: LayoutUI(
        screen: ScreenVO(
          template: Templates.home,
          body: _bodyList,
        ),
      ),
    );

    return _homePage;
  }
}
