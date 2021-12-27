import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PatientUsersModel {
  final String patientID;
  final String therapyBuddyID;
  final String profileImage;
  final String firstName;
  final String lastName;
  final Timestamp birthday;
  final String gender;
  final Timestamp createdAt;
  final Timestamp lastUpdate;
  final Timestamp deletedAt;
  PatientUsersModel({
    @required this.patientID,
    @required this.therapyBuddyID,
    @required this.profileImage,
    @required this.firstName,
    @required this.lastName,
    @required this.birthday,
    @required this.gender,
    @required this.createdAt,
    @required this.lastUpdate,
    @required this.deletedAt,
  });

  PatientUsersModel copyWith({
    String patientID,
    String therapyBuddyID,
    String profileImage,
    String firstName,
    String lastName,
    Timestamp birthday,
    String gender,
    Timestamp createdAt,
    Timestamp lastUpdate,
    Timestamp deletedAt,
  }) {
    return PatientUsersModel(
      patientID: patientID ?? this.patientID,
      therapyBuddyID: therapyBuddyID ?? this.therapyBuddyID,
      profileImage: profileImage ?? this.profileImage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientID': patientID,
      'therapyBuddyID': therapyBuddyID,
      'profileImage': profileImage,
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'gender': gender,
      'createdAt': createdAt,
      'lastUpdate': lastUpdate,
      'deletedAt': deletedAt,
    };
  }

  factory PatientUsersModel.fromMap(Map<String, dynamic> map) {
    return PatientUsersModel(
      patientID: map['patientID'],
      therapyBuddyID: map['therapyBuddyID'],
      profileImage: map['profileImage'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      birthday: map['birthday'],
      gender: map['gender'],
      createdAt: map['createdAt'],
      lastUpdate: map['lastUpdate'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientUsersModel.fromJson(String source) =>
      PatientUsersModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientUsersModel(patientID: $patientID, therapyBuddyID: $therapyBuddyID, profileImage: $profileImage, firstName: $firstName, lastName: $lastName, birthday: $birthday, gender: $gender, createdAt: $createdAt, lastUpdate: $lastUpdate, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientUsersModel &&
        other.patientID == patientID &&
        other.therapyBuddyID == therapyBuddyID &&
        other.profileImage == profileImage &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.birthday == birthday &&
        other.gender == gender &&
        other.createdAt == createdAt &&
        other.lastUpdate == lastUpdate &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return patientID.hashCode ^
        therapyBuddyID.hashCode ^
        profileImage.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        birthday.hashCode ^
        gender.hashCode ^
        createdAt.hashCode ^
        lastUpdate.hashCode ^
        deletedAt.hashCode;
  }
}
