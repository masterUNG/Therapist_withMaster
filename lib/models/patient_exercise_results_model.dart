import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PatientExerciseResults {
  final String treatmentID;
  final String patientProfileImage;
  final String patientFirstName;
  final String patientLastName;
  final int exerciseNumberOfWeeks;
  final DateTime exerciseFirstDate;
  final DateTime exerciseLastDate;
  final List<String> exerciseImages;
  final int completionPercentage;
  PatientExerciseResults({
    @required this.treatmentID,
    @required this.patientProfileImage,
    @required this.patientFirstName,
    @required this.patientLastName,
    @required this.exerciseNumberOfWeeks,
    @required this.exerciseFirstDate,
    @required this.exerciseLastDate,
    @required this.exerciseImages,
    @required this.completionPercentage,
  });

  PatientExerciseResults copyWith({
    String treatmentID,
    String patientProfileImage,
    String patientFirstName,
    String patientLastName,
    int exerciseNumberOfWeeks,
    DateTime exerciseFirstDate,
    DateTime exerciseLastDate,
    List<String> exerciseImages,
    int completionPercentage,
  }) {
    return PatientExerciseResults(
      treatmentID: treatmentID ?? this.treatmentID,
      patientProfileImage: patientProfileImage ?? this.patientProfileImage,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientLastName: patientLastName ?? this.patientLastName,
      exerciseNumberOfWeeks:
          exerciseNumberOfWeeks ?? this.exerciseNumberOfWeeks,
      exerciseFirstDate: exerciseFirstDate ?? this.exerciseFirstDate,
      exerciseLastDate: exerciseLastDate ?? this.exerciseLastDate,
      exerciseImages: exerciseImages ?? this.exerciseImages,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treatmentID': treatmentID,
      'patientProfileImage': patientProfileImage,
      'patientFirstName': patientFirstName,
      'patientLastName': patientLastName,
      'exerciseNumberOfWeeks': exerciseNumberOfWeeks,
      'exerciseFirstDate': exerciseFirstDate.millisecondsSinceEpoch,
      'exerciseLastDate': exerciseLastDate.millisecondsSinceEpoch,
      'exerciseImages': exerciseImages,
      'completionPercentage': completionPercentage,
    };
  }

  factory PatientExerciseResults.fromMap(Map<String, dynamic> map) {
    return PatientExerciseResults(
      treatmentID: map['treatmentID'],
      patientProfileImage: map['patientProfileImage'],
      patientFirstName: map['patientFirstName'],
      patientLastName: map['patientLastName'],
      exerciseNumberOfWeeks: map['exerciseNumberOfWeeks'],
      exerciseFirstDate:
          DateTime.fromMillisecondsSinceEpoch(map['exerciseFirstDate']),
      exerciseLastDate:
          DateTime.fromMillisecondsSinceEpoch(map['exerciseLastDate']),
      exerciseImages: List<String>.from(map['exerciseImages']),
      completionPercentage: map['completionPercentage'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientExerciseResults.fromJson(String source) =>
      PatientExerciseResults.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientExerciseResults(treatmentID: $treatmentID, patientProfileImage: $patientProfileImage, patientFirstName: $patientFirstName, patientLastName: $patientLastName, exerciseNumberOfWeeks: $exerciseNumberOfWeeks, exerciseFirstDate: $exerciseFirstDate, exerciseLastDate: $exerciseLastDate, exerciseImages: $exerciseImages, completionPercentage: $completionPercentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientExerciseResults &&
        other.treatmentID == treatmentID &&
        other.patientProfileImage == patientProfileImage &&
        other.patientFirstName == patientFirstName &&
        other.patientLastName == patientLastName &&
        other.exerciseNumberOfWeeks == exerciseNumberOfWeeks &&
        other.exerciseFirstDate == exerciseFirstDate &&
        other.exerciseLastDate == exerciseLastDate &&
        listEquals(other.exerciseImages, exerciseImages) &&
        other.completionPercentage == completionPercentage;
  }

  @override
  int get hashCode {
    return treatmentID.hashCode ^
        patientProfileImage.hashCode ^
        patientFirstName.hashCode ^
        patientLastName.hashCode ^
        exerciseNumberOfWeeks.hashCode ^
        exerciseFirstDate.hashCode ^
        exerciseLastDate.hashCode ^
        exerciseImages.hashCode ^
        completionPercentage.hashCode;
  }
}
