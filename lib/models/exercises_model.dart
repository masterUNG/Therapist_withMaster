import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExercisesModel {
  final String name;
  final String imagePath;
  final String videoURL;
  final List<String> patientTypes;
  final String instruction;
  ExercisesModel({
    @required this.name,
    @required this.imagePath,
    @required this.videoURL,
    @required this.patientTypes,
    @required this.instruction,
  });

  ExercisesModel copyWith({
    String name,
    String imagePath,
    String videoURL,
    List<String> patientTypes,
    String instruction,
  }) {
    return ExercisesModel(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      videoURL: videoURL ?? this.videoURL,
      patientTypes: patientTypes ?? this.patientTypes,
      instruction: instruction ?? this.instruction,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'videoURL': videoURL,
      'patientTypes': patientTypes,
      'instruction': instruction,
    };
  }

  factory ExercisesModel.fromMap(Map<String, dynamic> map) {
    return ExercisesModel(
      name: map['name'],
      imagePath: map['imagePath'],
      videoURL: map['videoURL'],
      patientTypes: List<String>.from(map['patientTypes']),
      instruction: map['instruction'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExercisesModel.fromJson(String source) =>
      ExercisesModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExercisesModel(name: $name, imagePath: $imagePath, videoURL: $videoURL, patientTypes: $patientTypes, instruction: $instruction)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExercisesModel &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.videoURL == videoURL &&
        listEquals(other.patientTypes, patientTypes) &&
        other.instruction == instruction;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        imagePath.hashCode ^
        videoURL.hashCode ^
        patientTypes.hashCode ^
        instruction.hashCode;
  }
}
