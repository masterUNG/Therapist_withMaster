import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PreviousTreatmentsModel {
  final String treatmentID;
  final String patientProfileImage;
  final String patientFirstName;
  final String patientLastName;
  final List<String> patientDiseases;
  final Timestamp treatmentStartDate;
  final Timestamp treatmentFinishDate;
  final String finishStatus;
  PreviousTreatmentsModel({
    @required this.treatmentID,
    @required this.patientProfileImage,
    @required this.patientFirstName,
    @required this.patientLastName,
    @required this.patientDiseases,
    @required this.treatmentStartDate,
    @required this.treatmentFinishDate,
    @required this.finishStatus,
  });

  PreviousTreatmentsModel copyWith({
    String treatmentID,
    String patientProfileImage,
    String patientFirstName,
    String patientLastName,
    List<String> patientDiseases,
    Timestamp treatmentStartDate,
    Timestamp treatmentFinishDate,
    String finishStatus,
  }) {
    return PreviousTreatmentsModel(
      treatmentID: treatmentID ?? this.treatmentID,
      patientProfileImage: patientProfileImage ?? this.patientProfileImage,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientLastName: patientLastName ?? this.patientLastName,
      patientDiseases: patientDiseases ?? this.patientDiseases,
      treatmentStartDate: treatmentStartDate ?? this.treatmentStartDate,
      treatmentFinishDate: treatmentFinishDate ?? this.treatmentFinishDate,
      finishStatus: finishStatus ?? this.finishStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treatmentID': treatmentID,
      'patientProfileImage': patientProfileImage,
      'patientFirstName': patientFirstName,
      'patientLastName': patientLastName,
      'patientDiseases': patientDiseases,
      'treatmentStartDate': treatmentStartDate,
      'treatmentFinishDate': treatmentFinishDate,
      'finishStatus': finishStatus,
    };
  }

  factory PreviousTreatmentsModel.fromMap(Map<String, dynamic> map) {
    return PreviousTreatmentsModel(
      treatmentID: map['treatmentID'],
      patientProfileImage: map['patientProfileImage'],
      patientFirstName: map['patientFirstName'],
      patientLastName: map['patientLastName'],
      patientDiseases: List<String>.from(map['patientDiseases']),
      treatmentStartDate: map['treatmentStartDate'],
      treatmentFinishDate: map['treatmentFinishDate'],
      finishStatus: map['finishStatus'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PreviousTreatmentsModel.fromJson(String source) =>
      PreviousTreatmentsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PreviousTreatmentsModel(treatmentID: $treatmentID, patientProfileImage: $patientProfileImage, patientFirstName: $patientFirstName, patientLastName: $patientLastName, patientDiseases: $patientDiseases, treatmentStartDate: $treatmentStartDate, treatmentFinishDate: $treatmentFinishDate, finishStatus: $finishStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PreviousTreatmentsModel &&
        other.treatmentID == treatmentID &&
        other.patientProfileImage == patientProfileImage &&
        other.patientFirstName == patientFirstName &&
        other.patientLastName == patientLastName &&
        listEquals(other.patientDiseases, patientDiseases) &&
        other.treatmentStartDate == treatmentStartDate &&
        other.treatmentFinishDate == treatmentFinishDate &&
        other.finishStatus == finishStatus;
  }

  @override
  int get hashCode {
    return treatmentID.hashCode ^
        patientProfileImage.hashCode ^
        patientFirstName.hashCode ^
        patientLastName.hashCode ^
        patientDiseases.hashCode ^
        treatmentStartDate.hashCode ^
        treatmentFinishDate.hashCode ^
        finishStatus.hashCode;
  }
}
