import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ExercisesListModel {
  String exerciseID;
  String exerciseImage;
  String exerciseName;
  List<String> exercisePatientTypes;
  String exerciseVideoURL;
  int exerciseNumberOfTimes;
  int exerciseNumberOfSets;
  ExercisesListModel({
    @required this.exerciseID,
    @required this.exerciseImage,
    @required this.exerciseName,
    @required this.exercisePatientTypes,
    @required this.exerciseVideoURL,
    @required this.exerciseNumberOfTimes,
    @required this.exerciseNumberOfSets,
  });

  ExercisesListModel copyWith({
    String exerciseID,
    String exerciseImage,
    String exerciseName,
    List<String> exercisePatientTypes,
    String exerciseVideoURL,
    int exerciseNumberOfTimes,
    int exerciseNumberOfSets,
  }) {
    return ExercisesListModel(
      exerciseID: exerciseID ?? this.exerciseID,
      exerciseImage: exerciseImage ?? this.exerciseImage,
      exerciseName: exerciseName ?? this.exerciseName,
      exercisePatientTypes: exercisePatientTypes ?? this.exercisePatientTypes,
      exerciseVideoURL: exerciseVideoURL ?? this.exerciseVideoURL,
      exerciseNumberOfTimes:
          exerciseNumberOfTimes ?? this.exerciseNumberOfTimes,
      exerciseNumberOfSets: exerciseNumberOfSets ?? this.exerciseNumberOfSets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseID': exerciseID,
      'exerciseImage': exerciseImage,
      'exerciseName': exerciseName,
      'exercisePatientTypes': exercisePatientTypes,
      'exerciseVideoURL': exerciseVideoURL,
      'exerciseNumberOfTimes': exerciseNumberOfTimes,
      'exerciseNumberOfSets': exerciseNumberOfSets,
    };
  }

  factory ExercisesListModel.fromMap(Map<String, dynamic> map) {
    return ExercisesListModel(
      exerciseID: map['exerciseID'],
      exerciseImage: map['exerciseImage'],
      exerciseName: map['exerciseName'],
      exercisePatientTypes: List<String>.from(map['exercisePatientTypes']),
      exerciseVideoURL: map['exerciseVideoURL'],
      exerciseNumberOfTimes: map['exerciseNumberOfTimes'],
      exerciseNumberOfSets: map['exerciseNumberOfSets'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExercisesListModel.fromJson(String source) =>
      ExercisesListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExercisesListModel(exerciseID: $exerciseID, exerciseImage: $exerciseImage, exerciseName: $exerciseName, exercisePatientTypes: $exercisePatientTypes, exerciseVideoURL: $exerciseVideoURL, exerciseNumberOfTimes: $exerciseNumberOfTimes, exerciseNumberOfSets: $exerciseNumberOfSets)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExercisesListModel &&
        other.exerciseID == exerciseID &&
        other.exerciseImage == exerciseImage &&
        other.exerciseName == exerciseName &&
        listEquals(other.exercisePatientTypes, exercisePatientTypes) &&
        other.exerciseVideoURL == exerciseVideoURL &&
        other.exerciseNumberOfTimes == exerciseNumberOfTimes &&
        other.exerciseNumberOfSets == exerciseNumberOfSets;
  }

  @override
  int get hashCode {
    return exerciseID.hashCode ^
        exerciseImage.hashCode ^
        exerciseName.hashCode ^
        exercisePatientTypes.hashCode ^
        exerciseVideoURL.hashCode ^
        exerciseNumberOfTimes.hashCode ^
        exerciseNumberOfSets.hashCode;
  }
}
