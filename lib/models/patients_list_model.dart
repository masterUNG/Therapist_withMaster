import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PatientsListModel {
  final String patientID;
  final String patientUserID;
  final String patientUserProfileImage;
  final String patientUserFirstName;
  final String patientUserLastName;
  PatientsListModel({
    @required this.patientID,
    @required this.patientUserID,
    @required this.patientUserProfileImage,
    @required this.patientUserFirstName,
    @required this.patientUserLastName,
  });

  PatientsListModel copyWith({
    String patientID,
    String patientUserID,
    String patientUserProfileImage,
    String patientUserFirstName,
    String patientUserLastName,
  }) {
    return PatientsListModel(
      patientID: patientID ?? this.patientID,
      patientUserID: patientUserID ?? this.patientUserID,
      patientUserProfileImage:
          patientUserProfileImage ?? this.patientUserProfileImage,
      patientUserFirstName: patientUserFirstName ?? this.patientUserFirstName,
      patientUserLastName: patientUserLastName ?? this.patientUserLastName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientID': patientID,
      'patientUserID': patientUserID,
      'patientUserProfileImage': patientUserProfileImage,
      'patientUserFirstName': patientUserFirstName,
      'patientUserLastName': patientUserLastName,
    };
  }

  factory PatientsListModel.fromMap(Map<String, dynamic> map) {
    return PatientsListModel(
      patientID: map['patientID'],
      patientUserID: map['patientUserID'],
      patientUserProfileImage: map['patientUserProfileImage'],
      patientUserFirstName: map['patientUserFirstName'],
      patientUserLastName: map['patientUserLastName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientsListModel.fromJson(String source) =>
      PatientsListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientsListModel(patientID: $patientID, patientUserID: $patientUserID, patientUserProfileImage: $patientUserProfileImage, patientUserFirstName: $patientUserFirstName, patientUserLastName: $patientUserLastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientsListModel &&
        other.patientID == patientID &&
        other.patientUserID == patientUserID &&
        other.patientUserProfileImage == patientUserProfileImage &&
        other.patientUserFirstName == patientUserFirstName &&
        other.patientUserLastName == patientUserLastName;
  }

  @override
  int get hashCode {
    return patientID.hashCode ^
        patientUserID.hashCode ^
        patientUserProfileImage.hashCode ^
        patientUserFirstName.hashCode ^
        patientUserLastName.hashCode;
  }
}
