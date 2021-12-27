import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class OTPSentModel {
  final String status;
  final String token;
  OTPSentModel({
    @required this.status,
    @required this.token,
  });

  OTPSentModel copyWith({
    String status,
    String token,
  }) {
    return OTPSentModel(
      status: status ?? this.status,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'token': token,
    };
  }

  factory OTPSentModel.fromMap(Map<String, dynamic> map) {
    return OTPSentModel(
      status: map['status'],
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OTPSentModel.fromJson(String source) =>
      OTPSentModel.fromMap(json.decode(source));

  @override
  String toString() => 'TokenSentModel(status: $status, token: $token)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OTPSentModel &&
        other.status == status &&
        other.token == token;
  }

  @override
  int get hashCode => status.hashCode ^ token.hashCode;
}
