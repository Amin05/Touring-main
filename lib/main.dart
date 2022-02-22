import 'package:touring/constant/constant.dart';
import 'package:touring/view/main/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TouringApp());
}

class TouringApp extends StatefulWidget {
  @override
  _TouringAppState createState() => _TouringAppState();
}

class _TouringAppState extends State<TouringApp> {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
