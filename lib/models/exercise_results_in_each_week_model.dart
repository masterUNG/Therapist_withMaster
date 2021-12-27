import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'exercise_images_model.dart';

class ExerciseResultsInEachWeekModel {
  final int weekNumber;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<ExerciseImagesModel> exerciseImagesModel;
  final int completionPercentage;
  ExerciseResultsInEachWeekModel({
    @required this.weekNumber,
    @required this.firstDate,
    @required this.lastDate,
    @required this.exerciseImagesModel,
    @required this.completionPercentage,
  });

  ExerciseResultsInEachWeekModel copyWith({
    int weekNumber,
    DateTime firstDate,
    DateTime lastDate,
    List<ExerciseImagesModel> exerciseImagesModel,
    int completionPercentage,
  }) {
    return ExerciseResultsInEachWeekModel(
      weekNumber: weekNumber ?? this.weekNumber,
      firstDate: firstDate ?? this.firstDate,
      lastDate: lastDate ?? this.lastDate,
      exerciseImagesModel: exerciseImagesModel ?? this.exerciseImagesModel,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'firstDate': firstDate.millisecondsSinceEpoch,
      'lastDate': lastDate.millisecondsSinceEpoch,
      'exerciseImagesModel':
          exerciseImagesModel?.map((x) => x.toMap())?.toList(),
      'completionPercentage': completionPercentage,
    };
  }

  factory ExerciseResultsInEachWeekModel.fromMap(Map<String, dynamic> map) {
    return ExerciseResultsInEachWeekModel(
      weekNumber: map['weekNumber'],
      firstDate: DateTime.fromMillisecondsSinceEpoch(map['firstDate']),
      lastDate: DateTime.fromMillisecondsSinceEpoch(map['lastDate']),
      exerciseImagesModel: List<ExerciseImagesModel>.from(
          map['exerciseImagesModel']
              ?.map((x) => ExerciseImagesModel.fromMap(x))),
      completionPercentage: map['completionPercentage'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseResultsInEachWeekModel.fromJson(String source) =>
      ExerciseResultsInEachWeekModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExerciseResultsInEachWeekModel(weekNumber: $weekNumber, firstDate: $firstDate, lastDate: $lastDate, exerciseImagesModel: $exerciseImagesModel, completionPercentage: $completionPercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseResultsInEachWeekModel &&
        other.weekNumber == weekNumber &&
        other.firstDate == firstDate &&
        other.lastDate == lastDate &&
        listEquals(other.exerciseImagesModel, exerciseImagesModel) &&
        other.completionPercentage == completionPercentage;
  }

  @override
  int get hashCode {
    return weekNumber.hashCode ^
        firstDate.hashCode ^
        lastDate.hashCode ^
        exerciseImagesModel.hashCode ^
        completionPercentage.hashCode;
  }
}
