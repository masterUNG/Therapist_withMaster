import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AppointmentsModel {
  final Timestamp date;
  final Timestamp startTime;
  final Timestamp finishTime;
  final bool isActive;
  final String finishStatus;
  final Timestamp createdAt;
  final Timestamp lastUpdate;
  final Timestamp deletedAt;
  AppointmentsModel({
    @required this.date,
    @required this.startTime,
    @required this.finishTime,
    @required this.isActive,
    @required this.finishStatus,
    @required this.createdAt,
    @required this.lastUpdate,
    @required this.deletedAt,
  });

  AppointmentsModel copyWith({
    Timestamp date,
    Timestamp startTime,
    Timestamp finishTime,
    bool isActive,
    String finishStatus,
    Timestamp createdAt,
    Timestamp lastUpdate,
    Timestamp deletedAt,
  }) {
    return AppointmentsModel(
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      finishTime: finishTime ?? this.finishTime,
      isActive: isActive ?? this.isActive,
      finishStatus: finishStatus ?? this.finishStatus,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'startTime': startTime,
      'finishTime': finishTime,
      'isActive': isActive,
      'finishStatus': finishStatus,
      'createdAt': createdAt,
      'lastUpdate': lastUpdate,
      'deletedAt': deletedAt,
    };
  }

  factory AppointmentsModel.fromMap(Map<String, dynamic> map) {
    return AppointmentsModel(
      date: map['date'],
      startTime: map['startTime'],
      finishTime: map['finishTime'],
      isActive: map['isActive'],
      finishStatus: map['finishStatus'],
      createdAt: map['createdAt'],
      lastUpdate: map['lastUpdate'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppointmentsModel.fromJson(String source) =>
      AppointmentsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppointmentsModel(date: $date, startTime: $startTime, finishTime: $finishTime, isActive: $isActive, finishStatus: $finishStatus, createdAt: $createdAt, lastUpdate: $lastUpdate, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppointmentsModel &&
        other.date == date &&
        other.startTime == startTime &&
        other.finishTime == finishTime &&
        other.isActive == isActive &&
        other.finishStatus == finishStatus &&
        other.createdAt == createdAt &&
        other.lastUpdate == lastUpdate &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        startTime.hashCode ^
        finishTime.hashCode ^
        isActive.hashCode ^
        finishStatus.hashCode ^
        createdAt.hashCode ^
        lastUpdate.hashCode ^
        deletedAt.hashCode;
  }
}
