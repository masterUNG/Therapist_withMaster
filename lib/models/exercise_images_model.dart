import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExerciseImagesModel {
  final String exerciseImage;
  final Timestamp exerciseDate;
  ExerciseImagesModel({
    @required this.exerciseImage,
    @required this.exerciseDate,
  });

  ExerciseImagesModel copyWith({
    String exerciseImage,
    Timestamp exerciseDate,
  }) {
    return ExerciseImagesModel(
      exerciseImage: exerciseImage ?? this.exerciseImage,
      exerciseDate: exerciseDate ?? this.exerciseDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseImage': exerciseImage,
      'exerciseDate': exerciseDate,
    };
  }

  factory ExerciseImagesModel.fromMap(Map<String, dynamic> map) {
    return ExerciseImagesModel(
      exerciseImage: map['exerciseImage'],
      exerciseDate: map['exerciseDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseImagesModel.fromJson(String source) =>
      ExerciseImagesModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'ExerciseImagesModel(exerciseImage: $exerciseImage, exerciseDate: $exerciseDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseImagesModel &&
        other.exerciseImage == exerciseImage &&
        other.exerciseDate == exerciseDate;
  }

  @override
  int get hashCode => exerciseImage.hashCode ^ exerciseDate.hashCode;
}
