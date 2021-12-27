import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AssignedExercisesModel {
  final String exerciseID;
  final int numberOfTimes;
  final int numberOfSets;
  AssignedExercisesModel({
    @required this.exerciseID,
    @required this.numberOfTimes,
    @required this.numberOfSets,
  });

  AssignedExercisesModel copyWith({
    String exerciseID,
    int numberOfTimes,
    int numberOfSets,
  }) {
    return AssignedExercisesModel(
      exerciseID: exerciseID ?? this.exerciseID,
      numberOfTimes: numberOfTimes ?? this.numberOfTimes,
      numberOfSets: numberOfSets ?? this.numberOfSets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseID': exerciseID,
      'numberOfTimes': numberOfTimes,
      'numberOfSets': numberOfSets,
    };
  }

  factory AssignedExercisesModel.fromMap(Map<String, dynamic> map) {
    return AssignedExercisesModel(
      exerciseID: map['exerciseID'],
      numberOfTimes: map['numberOfTimes'],
      numberOfSets: map['numberOfSets'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignedExercisesModel.fromJson(String source) =>
      AssignedExercisesModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'AssignedExercisesModel(exerciseID: $exerciseID, numberOfTimes: $numberOfTimes, numberOfSets: $numberOfSets)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignedExercisesModel &&
        other.exerciseID == exerciseID &&
        other.numberOfTimes == numberOfTimes &&
        other.numberOfSets == numberOfSets;
  }

  @override
  int get hashCode =>
      exerciseID.hashCode ^ numberOfTimes.hashCode ^ numberOfSets.hashCode;
}
