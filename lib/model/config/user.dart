import 'dart:convert';

import 'package:touring/constant/constant.dart';
import 'package:touring/model/vo/user.dart';

import 'config.dart';

class UserConfig {
  MainConfig _mainConfig = MainConfig();

  Future<UserVO> getUser() async{
    String str = await _mainConfig.getSavedString(kKeyUser);
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
    _mainConfig.setSavedString(kKeyUser, item.toString());
  }

  void clearUser() {
    _mainConfig.clearSetting(kKeyUser);
  }
}
