import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExerciseIDsModel {
  final String exerciseID;
  final Timestamp exerciseDate;
  ExerciseIDsModel({
    @required this.exerciseID,
    @required this.exerciseDate,
  });

  ExerciseIDsModel copyWith({
    String exerciseID,
    Timestamp exerciseDate,
  }) {
    return ExerciseIDsModel(
      exerciseID: exerciseID ?? this.exerciseID,
      exerciseDate: exerciseDate ?? this.exerciseDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseID': exerciseID,
      'exerciseDate': exerciseDate,
    };
  }

  factory ExerciseIDsModel.fromMap(Map<String, dynamic> map) {
    return ExerciseIDsModel(
      exerciseID: map['exerciseID'],
      exerciseDate: map['exerciseDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseIDsModel.fromJson(String source) =>
      ExerciseIDsModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'ExerciseIDsModel(exerciseID: $exerciseID, exerciseDate: $exerciseDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseIDsModel &&
        other.exerciseID == exerciseID &&
        other.exerciseDate == exerciseDate;
  }

  @override
  int get hashCode => exerciseID.hashCode ^ exerciseDate.hashCode;
}
