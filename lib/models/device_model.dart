import 'dart:convert';

class DeviceModel {
  final String uid;
  final String ipAddress;
  final String name;

  DeviceModel({required this.uid, required this.ipAddress, required this.name});

  DeviceModel copyWith({String? uid, String? ipAddress, String? name}) {
    return DeviceModel(
      uid: uid ?? this.uid,
      ipAddress: ipAddress ?? this.ipAddress,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'uid': uid, 'ipAddress': ipAddress, 'name': name};
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      uid: (map['uid'] ?? '') as String,
      ipAddress: (map['ipAddress'] ?? '') as String,
      name: (map['name'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceModel.fromJson(String source) =>
      DeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
