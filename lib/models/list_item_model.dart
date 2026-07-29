// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum ItemType {
  device('device'),
  divider('divider');

  final String value;
  const ItemType(this.value);

  String toJson() => value;

  static ItemType fromJson(String? json) => ItemType.values.firstWhere(
    (itemType) => itemType.value == json,
    orElse: () => ItemType.device,
  );
}

sealed class ListItemModel {
  final String uid;
  final ItemType type;

  ListItemModel({required this.uid, required this.type});

  Map<String, dynamic> toMap();

  factory ListItemModel.fromMap(Map<String, dynamic> map) {
    return switch (ItemType.fromJson(map['type'])) {
      ItemType.device => DeviceModel.fromMap(map),
      ItemType.divider => DividerModel.fromMap(map),
    };
  }
}

class DeviceModel extends ListItemModel {
  final String ipAddress;
  final String name;

  DeviceModel({required super.uid, required this.ipAddress, required this.name})
    : super(type: ItemType.device);

  DeviceModel copyWith({String? uid, String? ipAddress, String? name}) {
    return DeviceModel(
      uid: uid ?? this.uid,
      ipAddress: ipAddress ?? this.ipAddress,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': super.uid,
      'type': super.type.toJson(),
      'ipAddress': ipAddress,
      'name': name,
    };
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

class DividerModel extends ListItemModel {
  final String name;
  final String description;

  DividerModel({
    required super.uid,
    required this.name,
    required this.description,
  }) : super(type: ItemType.divider);

  DividerModel copyWith({String? uid, String? name, String? description}) {
    return DividerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': super.uid,
      'type': super.type.toJson(),
      'name': name,
      'description': description,
    };
  }

  factory DividerModel.fromMap(Map<String, dynamic> map) {
    return DividerModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DividerModel.fromJson(String source) =>
      DividerModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
