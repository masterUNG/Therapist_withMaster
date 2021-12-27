import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExercisesInPatientPageModel {
  final String exerciseImagePath;
  final String exerciseName;
  final int numberOfTimes;
  final int numberOfSets;
  final Timestamp createdAt;
  ExercisesInPatientPageModel({
    @required this.exerciseImagePath,
    @required this.exerciseName,
    @required this.numberOfTimes,
    @required this.numberOfSets,
    @required this.createdAt,
  });

  ExercisesInPatientPageModel copyWith({
    String exerciseImagePath,
    String exerciseName,
    int numberOfTimes,
    int numberOfSets,
    Timestamp createdAt,
  }) {
    return ExercisesInPatientPageModel(
      exerciseImagePath: exerciseImagePath ?? this.exerciseImagePath,
      exerciseName: exerciseName ?? this.exerciseName,
      numberOfTimes: numberOfTimes ?? this.numberOfTimes,
      numberOfSets: numberOfSets ?? this.numberOfSets,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseImagePath': exerciseImagePath,
      'exerciseName': exerciseName,
      'numberOfTimes': numberOfTimes,
      'numberOfSets': numberOfSets,
      'createdAt': createdAt,
    };
  }

  factory ExercisesInPatientPageModel.fromMap(Map<String, dynamic> map) {
    return ExercisesInPatientPageModel(
      exerciseImagePath: map['exerciseImagePath'],
      exerciseName: map['exerciseName'],
      numberOfTimes: map['numberOfTimes'],
      numberOfSets: map['numberOfSets'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExercisesInPatientPageModel.fromJson(String source) =>
      ExercisesInPatientPageModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExercisesInPatientPageModel(exerciseImagePath: $exerciseImagePath, exerciseName: $exerciseName, numberOfTimes: $numberOfTimes, numberOfSets: $numberOfSets, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExercisesInPatientPageModel &&
        other.exerciseImagePath == exerciseImagePath &&
        other.exerciseName == exerciseName &&
        other.numberOfTimes == numberOfTimes &&
        other.numberOfSets == numberOfSets &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return exerciseImagePath.hashCode ^
        exerciseName.hashCode ^
        numberOfTimes.hashCode ^
        numberOfSets.hashCode ^
        createdAt.hashCode;
  }
}
