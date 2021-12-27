import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class DiseasesModel {
  final String disease;
  final Timestamp createdAt;
  DiseasesModel({
    @required this.disease,
    @required this.createdAt,
  });

  DiseasesModel copyWith({
    String disease,
    Timestamp createdAt,
  }) {
    return DiseasesModel(
      disease: disease ?? this.disease,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'createdAt': createdAt,
    };
  }

  factory DiseasesModel.fromMap(Map<String, dynamic> map) {
    return DiseasesModel(
      disease: map['disease'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DiseasesModel.fromJson(String source) =>
      DiseasesModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'DiseasesModel(disease: $disease, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiseasesModel &&
        other.disease == disease &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => disease.hashCode ^ createdAt.hashCode;
}
