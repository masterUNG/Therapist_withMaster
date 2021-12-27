import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class TherapistsModel {
  final String profileImage;
  final String nameTitle;
  final String firstName;
  final String lastName;
  final String callingCode;
  final String phoneNumber;
  final String password;
  final String licenseNumberTitle;
  final String licenseNumber;
  final String workplace;
  final Timestamp birthday;
  final String gender;
  final Timestamp createdAt;
  final Timestamp lastUpdate;
  final Timestamp deletedAt;
  TherapistsModel({
    @required this.profileImage,
    @required this.nameTitle,
    @required this.firstName,
    @required this.lastName,
    @required this.callingCode,
    @required this.phoneNumber,
    @required this.password,
    @required this.licenseNumberTitle,
    @required this.licenseNumber,
    @required this.workplace,
    @required this.birthday,
    @required this.gender,
    @required this.createdAt,
    @required this.lastUpdate,
    @required this.deletedAt,
  });

  TherapistsModel copyWith({
    String profileImage,
    String nameTitle,
    String firstName,
    String lastName,
    String callingCode,
    String phoneNumber,
    String password,
    String licenseNumberTitle,
    String licenseNumber,
    String workplace,
    Timestamp birthday,
    String gender,
    Timestamp createdAt,
    Timestamp lastUpdate,
    Timestamp deletedAt,
  }) {
    return TherapistsModel(
      profileImage: profileImage ?? this.profileImage,
      nameTitle: nameTitle ?? this.nameTitle,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      callingCode: callingCode ?? this.callingCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      licenseNumberTitle: licenseNumberTitle ?? this.licenseNumberTitle,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      workplace: workplace ?? this.workplace,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImage': profileImage,
      'nameTitle': nameTitle,
      'firstName': firstName,
      'lastName': lastName,
      'callingCode': callingCode,
      'phoneNumber': phoneNumber,
      'password': password,
      'licenseNumberTitle': licenseNumberTitle,
      'licenseNumber': licenseNumber,
      'workplace': workplace,
      'birthday': birthday,
      'gender': gender,
      'createdAt': createdAt,
      'lastUpdate': lastUpdate,
      'deletedAt': deletedAt,
    };
  }

  factory TherapistsModel.fromMap(Map<String, dynamic> map) {
    return TherapistsModel(
      profileImage: map['profileImage'],
      nameTitle: map['nameTitle'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      callingCode: map['callingCode'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      licenseNumberTitle: map['licenseNumberTitle'],
      licenseNumber: map['licenseNumber'],
      workplace: map['workplace'],
      birthday: map['birthday'],
      gender: map['gender'],
      createdAt: map['createdAt'],
      lastUpdate: map['lastUpdate'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TherapistsModel.fromJson(String source) =>
      TherapistsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TherapistsModel(profileImage: $profileImage, nameTitle: $nameTitle, firstName: $firstName, lastName: $lastName, callingCode: $callingCode, phoneNumber: $phoneNumber, password: $password, licenseNumberTitle: $licenseNumberTitle, licenseNumber: $licenseNumber, workplace: $workplace, birthday: $birthday, gender: $gender, createdAt: $createdAt, lastUpdate: $lastUpdate, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TherapistsModel &&
        other.profileImage == profileImage &&
        other.nameTitle == nameTitle &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.callingCode == callingCode &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.licenseNumberTitle == licenseNumberTitle &&
        other.licenseNumber == licenseNumber &&
        other.workplace == workplace &&
        other.birthday == birthday &&
        other.gender == gender &&
        other.createdAt == createdAt &&
        other.lastUpdate == lastUpdate &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return profileImage.hashCode ^
        nameTitle.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        callingCode.hashCode ^
        phoneNumber.hashCode ^
        password.hashCode ^
        licenseNumberTitle.hashCode ^
        licenseNumber.hashCode ^
        workplace.hashCode ^
        birthday.hashCode ^
        gender.hashCode ^
        createdAt.hashCode ^
        lastUpdate.hashCode ^
        deletedAt.hashCode;
  }
}
