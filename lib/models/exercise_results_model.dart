import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExerciseResultsModel {
  final String exerciseID;
  final String exerciseImage;
  final String exerciseName;
  final int numberOfTimes;
  final bool isCompleted;
  final Timestamp completionDate;
  ExerciseResultsModel({
    @required this.exerciseID,
    @required this.exerciseImage,
    @required this.exerciseName,
    @required this.numberOfTimes,
    @required this.isCompleted,
    @required this.completionDate,
  });

  ExerciseResultsModel copyWith({
    String exerciseID,
    String exerciseImage,
    String exerciseName,
    int numberOfTimes,
    bool isCompleted,
    Timestamp completionDate,
  }) {
    return ExerciseResultsModel(
      exerciseID: exerciseID ?? this.exerciseID,
      exerciseImage: exerciseImage ?? this.exerciseImage,
      exerciseName: exerciseName ?? this.exerciseName,
      numberOfTimes: numberOfTimes ?? this.numberOfTimes,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseID': exerciseID,
      'exerciseImage': exerciseImage,
      'exerciseName': exerciseName,
      'numberOfTimes': numberOfTimes,
      'isCompleted': isCompleted,
      'completionDate': completionDate,
    };
  }

  factory ExerciseResultsModel.fromMap(Map<String, dynamic> map) {
    return ExerciseResultsModel(
      exerciseID: map['exerciseID'],
      exerciseImage: map['exerciseImage'],
      exerciseName: map['exerciseName'],
      numberOfTimes: map['numberOfTimes'],
      isCompleted: map['isCompleted'],
      completionDate: map['completionDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseResultsModel.fromJson(String source) =>
      ExerciseResultsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExerciseResultsModel(exerciseID: $exerciseID, exerciseImage: $exerciseImage, exerciseName: $exerciseName, numberOfTimes: $numberOfTimes, isCompleted: $isCompleted, completionDate: $completionDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseResultsModel &&
        other.exerciseID == exerciseID &&
        other.exerciseImage == exerciseImage &&
        other.exerciseName == exerciseName &&
        other.numberOfTimes == numberOfTimes &&
        other.isCompleted == isCompleted &&
        other.completionDate == completionDate;
  }

  @override
  int get hashCode {
    return exerciseID.hashCode ^
        exerciseImage.hashCode ^
        exerciseName.hashCode ^
        numberOfTimes.hashCode ^
        isCompleted.hashCode ^
        completionDate.hashCode;
  }
}
