import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class CheckOTPModel {
  final String status;
  final String message;
  CheckOTPModel({
    @required this.status,
    @required this.message,
  });

  CheckOTPModel copyWith({
    String status,
    String message,
  }) {
    return CheckOTPModel(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'message': message,
    };
  }

  factory CheckOTPModel.fromMap(Map<String, dynamic> map) {
    return CheckOTPModel(
      status: map['status'],
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CheckOTPModel.fromJson(String source) =>
      CheckOTPModel.fromMap(json.decode(source));

  @override
  String toString() => 'CheckOTPModel(status: $status, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CheckOTPModel &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode;
}
