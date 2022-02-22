import 'dart:convert';

class UserVO {
  String uid;
  String tid;
  String name;
  String email;
  String status;
  String image;

  UserVO({
    this.tid,
    this.uid,
    this.name,
    this.email,
    this.status,
    this.image,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) {
    return UserVO(
      uid: json.containsKey('uid') ? json['uid'].toString() : '',
      tid: json.containsKey('tid') ? json['tid'].toString() : '',
      name: json.containsKey('name') ? json['name'].toString() : '',
      email: json.containsKey('email') ? json['email'].toString() : '',
      image: json.containsKey('image') ? json['image'].toString() : '',
      status: json.containsKey('status') ? json['status'].toString() : '0',
    );
  }

  Map<String, dynamic> toJson() => {
    'tid': tid ?? '',
    'uid': uid ?? '',
    'name': name ?? '',
    'email': email ?? '',
    'status': status ?? '',
    'image': image ?? '',
  };

  @override
  String toString() {
    var jsonData = json.encode(toJson());
    return jsonData;
  }
}
