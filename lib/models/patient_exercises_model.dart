import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PatientExercisesModel {
  final String assignedExercisesListID;
  final String exerciseID;
  final int numberOfTimes;
  final Timestamp date;
  final bool isCompleted;
  final Timestamp completionDate;
  PatientExercisesModel({
    @required this.assignedExercisesListID,
    @required this.exerciseID,
    @required this.numberOfTimes,
    @required this.date,
    @required this.isCompleted,
    @required this.completionDate,
  });

  PatientExercisesModel copyWith({
    String assignedExercisesListID,
    String exerciseID,
    int numberOfTimes,
    Timestamp date,
    bool isCompleted,
    Timestamp completionDate,
  }) {
    return PatientExercisesModel(
      assignedExercisesListID:
          assignedExercisesListID ?? this.assignedExercisesListID,
      exerciseID: exerciseID ?? this.exerciseID,
      numberOfTimes: numberOfTimes ?? this.numberOfTimes,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignedExercisesListID': assignedExercisesListID,
      'exerciseID': exerciseID,
      'numberOfTimes': numberOfTimes,
      'date': date,
      'isCompleted': isCompleted,
      'completionDate': completionDate,
    };
  }

  factory PatientExercisesModel.fromMap(Map<String, dynamic> map) {
    return PatientExercisesModel(
      assignedExercisesListID: map['assignedExercisesListID'],
      exerciseID: map['exerciseID'],
      numberOfTimes: map['numberOfTimes'],
      date: map['date'],
      isCompleted: map['isCompleted'],
      completionDate: map['completionDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientExercisesModel.fromJson(String source) =>
      PatientExercisesModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientExercisesModel(assignedExercisesListID: $assignedExercisesListID, exerciseID: $exerciseID, numberOfTimes: $numberOfTimes, date: $date, isCompleted: $isCompleted, completionDate: $completionDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientExercisesModel &&
        other.assignedExercisesListID == assignedExercisesListID &&
        other.exerciseID == exerciseID &&
        other.numberOfTimes == numberOfTimes &&
        other.date == date &&
        other.isCompleted == isCompleted &&
        other.completionDate == completionDate;
  }

  @override
  int get hashCode {
    return assignedExercisesListID.hashCode ^
        exerciseID.hashCode ^
        numberOfTimes.hashCode ^
        date.hashCode ^
        isCompleted.hashCode ^
        completionDate.hashCode;
  }
}
