import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toast/toast.dart';
import 'package:touring/constant/color.dart';
import 'package:touring/layout/layout.dart';
import 'package:touring/layout/model/vo/screen.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/group.dart';
import 'package:touring/model/vo/member.dart';
import 'package:touring/model/vo/menu.dart';
import 'package:touring/model/vo/user.dart';

class CreateGroupPage extends StatefulWidget {
  CreateGroupPage({Key key}) : super(key: key);

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Position _currPosition;
  LatLng _currLatLng;
  LatLng _destLatLng;
  Marker _destMarker;
  Marker _currMarker;
  bool _isRefresh = false;

  final TextEditingController _textNameController = TextEditingController();
  final TextEditingController _textLocationController = TextEditingController();

  GoogleMapController _googleMapController;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  final List<MenuVO> _menuIndexes = [];
  List<Widget> _actionList = [];

  UserVO _userLogin;

  CollectionReference _queryUser;
  CollectionReference _queryGroup;

  @override
  void initState() {
    super.initState();
    _currLatLng = LatLng(0, 0);
    _destLatLng = _currLatLng;
    _getCurrentLocation();
    _queryUser = FirebaseFirestore.instance.collection('users');
    _queryGroup = FirebaseFirestore.instance.collection('groups');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getUser() async {
    var _userCfg = UserConfig();
    _userLogin = await _userCfg.getUser();
  }

  void _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currPosition = position;
      _currLatLng = LatLng(_currPosition.latitude, _currPosition.longitude);
    });
    _updateMarker();
    if (_googleMapController != null){
      await _googleMapController.moveCamera(CameraUpdate.newLatLng(_currLatLng));
    }
  }

  void _initMenu() {
    _menuIndexes.clear();

    var menu = MenuVO();

    menu = MenuVO();
    menu.id = 1;
    menu.count = 8;
    menu.text = 'Buat Grup';
    menu.textColor = Colors.green[800];
    menu.shadowColor = Colors.green[300];
    menu.backColor = Colors.green[200];
    menu.colors = [
      Colors.green[200],
      Colors.green[400],
      Colors.green[600],
    ];
    menu.icon = Icons.group_add;
    _menuIndexes.add(menu);

    menu = MenuVO();
    menu.id = 2;
    menu.count = 6;
    menu.text = 'Gabung Grup';
    menu.textColor = Colors.blue[800];
    menu.shadowColor = Colors.blue[300];
    menu.backColor = Colors.blue[200];
    menu.colors = [
      Colors.blue[200],
      Colors.blue[400],
      Colors.blue[600],
    ];
    menu.icon = Icons.group_work;
    _menuIndexes.add(menu);

  }

  void _initAction(context){
    _actionList.clear();
    _actionList = [
      IconButton(
        icon: Icon(Icons.refresh),
        tooltip: 'Segarkan',
        onPressed: () {
          _getCurrentLocation();
        },
      ),
    ];
  }

  void _onMapTapped(latLng){
    setState(() {
      _destLatLng = latLng;
      var id = 'YourDestination';
      var newMarker = Marker(
        markerId: MarkerId('YourDestination'),
        position: latLng,
        infoWindow: InfoWindow(
          title: 'Lokasi Tujuan',
          snippet: 'Posisi lokasi tujuan',
        ),
      );
      _destMarker = newMarker.copyWith(
        iconParam: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
      _markers.clear();
      _markers[_currMarker.markerId] = _currMarker;
      _markers[MarkerId(id)] = _destMarker;
    });

    print(latLng.latitude);
    print(latLng.longitude);
  }

  void _updateMarker(){
    setState(() {
      var id = 'YourLocation';
      _markers.clear();
      _currMarker = Marker(
        markerId: MarkerId(id),
        position: _currLatLng,
        infoWindow: InfoWindow(
          title: 'Lokasi Anda',
          snippet: 'Posisi lokasi Anda saat ini',
        ),
      );
      _markers[MarkerId(id)] = _currMarker;

      if (_googleMapController != null){
        _googleMapController.moveCamera(CameraUpdate.newLatLng(_currLatLng));
      }
    });
  }

  String _generateCode(int len) {
    var r = Random();
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  Future<void> _createGroup() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buat Grup'),
          content: Container(
            height: 120.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textNameController,
                  decoration: InputDecoration(hintText: 'Nama Grup'),
                ),
                SizedBox(height: 10.0,),
                TextField(
                  controller: _textLocationController,
                  decoration: InputDecoration(hintText: 'Nama Lokasi'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: Text('Simpan'),
              onPressed: () {
                if (_textNameController.text.isNotEmpty &&
                    _textLocationController.text.isNotEmpty){
                  var time = DateTime.now().millisecondsSinceEpoch;
                  var groupVO = GroupVO();
                  var code = _generateCode(6);
                  groupVO.code = code;
                  groupVO.creator = _userLogin.uid;
                  groupVO.longitude = _destLatLng.longitude;
                  groupVO.latitude = _destLatLng.latitude;
                  groupVO.name = _textNameController.text;
                  groupVO.location = _textLocationController.text;
                  groupVO.type = 0;
                  groupVO.created = time;

                  _queryGroup.doc(code).get().then((value){
                    if (value.exists){
                      Toast.show('Grup ${groupVO.name} gagal dibuat, silakan coba lagi',
                        this.context,
                        duration: Toast.LENGTH_LONG,
                        gravity: Toast.BOTTOM,
                      );
                    } else {
                      _queryGroup.doc(code).set(groupVO.toJson()).then((value){
                        MemberVO member = MemberVO(
                          id: _userLogin.uid,
                          latitude: _currLatLng.latitude,
                          longitude: _currLatLng.longitude,
                        );

                        _queryGroup.doc(code).collection('members')
                            .doc(_userLogin.uid).set(member.toJson()
                        ).then((value){
                          _queryUser.doc(_userLogin.uid).collection('groups')
                              .doc(code).set({'code': code}).then((value){
                            Toast.show('Grup ${groupVO.name} berhasil dibuat',
                              this.context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                            );

                            _textNameController.text = "";
                            _textLocationController.text = "";

                            _isRefresh = true;
                          });
                        });
                      });
                    }
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initMap(GoogleMapController controller) async {
    _googleMapController = controller;
    _updateMarker();
  }

  @override
  Widget build(BuildContext context) {
    _initAction(context);
    _getUser();
    _initMenu();

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
                'Buat Grup',
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
                'Pilih Titik Destinasi Grup',
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

    Widget _map = SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: GoogleMap(
                onMapCreated: _initMap,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                mapToolbarEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _currLatLng,
                  zoom: 15,
                ),
                markers: _markers.values.toSet(),
                onTap: _onMapTapped,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
            SizedBox(height: 12,),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 16.0, ),
                      child: Text(
                        'Latitude: ${_destLatLng.latitude.toString()}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(right: 16.0, ),
                      child: Text(
                        'Longitude: ${_destLatLng.longitude.toString()}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                color: Color.fromRGBO(0, 0, 0, 255),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0,),),
                  ),
                  color: kColorsGreen500,
                  onPressed: () {
                    _createGroup();
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.check_circle,
                          color: Colors.black45,
                        ),
                        SizedBox(width: 12,),
                        Text('Buat',
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
            ],
          ),
        ),
      ),
    );

    var _bodyList = <Widget>[
      _appBar,
      _map,
      _content,
    ];

    Widget _createGroupPage =
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
    return _createGroupPage;
  }
}
