import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:therapist_buddy/models/exercise_results_model.dart';

class ExerciseResultsInADayModel {
  final DateTime date;
  final List<ExerciseResultsModel> exerciseResultsModel;
  ExerciseResultsInADayModel({
    @required this.date,
    @required this.exerciseResultsModel,
  });

  ExerciseResultsInADayModel copyWith({
    DateTime date,
    List<ExerciseResultsModel> exerciseResultsModel,
  }) {
    return ExerciseResultsInADayModel(
      date: date ?? this.date,
      exerciseResultsModel: exerciseResultsModel ?? this.exerciseResultsModel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'exerciseResultsModel':
          exerciseResultsModel?.map((x) => x.toMap())?.toList(),
    };
  }

  factory ExerciseResultsInADayModel.fromMap(Map<String, dynamic> map) {
    return ExerciseResultsInADayModel(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      exerciseResultsModel: List<ExerciseResultsModel>.from(
          map['exerciseResultsModel']
              ?.map((x) => ExerciseResultsModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseResultsInADayModel.fromJson(String source) =>
      ExerciseResultsInADayModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'ExerciseResultsInADayModel(date: $date, exerciseResultsModel: $exerciseResultsModel)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseResultsInADayModel &&
        other.date == date &&
        listEquals(other.exerciseResultsModel, exerciseResultsModel);
  }

  @override
  int get hashCode => date.hashCode ^ exerciseResultsModel.hashCode;
}
