
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:touring/constant/color.dart';
import 'package:touring/constant/constant.dart';
import 'package:touring/layout/layout.dart';
import 'package:touring/layout/model/vo/screen.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/group.dart';
import 'package:touring/model/vo/member.dart';
import 'package:touring/model/vo/user.dart';
import 'package:touring/view/group/live.dart';

class InfoGroupPage extends StatefulWidget {
  final GroupVO group;
  InfoGroupPage({Key key, this.group}) : super(key: key);

  @override
  InfoGroupPageState createState() => InfoGroupPageState();
}

class InfoGroupPageState extends State<InfoGroupPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  List<Widget> _actionList = [];

  UserVO _userLogin;
  String _userId = '';
  GroupVO _group;
  bool _isRefresh = false;

  CollectionReference _queryUser;
  CollectionReference _queryGroup;

  final TextEditingController _textCodeController = TextEditingController();
  final TextEditingController _textNameController = TextEditingController();
  final TextEditingController _textLocationController = TextEditingController();
  final TextEditingController _textLatitudeController = TextEditingController();
  final TextEditingController _textLongitudeController = TextEditingController();
  final TextEditingController _textLeaderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _queryUser = FirebaseFirestore.instance.collection(kUsers);
    _queryGroup = FirebaseFirestore.instance.collection(kGroups);
    _initAction();
    _getUser();
    _getGroupInfo();
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

  void _getGroupInfo(){
    _group = widget.group;
    _queryGroup.doc(_group.code).snapshots().listen((value) {
      if (value.exists){
        _group = GroupVO.fromJson(value.data());
        _textCodeController.text = _group.code;
        _textNameController.text = _group.name;
        _textLocationController.text = _group.location;
        _textLatitudeController.text = _group.latitude.toString();
        _textLongitudeController.text = _group.longitude.toString();


        _queryGroup.doc(_group.code).collection(kMembers).get().then((_snapshotGroup){

          var _tempDistance = 0.0;
          MemberVO _selectmember;

          for (var i = 0; i < _snapshotGroup.docs.length; i++){
            var element = _snapshotGroup.docs[i];
            var member = MemberVO.fromJson(element.data());
            var latitude = member.latitude;
            var longitude = member.longitude;
            var distance = Geolocator.distanceBetween(_group.latitude, _group.longitude, latitude, longitude);
            member.distanceDestination = distance;

            if (i == 0){
              _tempDistance  = distance;
              _selectmember = member;
            }
            if (distance < _tempDistance){
              _selectmember = member;
            }
            _tempDistance = distance;
          }

          if (_selectmember != null){
            if (_selectmember.id.isNotEmpty){
              _queryUser.doc(_selectmember.id).get().then((_snapshotUser){
                if (_snapshotUser.exists){
                  var leader = UserVO.fromJson(_snapshotUser.data());
                  _textLeaderController.text = leader.name;
                }
              });
              /*
              _queryUser.doc(_selectmember.id).snapshots().listen((_snapshotUser) {
                if (_snapshotUser.exists){
                  var leader = UserVO.fromJson(_snapshotUser.data());
                  _textLeaderController.text = leader.name;
                }
              });
              print(_selectmember.id);
              */
            }
          }
        });
        /*
        _queryGroup.doc(_group.code).collection(kMembers)
            .snapshots()
            .listen((_snapshotGroup) {
          var _tempDistance = 0.0;
          MemberVO _selectmember;

          for (var i = 0; i < _snapshotGroup.docs.length; i++){
            var element = _snapshotGroup.docs[i];
            var member = MemberVO.fromJson(element.data());
            var latitude = member.latitude;
            var longitude = member.longitude;
            var distance = Geolocator.distanceBetween(_group.latitude, _group.longitude, latitude, longitude);
            member.distanceDestination = distance;

            if (i == 0){
              _tempDistance  = distance;
              _selectmember = member;
            }
            if (distance < _tempDistance){
              _selectmember = member;
            }
            _tempDistance = distance;
          }

          if (_selectmember != null){
            if (_selectmember.id.isNotEmpty){
              _queryUser.doc(_selectmember.id).get().then((_snapshotUser){
                if (_snapshotUser.exists){
                  var leader = UserVO.fromJson(_snapshotUser.data());
                  _textLeaderController.text = leader.name;
                }
              });
              *//*
              _queryUser.doc(_selectmember.id).snapshots().listen((_snapshotUser) {
                if (_snapshotUser.exists){
                  var leader = UserVO.fromJson(_snapshotUser.data());
                  _textLeaderController.text = leader.name;
                }
              });
              print(_selectmember.id);
              *//*
            }
          }
        });
        */
      }
    });
  }

  void _exitGroup(){
    _queryUser.doc(_userId).collection(kGroups).doc(_group.code).delete().then((value){
      _queryGroup.doc(_group.code).collection(kMembers).doc(_userId).delete().then((value){
        _isRefresh = true;
        Navigator.pop(context, _isRefresh);
      });
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Toast.show(kLocationServicesDisabledMessage,
        this.context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        Toast.show(kPermissionDeniedMessage,
          this.context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Toast.show(kPermissionDeniedForeverMessage,
        this.context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
      return false;
    }

    Toast.show(kPermissionGrantedMessage,
      this.context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
    );

    return true;
  }

  void _initAction(){
    _actionList.clear();
    _actionList = [
      IconButton(
        icon: Icon(Icons.live_tv),
        tooltip: 'Live',
        onPressed: () {
          _handlePermission().then((hasPermission){
            if (hasPermission) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveGroupPage(group: _group,),
                ),
              );
            } else {
              Toast.show(kLocationServicesNeedActivated,
                this.context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM,
              );
            }
          });
        },
      ),
    ];
  }

  Widget _inputBox(title, controller){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title,
            style: TextStyle(fontSize: 14.0,),
          ),
          SizedBox(height: 5.0,),
          SizedBox(height: 36.0,
            child: TextField(
              readOnly: true,
              controller: controller,
              maxLines: 1,
              style: TextStyle(
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                fillColor: kColorDeploy,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: kColorButton,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: kColorBorder,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                hintText: title,
                contentPadding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              ),
              onTap: (){
                if (controller.text.trim() == ''){
                  print('enter text');
                } else {
                  Clipboard.setData(ClipboardData(text: controller.text));
                  Toast.show('Teks disalin ke papan klip',
                    context,
                    duration: Toast.LENGTH_SHORT,
                    gravity: Toast.BOTTOM,
                  );
                }
              },
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
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                'Informasi Grup',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8.0),
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                '${_group.name}',
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
      actions: _actionList,
    );

    final assetName = 'assets/image/info.svg';
    final Widget cover = SvgPicture.asset(
      assetName,
      width: MediaQuery.of(context).size.width,
      semanticsLabel: 'Destinations',
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 10.0,),
            _inputBox('Kode Grup', _textCodeController),
            SizedBox(height: 10.0,),
            _inputBox('Nama Grup', _textNameController),
            SizedBox(height: 10.0,),
            _inputBox('Kreator Grup', _textLeaderController),
            SizedBox(height: 10.0,),
            _inputBox('Destinasi', _textLocationController),
            SizedBox(height: 10.0,),
            _inputBox('Latitude', _textLatitudeController),
            SizedBox(height: 10.0,),
            _inputBox('Longitude', _textLongitudeController),
            Divider(),
            Container(
              color: Color.fromRGBO(0, 0, 0, 255),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0,),),
                ),
                color: Colors.green.shade500,
                onPressed: () {
                  var text = 'Kode Grup: ${_group.code} \n'
                      'Nama Grup: ${_group.name} \n'
                      'Kreator Grup: ${_textLeaderController.text} \n'
                      'Lokasi: ${_group.location} \n'
                      'Latitude: ${_group.latitude} \n'
                      'Longitude: ${_group.longitude} \n'
                  ;
                  Share.share(text);
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.share,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12,),
                      Text('Bagikan Grup',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Color.fromRGBO(0, 0, 0, 255),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0,),),
                ),
                color: Colors.red.shade500,
                onPressed: () {
                  _exitGroup();
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.close,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12,),
                      Text('Keluar dari Grup',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    var _bodyList = <Widget>[
      _appBar,
      _header,
      _content,
    ];

    Widget _infoGroupPage = Scaffold(
      body: LayoutUI(
        screen: ScreenVO(
          template: Templates.home,
          body: _bodyList,
        ),
      ),
    );

    return _infoGroupPage;
  }
}
