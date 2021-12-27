import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class TokensModel {
  final String token;
  final bool isActive;
  final Timestamp createdAt;
  final Timestamp lastUpdate;
  TokensModel({
    @required this.token,
    @required this.isActive,
    @required this.createdAt,
    @required this.lastUpdate,
  });

  TokensModel copyWith({
    String token,
    bool isActive,
    Timestamp createdAt,
    Timestamp lastUpdate,
  }) {
    return TokensModel(
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastUpdate': lastUpdate,
    };
  }

  factory TokensModel.fromMap(Map<String, dynamic> map) {
    return TokensModel(
      token: map['token'],
      isActive: map['isActive'],
      createdAt: map['createdAt'],
      lastUpdate: map['lastUpdate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TokensModel.fromJson(String source) =>
      TokensModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TokensModel(token: $token, isActive: $isActive, createdAt: $createdAt, lastUpdate: $lastUpdate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokensModel &&
        other.token == token &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.lastUpdate == lastUpdate;
  }

  @override
  int get hashCode {
    return token.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        lastUpdate.hashCode;
  }
}
