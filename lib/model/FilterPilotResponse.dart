// To parse this JSON data, do
//
//     final filterPilotResponse = filterPilotResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'GetLoginDataResponse.dart';

FilterPilotResponse filterPilotResponseFromJson(String str) => FilterPilotResponse.fromJson(json.decode(str));

class FilterPilotResponse {
  FilterPilotResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  Data? data;

  factory FilterPilotResponse.fromJson(Map<String, dynamic> json) => FilterPilotResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? null : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

}

class Data {
  Data({
    required this.pilots,
    required this.sic,
    required this.fa,
    required this.fi,
  });

  List<Pilot> pilots;
  dynamic sic;
  dynamic fa;
  dynamic fi;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pilots: json["Pilots"] == null ? [] : List<Pilot>.from(json["Pilots"].map((x) => Pilot.fromJson(x))),
    sic: json["SIC"],
    fa: json["FA"],
    fi: json["FI"],
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots == null ? null : List<dynamic>.from(pilots.map((x) => x.toJson())),
    "SIC": sic,
    "FA": fa,
    "FI": fi,
  };
}

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String countryName;
  final dynamic membershipType; // or int if always numeric

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryName,
    required this.membershipType,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      countryName: data['countryName'] ?? '',
      membershipType: data['membershipType'],
    );
  }
}