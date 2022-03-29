import 'dart:convert';

class BroadcastVO {
  String id;
  String name;
  String message;
  int created;
  double latitude;
  double longitude;

  BroadcastVO({
    this.id,
    this.name,
    this.message,
    this.created,
    this.latitude,
    this.longitude,
  });

  factory BroadcastVO.fromJson(Map<String, dynamic> json) {
    return BroadcastVO(
      id: json.containsKey('id') ? json['id'].toString() : '',
      name: json.containsKey('name') ? json['name'].toString() : '',
      message: json.containsKey('message') ? json['message'].toString() : '',
      created: json.containsKey('created') ? json['created'] : 0,
      latitude: json.containsKey('latitude') ? json['latitude'] : 0.0,
      longitude: json.containsKey('longitude') ? json['longitude'] : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id ?? '',
    'name': name ?? '',
    'message': message ?? '',
    'created': created ?? 0,
    'latitude': latitude ?? 0.0,
    'longitude': longitude ?? 0.0,
  };

  @override
  String toString() {
    var jsonData = json.encode(toJson());
    return jsonData;
  }
}
