// models/device.dart

class Device {
  final String id;
  final String name;
  final String url;

  Device({
    required this.id,
    required this.name,
    required this.url,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'],
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'url': url,
    };
  }
}