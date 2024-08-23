// models/system.dart

import 'device.dart';

class System {
  final String id;
  final String name;
  final List<Device> devices;

  System({
    required this.id,
    required this.name,
    required this.devices,
  });

  factory System.fromJson(Map<String, dynamic> json) {
    var deviceList = json['devices'] as List;
    List<Device> devices = deviceList.map((i) => Device.fromJson(i)).toList();

    return System(
      id: json['_id'],
      name: json['name'],
      devices: devices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }
}