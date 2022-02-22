import 'dart:convert';

class GroupVO {
  String code;
  String name;
  int created;
  String image;
  String creator;
  int type;
  String location;
  double latitude;
  double longitude;

  GroupVO({
    this.code,
    this.name,
    this.type,
    this.creator,
    this.created,
    this.image,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory GroupVO.fromJson(Map<String, dynamic> json) {
    return GroupVO(
      code: json.containsKey('code') ? json['code'].toString() : '',
      name: json.containsKey('name') ? json['name'].toString() : '',
      type: json.containsKey('type') ? json['type'] : 0,
      created: json.containsKey('created') ? json['created'] : 0,
      creator: json.containsKey('creator') ? json['creator'].toString() : '',
      image: json.containsKey('image') ? json['image'].toString() : '',
      location: json.containsKey('location') ? json['location'].toString() : '',
      latitude: json.containsKey('latitude') ? json['latitude'] : 0.0,
      longitude: json.containsKey('longitude') ? json['longitude'] : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code ?? '',
    'name': name ?? '',
    'type': type ?? 0,
    'creator': creator ?? '',
    'created': created ?? 0,
    'image': image ?? '',
    'location': location ?? '',
    'latitude': latitude ?? 0.0,
    'longitude': longitude ?? 0.0,
  };

  @override
  String toString() {
    var jsonData = json.encode(toJson());
    return jsonData;
  }
}
