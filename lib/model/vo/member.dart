import 'dart:convert';

class MemberVO {
  String id;
  String name;
  double latitude;
  double longitude;
  double currentLatitude;
  double currentLongitude;
  double lastLatitude;
  double lastLongitude;
  double distanceMember;
  double distanceDestination;
  double speed;

  MemberVO({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLatitude,
    this.lastLongitude,
    this.distanceMember,
    this.distanceDestination,
    this.speed,
  });

  factory MemberVO.fromJson(Map<String, dynamic> json) {
    return MemberVO(
      id: json.containsKey('id') ? json['id'].toString() : '',
      latitude: json.containsKey('latitude') ? json['latitude'] : 0.0,
      longitude: json.containsKey('longitude') ? json['longitude'] : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id ?? '',
    'latitude': latitude ?? 0.0,
    'longitude': longitude ?? 0.0,
  };

  @override
  String toString() {
    var jsonData = json.encode(toJson());
    return jsonData;
  }

}
