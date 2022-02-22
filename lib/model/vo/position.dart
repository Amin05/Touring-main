import 'dart:convert';

class PositionVO {
  int lastTime;
  int currentTime;
  double currentLatitude;
  double currentLongitude;
  double lastLatitude;
  double lastLongitude;
  double distanceDestination;
  double speed;

  PositionVO({
    this.lastTime,
    this.currentTime,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLatitude,
    this.lastLongitude,
    this.distanceDestination,
    this.speed,
  });

  factory PositionVO.fromJson(Map<String, dynamic> json) {
    return PositionVO(
      lastTime: json.containsKey('lastTime') ? json['lastTime'] : 0,
      lastLatitude: json.containsKey('lastLatitude') ? json['lastLatitude'] : 0.0,
      lastLongitude: json.containsKey('lastLongitude') ? json['lastLongitude'] : 0.0,
      currentTime: json.containsKey('currentTime') ? json['currentTime'] : 0,
      currentLatitude: json.containsKey('currentLatitude') ? json['currentLatitude'] : 0.0,
      currentLongitude: json.containsKey('currentLongitude') ? json['currentLongitude'] : 0.0,
      distanceDestination: json.containsKey('distanceDestination') ? json['distanceDestination'] : 0.0,
      speed: json.containsKey('speed') ? json['speed'] : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'lastTime': lastTime ?? 0,
    'lastLatitude': lastLatitude ?? 0.0,
    'lastLongitude': lastLongitude ?? 0.0,
    'currentTime': currentTime ?? 0,
    'currentLatitude': currentLatitude ?? 0.0,
    'currentLongitude': currentLongitude ?? 0.0,
    'distanceDestination': distanceDestination ?? 0.0,
    'speed': speed ?? 0.0,
  };

  @override
  String toString() {
    var jsonData = json.encode(toJson());
    return jsonData;
  }
}
