import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AssignedExercisesListModel {
  final String disease;
  final String exerciseFrequency;
  final Timestamp startDate;
  final Timestamp finishDate;
  final Timestamp createdAt;
  final Timestamp lastUpdate;
  final Timestamp canceledAt;
  AssignedExercisesListModel({
    @required this.disease,
    @required this.exerciseFrequency,
    @required this.startDate,
    @required this.finishDate,
    @required this.createdAt,
    @required this.lastUpdate,
    @required this.canceledAt,
  });

  AssignedExercisesListModel copyWith({
    String disease,
    String exerciseFrequency,
    Timestamp startDate,
    Timestamp finishDate,
    Timestamp createdAt,
    Timestamp lastUpdate,
    Timestamp canceledAt,
  }) {
    return AssignedExercisesListModel(
      disease: disease ?? this.disease,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'exerciseFrequency': exerciseFrequency,
      'startDate': startDate,
      'finishDate': finishDate,
      'createdAt': createdAt,
      'lastUpdate': lastUpdate,
      'canceledAt': canceledAt,
    };
  }

  factory AssignedExercisesListModel.fromMap(Map<String, dynamic> map) {
    return AssignedExercisesListModel(
      disease: map['disease'],
      exerciseFrequency: map['exerciseFrequency'],
      startDate: map['startDate'],
      finishDate: map['finishDate'],
      createdAt: map['createdAt'],
      lastUpdate: map['lastUpdate'],
      canceledAt: map['canceledAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignedExercisesListModel.fromJson(String source) =>
      AssignedExercisesListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AssignedExercisesListModel(disease: $disease, exerciseFrequency: $exerciseFrequency, startDate: $startDate, finishDate: $finishDate, createdAt: $createdAt, lastUpdate: $lastUpdate, canceledAt: $canceledAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignedExercisesListModel &&
        other.disease == disease &&
        other.exerciseFrequency == exerciseFrequency &&
        other.startDate == startDate &&
        other.finishDate == finishDate &&
        other.createdAt == createdAt &&
        other.lastUpdate == lastUpdate &&
        other.canceledAt == canceledAt;
  }

  @override
  int get hashCode {
    return disease.hashCode ^
        exerciseFrequency.hashCode ^
        startDate.hashCode ^
        finishDate.hashCode ^
        createdAt.hashCode ^
        lastUpdate.hashCode ^
        canceledAt.hashCode;
  }
}
