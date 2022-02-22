import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:touring/constant/color.dart';
import 'package:touring/constant/constant.dart';
import 'package:touring/helper/clipper.dart';
import 'package:touring/layout/layout.dart';
import 'package:touring/layout/model/vo/screen.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/group.dart';
import 'package:touring/model/vo/member.dart';
import 'package:touring/model/vo/user.dart';

class JoinGroupPage extends StatefulWidget {
  JoinGroupPage({Key key}) : super(key: key);

  @override
  JoinGroupPageState createState() => JoinGroupPageState();
}

class JoinGroupPageState extends State<JoinGroupPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool _isRefresh = false;
  int _searchMode = 0;

  final TextEditingController _textCodeController = TextEditingController();

  Position _currPosition;
  LatLng _currLatLng;

  UserVO _userLogin;
  String _userId = '';

  CollectionReference _queryUser;
  CollectionReference _queryGroup;

  GroupVO _resultGroup;

  @override
  void initState() {
    super.initState();
    _currLatLng = LatLng(-6.9971703, 107.5439868);
    _queryUser = FirebaseFirestore.instance.collection('users');
    _queryGroup = FirebaseFirestore.instance.collection('groups');
    _getUser();
    _getCurrentLocation();
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
        _userId = _userLogin.uid;
      }
    });
  }

  void _findGroup(){
    if (_textCodeController.text.isNotEmpty){
      setState(() {
        _searchMode = 1;
      });
      var id = _textCodeController.text;
      _queryGroup.doc(id).get().then((value) {
        if (value.exists){
          setState(() {
            _resultGroup = GroupVO.fromJson(value.data());
            _resultGroup.code = id;
            _searchMode = 2;
          });
        } else {
          setState(() {
            _searchMode = 3;
          });
        }
      });
    } else {
      setState(() {
        _searchMode = 4;
      });
    }
  }

  void _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currPosition = position;
    _currLatLng = LatLng(_currPosition.latitude, _currPosition.longitude);
  }

  void _joinGroup(){
    if (_resultGroup != null){
      var code = _resultGroup.code;
      _queryGroup.doc(code).collection('members')
          .doc(_userId).get().then((value) {
        if (!value.exists){
          var distanceDest = Geolocator.distanceBetween(
              _resultGroup.latitude, _resultGroup.longitude,
              _currLatLng.latitude, _currLatLng.longitude);

          MemberVO member = MemberVO(
            id: _userLogin.uid,
            latitude: _currLatLng.latitude,
            longitude: _currLatLng.longitude,
            distanceMember: 0.0,
            distanceDestination: distanceDest,
          );

          _queryGroup.doc(code).collection('members').doc(_userId).set(member.toJson()).then((value){
            _queryUser.doc(_userId).collection('groups').doc(code).set({'code': code}).then((value){
              setState(() {
                _searchMode = 5;
                _isRefresh = true;
              });
            });
          });
        } else {
          setState(() {
            _searchMode = 5;
            _isRefresh = true;
          });
        }
      });
    }
  }

  Widget _itemGroup() {
    var group = _resultGroup;
    var text = group.name;
    var code = group.code;
    var location = group.location;

    var textColor = Colors.green[800];
    var shadowColor = Colors.green[300];
    var backColor = Colors.white;
    var colors = [
      Colors.green[200],
      Colors.green[400],
      Colors.green[600],
    ];

    Widget icon = Icon(
      Icons.group_rounded,
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
                  _joinGroup();
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

  @override
  Widget build(BuildContext context) { 
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
                'Gabung Grup',
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
                'Isikan Kode Grup Tujuan',
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

    final assetName = 'assets/image/groups.svg';
    final Widget cover = SvgPicture.asset(
      assetName,
      width: MediaQuery.of(context).size.width,
      semanticsLabel: 'Groups',
    );

    Widget _header = SliverToBoxAdapter(
      child: Center(
        child: Container(
          color: kColorPrimary,
          child: cover,
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
              SizedBox(height: 10.0,),
              Container(
                child: TextField(
                  controller: _textCodeController,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                  decoration: InputDecoration(
                    fillColor: kColorWhite,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.group,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0,),),
                      gapPadding: 6.0,
                      borderSide: BorderSide(
                        color: kColorBorder,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    hintText: 'Kode Grup',
                    contentPadding: EdgeInsets.all(4.0),
                  ),
                ),
              ),
              SizedBox(height: 5.0,),
              Container(
                color: Color.fromRGBO(0, 0, 0, 255),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0,),),
                  ),
                  color: kColorsGreen,
                  onPressed: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      currentFocus.focusedChild.unfocus();
                    }
                    _findGroup();
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search,
                          color: Colors.black45,
                        ),
                        SizedBox(width: 12,),
                        Text('Cari',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.0,),
            ],
          ),
        ),
      ),
    );

    Widget _result = SliverToBoxAdapter(
      child: Container(),
    );

    if (_searchMode == 1){ //loading
      _result = SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: 5.0,),
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(
                color: kColorBorder,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Container(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  strokeWidth: 4.0,
                  valueColor : AlwaysStoppedAnimation(Colors.black45),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (_searchMode == 2){ // group found
      if (_resultGroup != null){
        _result = SliverToBoxAdapter(
          child: Container(
            height: 140.0,
            child: _itemGroup(),
          ),
        );
      } else {
        _result = SliverToBoxAdapter(
          child: Container(),
        );
      }
    } else if (_searchMode == 3){ //not found
      _result = SliverToBoxAdapter(
        child: Center(
          child: Text('Grup tidak ditemukan'),
        ),
      );
    } else if (_searchMode == 4){ //code empty
      _result = SliverToBoxAdapter(
        child: Center(
          child: Text('Isikan kode lebih dulu'),
        ),
      );
    } else if (_searchMode == 5){ //code empty
      _result = SliverToBoxAdapter(
        child: Center(
          child: Text('Berhasil bergabung dengan grup'),
        ),
      );
    }

    var _bodyList = <Widget>[
      _appBar,
      _header,
      _content,
      _result,
    ];

    Widget _joinGroupPage =
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
    return _joinGroupPage;
  }
}
