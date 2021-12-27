import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PatientNotificationsModel {
  final String image;
  final String title;
  final String body;
  final String category;
  final Timestamp readAt;
  final Timestamp createdAt;
  PatientNotificationsModel({
    @required this.image,
    @required this.title,
    @required this.body,
    @required this.category,
    @required this.readAt,
    @required this.createdAt,
  });

  PatientNotificationsModel copyWith({
    String image,
    String title,
    String body,
    String category,
    Timestamp readAt,
    Timestamp createdAt,
  }) {
    return PatientNotificationsModel(
      image: image ?? this.image,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'title': title,
      'body': body,
      'category': category,
      'readAt': readAt,
      'createdAt': createdAt,
    };
  }

  factory PatientNotificationsModel.fromMap(Map<String, dynamic> map) {
    return PatientNotificationsModel(
      image: map['image'],
      title: map['title'],
      body: map['body'],
      category: map['category'],
      readAt: map['readAt'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientNotificationsModel.fromJson(String source) =>
      PatientNotificationsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientNotificationsModel(image: $image, title: $title, body: $body, category: $category, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientNotificationsModel &&
        other.image == image &&
        other.title == title &&
        other.body == body &&
        other.category == category &&
        other.readAt == readAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return image.hashCode ^
        title.hashCode ^
        body.hashCode ^
        category.hashCode ^
        readAt.hashCode ^
        createdAt.hashCode;
  }
}
