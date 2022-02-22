
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:touring/constant/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:touring/constant/constant.dart';
import 'package:touring/helper/clipper.dart';
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/user.dart';
import 'package:touring/view/home/home.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  CollectionReference _queryUser;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _queryUser = FirebaseFirestore.instance.collection('users');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    var googleUser = await googleSignIn.signIn();
    var googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    var firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      var _configVO = UserConfig();
      var _user = UserVO();
      _user.uid = firebaseUser.uid;
      _user.name = firebaseUser.displayName;
      _user.email = firebaseUser.email;
      _user.image = firebaseUser.photoURL;
      _user.tid = await firebaseMessaging.getToken();

      var _snapshotUser = await _queryUser.doc(_user.uid).get();

      UserVO _result;

      if (_snapshotUser.exists){
        _result = UserVO.fromJson(_snapshotUser.data());
        if (_result.tid != _user.tid){
          await _queryUser.doc(_user.uid).set(_user.toJson());
          _result.tid = _user.tid;
        }
      } else {
        await _queryUser.doc(_user.uid).set(_user.toJson());
        _result = _user;
      }

      if (_result != null){
        _configVO.setUser(_result);
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _loading = Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 5.0,),
      width: 44.0,
      height: 44.0,
      decoration: BoxDecoration(
        color: kColorPrimary,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        border: Border.all(
          color: kColorPrimary,
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
            valueColor : AlwaysStoppedAnimation(kColorPrimary),
          ),
        ),
      ),
    );

    Widget _button = Container(
      color: Color.fromRGBO(0, 0, 0, 255),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0,),),
        ),
        color: kColorsGreen,
        onPressed: _handleSignIn,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.account_circle,
                color: Colors.black45,
              ),
              SizedBox(width: 12,),
              Text('Masuk',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final assetName = 'assets/image/destinations.svg';
    final Widget cover = SvgPicture.asset(
      assetName,
      width: MediaQuery.of(context).size.width,
      semanticsLabel: 'Destinations',
    );

    Widget _form = Center(
      child: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.symmetric(
          vertical: 0.0,
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20,),
              child: cover,
            ),
            SizedBox(height: 10.0,),
            Text(kAppWelcome,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kColorsIndigo800,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0,),
            Text(kAppDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kColorsBlueGrey800,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 20.0,),
            Divider(
              color: kColorsGreen800,
              height: 1.0,
            ),
            SizedBox(height: 5.0,),
            Text(kLoginInstruction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kColorsBlueGrey800,
                fontSize: 16.0,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
              color: Color.fromRGBO(0, 0, 0, 255),
              height: 64,
              child: _isLoading ? _loading : _button,
            ),
          ],
        ),
      ),
    );

    Widget _body = Stack(
      children: [
        _form,
      ],
    );

    return Scaffold(
      body: _body,
      backgroundColor: kColorPrimary,
      bottomNavigationBar: Container(
        color: kColorPrimary,
        height: 70,
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: CurveBottomThree(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan[100],
                      Colors.cyan[200],
                      Colors.cyan[400],
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment(1, 1),
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: CurveBottomTwo(),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan[200],
                      Colors.cyan[400],
                      Colors.cyan[600],
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment(1, 1),
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: CurveBottomOne(),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan[400],
                      Colors.cyan[600],
                      Colors.cyan[800],
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment(1, 1),
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
