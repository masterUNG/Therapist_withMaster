import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'exercises_in_assigned_exercises_list_model.dart';

class AssignedExercisesListWithExercisesModel {
  final String assignedExercisesListID;
  final String disease;
  final List<ExercisesInAssignedExercisesListModel> exercisesInAssignedExercisesListModel;
  final String exerciseFrequency;
  final Timestamp startDate;
  final Timestamp finishDate;
  final Timestamp createdAt;
  final Timestamp canceledAt;
  AssignedExercisesListWithExercisesModel({
    @required this.assignedExercisesListID,
    @required this.disease,
    @required this.exercisesInAssignedExercisesListModel,
    @required this.exerciseFrequency,
    @required this.startDate,
    @required this.finishDate,
    @required this.createdAt,
    @required this.canceledAt,
  });

  AssignedExercisesListWithExercisesModel copyWith({
    String assignedExercisesListID,
    String disease,
    List<ExercisesInAssignedExercisesListModel> exercisesInAssignedExercisesListModel,
    String exerciseFrequency,
    Timestamp startDate,
    Timestamp finishDate,
    Timestamp createdAt,
    Timestamp canceledAt,
  }) {
    return AssignedExercisesListWithExercisesModel(
      assignedExercisesListID: assignedExercisesListID ?? this.assignedExercisesListID,
      disease: disease ?? this.disease,
      exercisesInAssignedExercisesListModel: exercisesInAssignedExercisesListModel ?? this.exercisesInAssignedExercisesListModel,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      createdAt: createdAt ?? this.createdAt,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignedExercisesListID': assignedExercisesListID,
      'disease': disease,
      'exercisesInAssignedExercisesListModel': exercisesInAssignedExercisesListModel?.map((x) => x.toMap())?.toList(),
      'exerciseFrequency': exerciseFrequency,
      'startDate': startDate,
      'finishDate': finishDate,
      'createdAt': createdAt,
      'canceledAt': canceledAt,
    };
  }

  factory AssignedExercisesListWithExercisesModel.fromMap(Map<String, dynamic> map) {
    return AssignedExercisesListWithExercisesModel(
      assignedExercisesListID: map['assignedExercisesListID'],
      disease: map['disease'],
      exercisesInAssignedExercisesListModel: List<ExercisesInAssignedExercisesListModel>.from(map['exercisesInAssignedExercisesListModel']?.map((x) => ExercisesInAssignedExercisesListModel.fromMap(x))),
      exerciseFrequency: map['exerciseFrequency'],
      startDate: map['startDate'],
      finishDate: map['finishDate'],
      createdAt: map['createdAt'],
      canceledAt: map['canceledAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignedExercisesListWithExercisesModel.fromJson(String source) => AssignedExercisesListWithExercisesModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AssignedExercisesListWithExercisesModel(assignedExercisesListID: $assignedExercisesListID, disease: $disease, exercisesInAssignedExercisesListModel: $exercisesInAssignedExercisesListModel, exerciseFrequency: $exerciseFrequency, startDate: $startDate, finishDate: $finishDate, createdAt: $createdAt, canceledAt: $canceledAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignedExercisesListWithExercisesModel &&
        other.assignedExercisesListID == assignedExercisesListID &&
        other.disease == disease &&
        listEquals(other.exercisesInAssignedExercisesListModel, exercisesInAssignedExercisesListModel) &&
        other.exerciseFrequency == exerciseFrequency &&
        other.startDate == startDate &&
        other.finishDate == finishDate &&
        other.createdAt == createdAt &&
        other.canceledAt == canceledAt;
  }

  @override
  int get hashCode {
    return assignedExercisesListID.hashCode ^
    disease.hashCode ^
    exercisesInAssignedExercisesListModel.hashCode ^
    exerciseFrequency.hashCode ^
    startDate.hashCode ^
    finishDate.hashCode ^
    createdAt.hashCode ^
    canceledAt.hashCode;
  }
}
