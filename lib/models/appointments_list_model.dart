import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AppointmentsListModel {
  final String patientProfileImage;
  final String patientFirstName;
  final String patientLastName;
  final Timestamp appointmentDate;
  final Timestamp appointmentStartTime;
  final Timestamp appointmentFinishTime;
  final String appointmentPlace;
  AppointmentsListModel({
    @required this.patientProfileImage,
    @required this.patientFirstName,
    @required this.patientLastName,
    @required this.appointmentDate,
    @required this.appointmentStartTime,
    @required this.appointmentFinishTime,
    @required this.appointmentPlace,
  });

  AppointmentsListModel copyWith({
    String patientProfileImage,
    String patientFirstName,
    String patientLastName,
    Timestamp appointmentDate,
    Timestamp appointmentStartTime,
    Timestamp appointmentFinishTime,
    String appointmentPlace,
  }) {
    return AppointmentsListModel(
      patientProfileImage: patientProfileImage ?? this.patientProfileImage,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientLastName: patientLastName ?? this.patientLastName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentStartTime: appointmentStartTime ?? this.appointmentStartTime,
      appointmentFinishTime:
      appointmentFinishTime ?? this.appointmentFinishTime,
      appointmentPlace: appointmentPlace ?? this.appointmentPlace,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientProfileImage': patientProfileImage,
      'patientFirstName': patientFirstName,
      'patientLastName': patientLastName,
      'appointmentDate': appointmentDate,
      'appointmentStartTime': appointmentStartTime,
      'appointmentFinishTime': appointmentFinishTime,
      'appointmentPlace': appointmentPlace,
    };
  }

  factory AppointmentsListModel.fromMap(Map<String, dynamic> map) {
    return AppointmentsListModel(
      patientProfileImage: map['patientProfileImage'],
      patientFirstName: map['patientFirstName'],
      patientLastName: map['patientLastName'],
      appointmentDate: map['appointmentDate'],
      appointmentStartTime: map['appointmentStartTime'],
      appointmentFinishTime: map['appointmentFinishTime'],
      appointmentPlace: map['appointmentPlace'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppointmentsListModel.fromJson(String source) =>
      AppointmentsListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppointmentsListModel(patientProfileImage: $patientProfileImage, patientFirstName: $patientFirstName, patientLastName: $patientLastName, appointmentDate: $appointmentDate, appointmentStartTime: $appointmentStartTime, appointmentFinishTime: $appointmentFinishTime, appointmentPlace: $appointmentPlace)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppointmentsListModel &&
        other.patientProfileImage == patientProfileImage &&
        other.patientFirstName == patientFirstName &&
        other.patientLastName == patientLastName &&
        other.appointmentDate == appointmentDate &&
        other.appointmentStartTime == appointmentStartTime &&
        other.appointmentFinishTime == appointmentFinishTime &&
        other.appointmentPlace == appointmentPlace;
  }

  @override
  int get hashCode {
    return patientProfileImage.hashCode ^
    patientFirstName.hashCode ^
    patientLastName.hashCode ^
    appointmentDate.hashCode ^
    appointmentStartTime.hashCode ^
    appointmentFinishTime.hashCode ^
    appointmentPlace.hashCode;
  }
}
