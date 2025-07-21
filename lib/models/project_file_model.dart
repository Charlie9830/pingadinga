// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pingadinga/models/device_model.dart';

class ProjectFileModel {
  final int fileVersion = 1;
  final List<DeviceModel> devices;

  ProjectFileModel({required this.devices});

  ProjectFileModel copyWith({List<DeviceModel>? devices}) {
    return ProjectFileModel(devices: devices ?? this.devices);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'devices': devices.map((x) => x.toMap()).toList()};
  }

  factory ProjectFileModel.fromMap(Map<String, dynamic> map) {
    return ProjectFileModel(
      devices: List<DeviceModel>.from(
        (map['devices']).map<DeviceModel>(
          (x) => DeviceModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectFileModel.fromJson(String source) =>
      ProjectFileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
