import 'dart:convert';

class ImageVO {
  String path = '';
  int type = 0;

  ImageVO({
    this.path,
    this.type,
  });

  factory ImageVO.fromJson(Map<String, dynamic> json) {
    return ImageVO(
      path: json.containsKey('path') ? json['path'] as String ?? "" : "",
      type: json.containsKey('type') ? json['type'] as int ?? 0 : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path ?? "",
    'type': type ?? 0,
  };

  @override
  String toString() {
    var jsonData = json.encode(toJson());
    return jsonData;
  }
}
