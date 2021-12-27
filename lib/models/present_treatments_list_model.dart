import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PresentTreatmentsListModel {
  final String treatmentID;
  final String patientID;
  final String patientUserID;
  final String patientUserProfileImage;
  final String patientUserFirstName;
  final String patientUserLastName;
  final String diseases;
  final Timestamp appointmentDate;
  final Timestamp treatmentStartDate;
  PresentTreatmentsListModel({
    @required this.treatmentID,
    @required this.patientID,
    @required this.patientUserID,
    @required this.patientUserProfileImage,
    @required this.patientUserFirstName,
    @required this.patientUserLastName,
    @required this.diseases,
    @required this.appointmentDate,
    @required this.treatmentStartDate,
  });

  PresentTreatmentsListModel copyWith({
    String treatmentID,
    String patientID,
    String patientUserID,
    String patientUserProfileImage,
    String patientUserFirstName,
    String patientUserLastName,
    String diseases,
    Timestamp appointmentDate,
    Timestamp treatmentStartDate,
  }) {
    return PresentTreatmentsListModel(
      treatmentID: treatmentID ?? this.treatmentID,
      patientID: patientID ?? this.patientID,
      patientUserID: patientUserID ?? this.patientUserID,
      patientUserProfileImage:
          patientUserProfileImage ?? this.patientUserProfileImage,
      patientUserFirstName: patientUserFirstName ?? this.patientUserFirstName,
      patientUserLastName: patientUserLastName ?? this.patientUserLastName,
      diseases: diseases ?? this.diseases,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      treatmentStartDate: treatmentStartDate ?? this.treatmentStartDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treatmentID': treatmentID,
      'patientID': patientID,
      'patientUserID': patientUserID,
      'patientUserProfileImage': patientUserProfileImage,
      'patientUserFirstName': patientUserFirstName,
      'patientUserLastName': patientUserLastName,
      'diseases': diseases,
      'appointmentDate': appointmentDate,
      'treatmentStartDate': treatmentStartDate,
    };
  }

  factory PresentTreatmentsListModel.fromMap(Map<String, dynamic> map) {
    return PresentTreatmentsListModel(
      treatmentID: map['treatmentID'],
      patientID: map['patientID'],
      patientUserID: map['patientUserID'],
      patientUserProfileImage: map['patientUserProfileImage'],
      patientUserFirstName: map['patientUserFirstName'],
      patientUserLastName: map['patientUserLastName'],
      diseases: map['diseases'],
      appointmentDate: map['appointmentDate'],
      treatmentStartDate: map['treatmentStartDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PresentTreatmentsListModel.fromJson(String source) =>
      PresentTreatmentsListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PresentTreatmentsListModel(treatmentID: $treatmentID, patientID: $patientID, patientUserID: $patientUserID, patientUserProfileImage: $patientUserProfileImage, patientUserFirstName: $patientUserFirstName, patientUserLastName: $patientUserLastName, diseases: $diseases, appointmentDate: $appointmentDate, treatmentStartDate: $treatmentStartDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PresentTreatmentsListModel &&
        other.treatmentID == treatmentID &&
        other.patientID == patientID &&
        other.patientUserID == patientUserID &&
        other.patientUserProfileImage == patientUserProfileImage &&
        other.patientUserFirstName == patientUserFirstName &&
        other.patientUserLastName == patientUserLastName &&
        other.diseases == diseases &&
        other.appointmentDate == appointmentDate &&
        other.treatmentStartDate == treatmentStartDate;
  }

  @override
  int get hashCode {
    return treatmentID.hashCode ^
        patientID.hashCode ^
        patientUserID.hashCode ^
        patientUserProfileImage.hashCode ^
        patientUserFirstName.hashCode ^
        patientUserLastName.hashCode ^
        diseases.hashCode ^
        appointmentDate.hashCode ^
        treatmentStartDate.hashCode;
  }
}
