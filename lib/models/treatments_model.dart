import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class TreatmentsModel {
  final String therapistID;
  final String patientID;
  final String patientUserID;
  final Timestamp startDate;
  final Timestamp finishDate;
  final bool isActive;
  final String finishStatus;
  TreatmentsModel({
    @required this.therapistID,
    @required this.patientID,
    @required this.patientUserID,
    @required this.startDate,
    @required this.finishDate,
    @required this.isActive,
    @required this.finishStatus,
  });

  TreatmentsModel copyWith({
    String therapistID,
    String patientID,
    String patientUserID,
    Timestamp startDate,
    Timestamp finishDate,
    bool isActive,
    String finishStatus,
  }) {
    return TreatmentsModel(
      therapistID: therapistID ?? this.therapistID,
      patientID: patientID ?? this.patientID,
      patientUserID: patientUserID ?? this.patientUserID,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      isActive: isActive ?? this.isActive,
      finishStatus: finishStatus ?? this.finishStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'therapistID': therapistID,
      'patientID': patientID,
      'patientUserID': patientUserID,
      'startDate': startDate,
      'finishDate': finishDate,
      'isActive': isActive,
      'finishStatus': finishStatus,
    };
  }

  factory TreatmentsModel.fromMap(Map<String, dynamic> map) {
    return TreatmentsModel(
      therapistID: map['therapistID'],
      patientID: map['patientID'],
      patientUserID: map['patientUserID'],
      startDate: map['startDate'],
      finishDate: map['finishDate'],
      isActive: map['isActive'],
      finishStatus: map['finishStatus'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TreatmentsModel.fromJson(String source) =>
      TreatmentsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TreatmentsModel(therapistID: $therapistID, patientID: $patientID, patientUserID: $patientUserID, startDate: $startDate, finishDate: $finishDate, isActive: $isActive, finishStatus: $finishStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TreatmentsModel &&
        other.therapistID == therapistID &&
        other.patientID == patientID &&
        other.patientUserID == patientUserID &&
        other.startDate == startDate &&
        other.finishDate == finishDate &&
        other.isActive == isActive &&
        other.finishStatus == finishStatus;
  }

  @override
  int get hashCode {
    return therapistID.hashCode ^
        patientID.hashCode ^
        patientUserID.hashCode ^
        startDate.hashCode ^
        finishDate.hashCode ^
        isActive.hashCode ^
        finishStatus.hashCode;
  }
}
