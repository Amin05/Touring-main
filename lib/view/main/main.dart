
import 'package:touring/model/config/user.dart';
import 'package:touring/model/vo/user.dart';
import 'package:touring/view/home/home.dart';
import 'package:touring/view/login/login.dart';
import 'package:touring/view/splash/splash.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    //getToken();
  }

  void getToken() async {
    //_token = await firebaseMessaging.getToken();
  }

  @override
  Widget build(BuildContext context) {
    UserConfig _userCfg = UserConfig();

    return FutureBuilder(
      future: _userCfg.getUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          bool isLogin = false;
          if (snapshot.hasData) {
            UserVO user = snapshot.data;
            if (user != null){
              isLogin = true;
            }
          }

          if (isLogin) {
            return HomePage();
          } else {
            return LoginPage();
          }
        } else {
          return SplashPage();
        }
      },
    );
  }
}
