import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExercisesInAssignedExercisesListModel {
  final String exerciseID;
  final String exerciseName;
  final String exerciseImagePath;
  final int numberOfTimes;
  final int numberOfSets;
  ExercisesInAssignedExercisesListModel({
    @required this.exerciseID,
    @required this.exerciseName,
    @required this.exerciseImagePath,
    @required this.numberOfTimes,
    @required this.numberOfSets,
  });

  ExercisesInAssignedExercisesListModel copyWith({
    String exerciseID,
    String exerciseName,
    String exerciseImagePath,
    int numberOfTimes,
    int numberOfSets,
  }) {
    return ExercisesInAssignedExercisesListModel(
      exerciseID: exerciseID ?? this.exerciseID,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImagePath: exerciseImagePath ?? this.exerciseImagePath,
      numberOfTimes: numberOfTimes ?? this.numberOfTimes,
      numberOfSets: numberOfSets ?? this.numberOfSets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseID': exerciseID,
      'exerciseName': exerciseName,
      'exerciseImagePath': exerciseImagePath,
      'numberOfTimes': numberOfTimes,
      'numberOfSets': numberOfSets,
    };
  }

  factory ExercisesInAssignedExercisesListModel.fromMap(Map<String, dynamic> map) {
    return ExercisesInAssignedExercisesListModel(
      exerciseID: map['exerciseID'],
      exerciseName: map['exerciseName'],
      exerciseImagePath: map['exerciseImagePath'],
      numberOfTimes: map['numberOfTimes'],
      numberOfSets: map['numberOfSets'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExercisesInAssignedExercisesListModel.fromJson(String source) => ExercisesInAssignedExercisesListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExercisesInAssignedExercisesListModel(exerciseID: $exerciseID, exerciseName: $exerciseName, exerciseImagePath: $exerciseImagePath, numberOfTimes: $numberOfTimes, numberOfSets: $numberOfSets)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExercisesInAssignedExercisesListModel &&
        other.exerciseID == exerciseID &&
        other.exerciseName == exerciseName &&
        other.exerciseImagePath == exerciseImagePath &&
        other.numberOfTimes == numberOfTimes &&
        other.numberOfSets == numberOfSets;
  }

  @override
  int get hashCode {
    return exerciseID.hashCode ^
    exerciseName.hashCode ^
    exerciseImagePath.hashCode ^
    numberOfTimes.hashCode ^
    numberOfSets.hashCode;
  }
}
