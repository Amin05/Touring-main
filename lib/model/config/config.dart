import 'dart:convert';

import 'package:touring/constant/constant.dart';
import 'package:touring/model/vo/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainConfig {
  String searchType = '';
  String searchQuery = '';

  Future<String> getSavedString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getString(key) ?? "");
  }

  void setSavedString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  void clearSetting(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  Future<List<String>> getSavedStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(key) ?? null);
  }

  void setSavedStringList(String key, List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  Future<UserVO> getUser() async{
    String str = await getSavedString(kKeyUser);
    if (str.isNotEmpty){
      try {
        final jsonResponse = json.decode(str);
        return UserVO.fromJson(jsonResponse);
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }
  void setUser(UserVO item) {
    setSavedString(kKeyUser, item.toString());
  }
  void clearUser() {
    clearSetting(kKeyUser);
  }
}
