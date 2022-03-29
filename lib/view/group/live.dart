import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toast/toast.dart';
import 'package:touring/constant/color.dart';
import 'package:touring/constant/constant.dart';
import 'package:touring/layout/layout.dart';
import 'package:touring/layout/model/vo/screen.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/broadcast.dart';
import 'package:touring/model/vo/group.dart';
import 'package:touring/model/vo/member.dart';
import 'package:touring/model/vo/menu.dart';
import 'package:touring/model/vo/position.dart';
import 'package:touring/model/vo/user.dart';

class LiveGroupPage extends StatefulWidget {
  final GroupVO group;
  LiveGroupPage({Key key, this.group}) : super(key: key);

  @override
  LiveGroupPageState createState() => LiveGroupPageState();
}

class LiveGroupPageState extends State<LiveGroupPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //LatLng _currLatLng;
  //LatLng _destLatLng;
  //Marker _destMarker;

  GoogleMapController _googleMapController;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<String, MemberVO> _members = <String, MemberVO>{};

  //final Set<Polyline> _polylines = {};

  final List<MenuVO> _menuIndexes = [];
  List<Widget> _actionList = [];

  UserVO _userLogin;
  GroupVO _group;
  MemberVO _selectedMember;
  MemberVO _selectedUser;
  MemberVO _selectedHeader;

  String _userId = '';
  bool _isSpeak = false;

  CollectionReference _queryUsers;
  CollectionReference _queryGroups;
  CollectionReference _queryLives;

  dynamic languages;
  String language;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  Position _curPosition;
  FlutterTts flutterTts;
  /*
  var _currPosition = PositionVO();
  var _lastPosition = PositionVO();
  */
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<Position> _positionStreamSubscription;
  bool positionStreamStarted = false;

  var _iconUser;
  var _iconMember;
  var _iconHeader;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _initTts();
    _initIcons();
    _getUser();
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    try {
      if (flutterTts != null){
        flutterTts.stop();
      }
    } catch (e) {
      print(e);
    }

    super.dispose();
  }

  void _initAction(context){
    _actionList.clear();
    _actionList = [
      IconButton(
        icon: Icon(Icons.warning_outlined,
          color: Colors.red,
        ),
        tooltip: 'Broadcast',
        onPressed: () {
          _showBroadcastDialog(context);
        },
      ),
    ];
  }

  //Inisialisasi warna profil pengendara
  void _initIcons() async {
    _iconUser = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48.0, 48.0,)), 'assets/image/green_bike.png');
    _iconMember = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48.0, 48.0,)), 'assets/image/black_bike.png');
    _iconHeader = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48.0, 48.0,)), 'assets/image/red_bike.png');
  }

  void _getUser() async {
    var _userCfg = UserConfig();
    _userLogin = await _userCfg.getUser();
    if (_userLogin != null){
      _userId = _userLogin.uid;
      if (_group != null) {
        _queryUsers = FirebaseFirestore.instance.collection(kUsers);
        _queryLives = FirebaseFirestore.instance.collection(kLives);
        _queryGroups = FirebaseFirestore.instance.collection(kGroups);

        _queryGroups.doc(_group.code).collection(kMembers)
            .doc(_userId).get().then((value){
          if (value.exists){
            _getCurrentPosition();
          }
        });
      }
    }
  }

  void _listenPosition() {
    final positionStream = _geolocatorPlatform.getPositionStream(
      locationSettings: AndroidSettings(
        intervalDuration: Duration(seconds: kTimeInterval) ,
        accuracy: LocationAccuracy.high,

      ),
    );
    _positionStreamSubscription = positionStream.handleError((error) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }).listen((position){
      Toast.show("Stream Refresh",
        this.context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
      _updateLocation(position);
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();

    var currentTime = DateTime.now().millisecondsSinceEpoch;
    double currentLatitude = position.latitude;
    double currentLongitude = position.longitude;

    var currPosition = PositionVO();

    currPosition.currentTime = currentTime;
    currPosition.currentLatitude = currentLatitude;
    currPosition.currentLongitude = currentLongitude;

    _listenBroadcast(this.context, position);

    _queryGroups.doc(_group.code).collection(kMembers)
        .doc(_userId).update(currPosition.toJson()).then((value){
      _listenPosition();
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

  Future<void> _initMap(GoogleMapController controller) async {
    _googleMapController = controller;
    if (_group != null){
      var destLatitude = _group.latitude;
      var destLongitude = _group.longitude;
      LatLng destLatLng = LatLng(destLatitude, destLongitude);
      Marker destMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        markerId: MarkerId(_group.code),
        position: destLatLng,
        infoWindow: InfoWindow(
          title: '${_group.location}',
          snippet: 'Posisi Lokasi Tujuan',
        ),
      );

      _markers[MarkerId(_group.code)] = destMarker;
    }
  }

  void _updateLocation(Position position) {
    var destLatitude = _group.latitude;
    var destLongitude = _group.longitude;

    var currentTime = DateTime.now().millisecondsSinceEpoch;
    double currentLatitude = position.latitude;
    double currentLongitude = position.longitude;

    var currPosition = PositionVO();
    var lastPosition = PositionVO();

    currPosition.currentTime = currentTime;
    currPosition.currentLatitude = currentLatitude;
    currPosition.currentLongitude = currentLongitude;

    _queryLives.doc(_group.code).collection(kMembers)
        .doc(_userId).collection(kRecords).get().then((records){
      var size = records.size;
      var num = (size + 1).toString();
      int lastTime = currentTime;

      double lastLatitude = currentLatitude;
      double lastLongitude = currentLongitude;

      if (size > 0){
        var lastData = records.docs[size - 1].data();
        if (lastData != null){
          lastPosition = PositionVO.fromJson(lastData);
          if (lastPosition != null){
            lastTime = lastPosition.currentTime;
            lastLatitude = lastPosition.currentLatitude;
            lastLongitude = lastPosition.currentLongitude;
            if (lastLatitude == null) lastLatitude = 0.0;
            if (lastLongitude == null) lastLongitude = 0.0;
          }
          if (lastTime == 0) lastTime = currentTime;
        }
      }

      currPosition.lastTime = lastTime;
      currPosition.lastLatitude = lastLatitude;
      currPosition.lastLongitude = lastLongitude;

      var distanceDest = Geolocator.distanceBetween(
          destLatitude, destLongitude,
          currentLatitude, currentLongitude);

      var distanceMove = Geolocator.distanceBetween(
          lastLatitude, lastLongitude,
          currentLatitude, currentLongitude);

      double speed = 0.0;

      var balanceMilli = (currentTime - lastTime);
      if (balanceMilli > 0){
        var balance = balanceMilli / 1000;
        if (distanceMove > 0){
          if (balance > 0){
            var time = balance / 3600.0;
            var distanceKM = distanceMove / 1000.0;
            speed = distanceKM / time;
          }
        }
      }

      currPosition.distanceDestination = distanceDest;
      currPosition.speed = speed;

      _queryLives.doc(_group.code).collection(kMembers)
          .doc(_userId).collection(kRecords)
          .doc(num.padLeft(9, '0'))
          .set(currPosition.toJson()).then((value){

        _queryGroups.doc(_group.code).collection(kMembers)
            .doc(_userId).set(currPosition.toJson()).then((value){
          _updatePosition();
        });
      });
      _curPosition = position;
    });
  }

  //Perhitungan perbandingan jarak dan notifikasi dengan member lain
  void _updatePosition() {
    List<MemberVO> memberDistances = [];
    List<MemberVO> memberSpeeds = [];

    _queryGroups.doc(_group.code).collection(kMembers)
      .get().then((_snapshotGroup) {

      memberDistances.clear();
      memberSpeeds.clear();

      for (var i = 0; i < _snapshotGroup.docs.length; i++) {
        var element = _snapshotGroup.docs[i];
        var memberId = element.id;
        var memberPosition = PositionVO.fromJson(element.data());

        var memberLat = memberPosition.currentLatitude;
        var memberLon = memberPosition.currentLongitude;

        MemberVO member = MemberVO(
          id: memberId,
          name: '',
          latitude: memberLat,
          longitude: memberLon,
          lastLatitude: memberPosition.lastLatitude,
          lastLongitude: memberPosition.lastLongitude,
          currentLatitude: memberPosition.currentLatitude,
          currentLongitude: memberPosition.currentLongitude,
          distanceDestination: memberPosition.distanceDestination,
          speed: memberPosition.speed,
        );

        memberDistances.add(member);
        memberSpeeds.add(member);

        _queryUsers.doc(memberId).get().then((_snapshotUser) {
          if (_snapshotUser.exists){
            var userMember = UserVO.fromJson(_snapshotUser.data());
            member.name = userMember.name;
            setState(() {
              _members[memberId] = member;
            });
          }
        });

      }
      //pengurutan member berdasarkan jarak dan kecepatan nya terhadap lokasi tujuan
      memberDistances.sort((x, y) => x.distanceDestination.compareTo(y.distanceDestination));
      memberSpeeds.sort((x, y) => x.speed.compareTo(y.speed));

      var vd = 0.01;
      var vs = 0.15;

      int memberCount = memberDistances.length;

      if (memberCount > 0){

        var headerId = memberDistances[0].id;

        for (var i = 0; i < memberCount; i++) {
          MemberVO member = memberDistances[i];
          var currId = member.id;

          var memberLat = member.currentLatitude;
          var memberLon = member.currentLongitude;

          double backDistance = 0.0;
          double currRangeFront = 0.0;
          double currRangeBack = 0.0;
          var division = 1000;
          double frontDistance = memberDistances[0].distanceDestination / division;
          double currDistance = memberDistances[i].distanceDestination / division;
          double currSpeed = (memberDistances[i].speed * 1000).ceilToDouble();
          double safeRange = (1000 * (currSpeed / 1000).ceilToDouble() * vd * memberCount).ceilToDouble();
          double safeSpeed = (1000 * (currSpeed / 1000).ceilToDouble() * vs).ceilToDouble();

          if (i > 0){
            frontDistance = memberDistances[i - 1].distanceDestination / division;
            currRangeFront = ((currDistance - frontDistance) * division).ceilToDouble();
          }

          if (i < (memberCount - 1)){
            backDistance = memberDistances[i + 1].distanceDestination / division;
            currRangeBack = ((backDistance - currDistance) * division).ceilToDouble();
          }

          double lastLatitude = memberDistances[0].lastLatitude;
          double lastLongitude = memberDistances[0].lastLongitude;
          double currentLatitude = memberDistances[0].currentLatitude;
          double currentLongitude = memberDistances[0].currentLongitude;

          var distanceMove = Geolocator.distanceBetween(
              lastLatitude, lastLongitude,
              currentLatitude, currentLongitude);

          if (distanceMove > 0){
            /*
            print("index: $i, currRangeFront: $currRangeFront,"
                " currRangeBack: $currRangeBack,"
                " currSpeed: $currSpeed,"
                " safeSpeed: $safeSpeed, safeRange: $safeRange"
                " member: $memberCount"
            );
            */
            setState(() {
              _selectedHeader = memberDistances[0];

              if (currId == _userId){
                _selectedUser = member;
                var userMarker = createMarker(_iconUser, member);
                _markers[MarkerId(currId)] = userMarker;
                var memberLatLng = LatLng(memberLat, memberLon);
                _googleMapController.moveCamera(CameraUpdate.newLatLng(memberLatLng));
              } else {
                var memberMarker = createMarker(_iconMember, member);
                _markers[MarkerId(currId)] = memberMarker;
              }

              if (currId == headerId){
                var headerMarker = createMarker(_iconHeader, _selectedHeader);
                _markers[MarkerId(currId)] = headerMarker;
              }

              if ((currSpeed / 1000).ceil() > 0){
                //state kepala rombongan
                if (headerId == _userId){
                  if (currRangeBack > safeSpeed){
                    print("Kurangi Kecepatan");
                    print("index: $i, currRangeFront: $currRangeFront,"
                        " currRangeBack: $currRangeBack,"
                        " currSpeed: $currSpeed,"
                        " safeSpeed: $safeSpeed, safeRange: $safeRange"
                        " member: $memberCount"
                    );
                    var newVoiceText = 'Mohon kurangi kecepatan. '
                        'Anda melampaui sejauh ${(currRangeBack).toInt()} meter.'
                        'Kecepatan Anda saat ini ${(currSpeed / 1000).ceil()} Kilometer per Jam';
                    _speak(newVoiceText);
                  }
                  if (currRangeBack > safeRange){
                    print("Kurangi Kecepatan");
                    print("index: $i, currRangeFront: $currRangeFront,"
                        " currRangeBack: $currRangeBack,"
                        " currSpeed: $currSpeed,"
                        " safeSpeed: $safeSpeed, safeRange: $safeRange"
                        " member: $memberCount"
                    );
                    var newVoiceText = 'Mohon kurangi kecepatan. '
                        'Anda melampaui sejauh ${(currRangeBack).toInt()} meter.'
                        'Kecepatan Anda saat ini ${(currSpeed / 1000).ceil()} Kilometer per Jam';
                    _speak(newVoiceText);
                  }
                } else {
                  //state antar member
                  if (currId == _userId) {
                    if (i > 0) {
                      //Peringatan tertinggal
                      if (currRangeFront > safeRange) {
                        print("Tambah Kecepatan");
                        print("index: $i, currRangeFront: $currRangeFront,"
                            " currRangeBack: $currRangeBack,"
                            " currSpeed: $currSpeed,"
                            " safeSpeed: $safeSpeed, safeRange: $safeRange"
                            " member: $memberCount"
                        );
                        var newVoiceText = 'Mohon tambah kecepatan. '
                            'Anda tertinggal sejauh ${(currRangeFront).toInt()} meter.'
                            'Kecepatan Anda saat ini ${(currSpeed / 1000).ceil()} Kilometer per Jam';
                        _speak(newVoiceText);
                      }
                      if (currRangeFront > safeSpeed) {
                        print("Tambah Kecepatan");
                        print("index: $i, currRangeFront: $currRangeFront,"
                            " currRangeBack: $currRangeBack,"
                            " currSpeed: $currSpeed,"
                            " safeSpeed: $safeSpeed, safeRange: $safeRange"
                            " member: $memberCount"
                        );
                        var newVoiceText = 'Mohon tambah kecepatan. '
                            'Anda tertinggal sejauh ${(currRangeFront).toInt()} meter.'
                            'Kecepatan Anda saat ini ${(currSpeed / 1000).ceil()} Kilometer per Jam';
                        _speak(newVoiceText);
                      }
                    } else {
                      //Peringatan kurangi kecepatan
                      if (currRangeBack > safeRange) {
                        print("Kurangi Kecepatan");
                        print("index: $i, currRangeFront: $currRangeFront,"
                            " currRangeBack: $currRangeBack,"
                            " currSpeed: $currSpeed,"
                            " safeSpeed: $safeSpeed, safeRange: $safeRange"
                            " member: $memberCount"
                        );
                        var newVoiceText = 'Mohon kurangi kecepatan. '
                            'Anda melampaui sejauh ${(currRangeBack).toInt()} meter.'
                            'Kecepatan Anda saat ini ${(currSpeed / 1000).ceil()} Kilometer per Jam';
                        _speak(newVoiceText);
                      }
                      if (currRangeBack > safeSpeed) {
                        print("Kurangi Kecepatan");
                        print("index: $i, currRangeFront: $currRangeFront,"
                            " currRangeBack: $currRangeBack,"
                            " currSpeed: $currSpeed,"
                            " safeSpeed: $safeSpeed, safeRange: $safeRange"
                            " member: $memberCount"
                        );
                        var newVoiceText = 'Mohon kurangi kecepatan. '
                            'Anda melampaui sejauh ${(currRangeBack).toInt()} meter.'
                            'Kecepatan Anda saat ini ${(currSpeed / 1000)
                            .ceil()} Kilometer per Jam';
                        _speak(newVoiceText);
                      }
                    }
                  }
                }
              }
            });
          }
        }
      }

    });
  }

  Marker createMarker(icon, MemberVO member){
    var latLng = LatLng(member.latitude, member.longitude);

    return Marker(
      icon: icon,
      markerId: MarkerId(member.id),
      position: latLng,
      infoWindow: InfoWindow(
        title: member.name,
      ),
      onTap: (){
        setState(() {
          _selectedMember = _members[member.id];
          if (_selectedUser != null){
            double destUser = _selectedUser.distanceDestination;
            double destMember = _selectedMember.distanceDestination;
            var distance = destMember - destUser;
            if (distance < 0){
              distance = distance * -1;
            }
            _members[member.id].distanceMember = distance;
            _selectedMember = _members[member.id];
          }
        });
      },
    );
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak(_newVoiceText) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
        _isSpeak = false;
      }
    }
  }

  //inisialisasi bunyi notifikasi
  void _initTts() {
    flutterTts = FlutterTts();

    _getLanguages();
    _getEngines();

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print('error: $msg');
      });
    });
  }

  void _listenBroadcast(BuildContext context, Position position){
    _queryLives.doc(_group.code)
        .collection(kBroadcasts)
        .snapshots()
        .listen((_snapshotBroadcast) {
      for (var i = 0; i < _snapshotBroadcast.docs.length; i++){
        var element = _snapshotBroadcast.docs[i];
        var id = element.id;
        BroadcastVO broadcast = BroadcastVO.fromJson(element.data());
        if (broadcast.id != _userId){
          _queryLives.doc(_group.code)
              .collection(kBroadcasts)
              .doc(id)
              .collection(kReads)
              .doc(_userId).get().then((read){
            if (!read.exists){
              if (broadcast.message.isNotEmpty){
                if (!_isSpeak){
                  _speak(broadcast.message);
                  _showBroadcastAlert(context, id, broadcast, position);
                }
              }
            }
          });
        }
      }
    });
  }

  void _sendBroadcast(context, message){
    if (_curPosition != null){
      BroadcastVO broadcast = new BroadcastVO();
      broadcast.id = _userLogin.uid;
      broadcast.name = _userLogin.name;
      broadcast.latitude = _curPosition.latitude;
      broadcast.longitude = _curPosition.longitude;
      broadcast.message = message;
      broadcast.created = DateTime.now().millisecondsSinceEpoch;

      _queryLives.doc(_group.code)
          .collection(kBroadcasts)
          .add(broadcast.toJson())
          .then((value){
        Toast.show("Broadcast terkirim",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      });
    }
  }

  void _showBroadcastDialog(BuildContext context) {
    // set up the list options
    Widget optionOne = SimpleDialogOption(
      child: Text(kMessage1,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      onPressed: () {
        _sendBroadcast(context, kMessage1);
        Navigator.of(context).pop();
      },
    );
    Widget optionTwo = SimpleDialogOption(
      child: Text(kMessage2,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      onPressed: () {
        _sendBroadcast(context, kMessage2);
        Navigator.of(context).pop();
      },
    );
    Widget optionThree = SimpleDialogOption(
      child: Text(kMessage3,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      onPressed: () {
        _sendBroadcast(context, kMessage3);
        Navigator.of(context).pop();
      },
    );
    Widget optionFour = SimpleDialogOption(
      child: Text(kMessage4,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      onPressed: () {
        _sendBroadcast(context, kMessage4);
        Navigator.of(context).pop();
      },
    );
    // set up the SimpleDialog
    SimpleDialog dialog = SimpleDialog(
      title: Text(kMessage0,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18.0,
        ),
      ),
      children: <Widget>[
        optionOne,
        optionTwo,
        optionThree,
        optionFour,
        MaterialButton(
          child: Text('Batal'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  void _showBroadcastAlert(BuildContext context, String id, BroadcastVO broadcast, Position position) {
    if (position != null){
      if (broadcast.message.isNotEmpty){
        var destLatitude = broadcast.latitude;
        var destLongitude = broadcast.longitude;
        var currentLatitude = position.latitude;
        var currentLongitude = position.longitude;
        var message = broadcast.message;

        var distanceDest = Geolocator.distanceBetween(
            destLatitude, destLongitude,
            currentLatitude, currentLongitude);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Perhatian'),
              content: Container(
                height: 150.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengirim',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text(
                                'Latitude',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text(
                                'Longitude',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text(
                                'Jarak',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                broadcast.name,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text(
                                broadcast.latitude.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text(
                                broadcast.longitude.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text('${distanceDest.ceil().toString()} meter',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text('Tutup'),
                  onPressed: () {
                    _queryLives.doc(_group.code)
                        .collection(kBroadcasts)
                        .doc(id)
                        .collection(kReads)
                        .doc(_userId).get().then((value){
                          if (!value.exists){
                            _queryLives.doc(_group.code)
                                .collection(kBroadcasts)
                                .doc(id)
                                .collection(kReads)
                                .doc(_userId).set(
                                  {'read': DateTime.now().millisecondsSinceEpoch}
                                );
                          }
                    });

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initAction(context);
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
                'Live',
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
                'Posisi Anggota Grup',
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

    //inisialisasi google maps
    Widget _map = SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 120,
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
                  target: _selectedUser != null ?
                  LatLng(_selectedUser.latitude, _selectedUser.longitude) :
                  LatLng(0.0, 0.0),
                  zoom: 15,
                ),
                markers: _markers.values.toSet(),
                //polylines: _polylines,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
            SizedBox(height: 12,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Anggota',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          'Jarak dengan Anda',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          'Jarak ke Tujuan',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          'Kecepatan',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  SizedBox(width: 10.0,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedMember != null ? '${_selectedMember.name}' : '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          _selectedMember != null ?
                          '${_selectedMember.distanceMember.toStringAsFixed(2)} meter' : '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          _selectedMember != null ?
                          '${_selectedMember.distanceDestination.toStringAsFixed(2)} meter' : '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                        Text(
                          _selectedMember != null ?
                          '${_selectedMember.speed.toStringAsFixed(0)} KMPJ' : '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 5.0,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    var _bodyList = <Widget>[
      _appBar,
      _map,
    ];

    Widget _liveGroupPage =
    Scaffold(
      body: LayoutUI(
        screen: ScreenVO(
          template: Templates.home,
          body: _bodyList,
        ),
      ),
    );
    return _liveGroupPage;
  }
}
