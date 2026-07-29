// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pingadinga/models/list_item_model.dart';

const _kFileVersion = 2;

class ProjectFileModel {
  final int fileVersion;
  final List<ListItemModel> listItems;

  ProjectFileModel({required this.listItems, this.fileVersion = _kFileVersion});

  ProjectFileModel copyWith({List<ListItemModel>? listItems}) {
    return ProjectFileModel(listItems: listItems ?? this.listItems);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileVersion': fileVersion,
      'items': listItems.map((x) => x.toMap()).toList(),
    };
  }

  factory ProjectFileModel.fromMap(Map<String, dynamic> map) {
    final assertedFileVersion =
        map['fileVersion'] ??
        1; // Assert the fileVersion property to 1 if it doesn't exist.

    return ProjectFileModel(
      fileVersion: assertedFileVersion,
      listItems: List<ListItemModel>.from(
        (map['items'] ?? map['devices']).map<ListItemModel>(
          (x) => ListItemModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectFileModel.fromJson(String source) =>
      ProjectFileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static ProjectFileValidationResult validate(String source) {
    try {
      final map = json.decode(source) as Map<String, dynamic>;

      final fileVersion = map['fileVersion'] ?? 1;

      if (_kFileVersion < fileVersion) {
        return ProjectFileValidationResult(
          valid: false,
          error:
              'File open aborted. This file was created with a newer version of Pingadinga.',
        );
      }
    } catch (e) {
      return ProjectFileValidationResult(
        valid: false,
        error: 'File failed validation: ${e.toString()}',
      );
    }

    return ProjectFileValidationResult(valid: true);
  }
}

class ProjectFileValidationResult {
  final bool valid;
  final String error;

  ProjectFileValidationResult({required this.valid, this.error = ''});
}
