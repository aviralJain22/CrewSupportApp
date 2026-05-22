// To parse this JSON data, do
//
//     final filterFlightAttedantResponse = filterFlightAttedantResponseFromJson(jsonString);

import 'dart:convert';

import 'package:meta/meta.dart';
import 'dart:convert';

import 'GetLoginDataResponse.dart';
FilterFlightAttedantResponse filterFlightAttedantResponseFromJson(String str) => FilterFlightAttedantResponse.fromJson(json.decode(str));






class FilterFlightAttedantResponse {
  FilterFlightAttedantResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String? msg;
  int code;
  Data? data;

  factory FilterFlightAttedantResponse.fromJson(Map<String, dynamic> json) => FilterFlightAttedantResponse(
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

  dynamic pilots;
  dynamic sic;
  List<Pilot> fa;
   dynamic fi;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pilots: json["Pilots"],
    sic: json["SIC"],
    fa: json["FA"] == null ? [] : List<Pilot>.from(json["FA"].map((x) => Pilot.fromJson(x))),
    fi: json["FI"],
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots,
    "SIC": sic,
    "FA": fa == null ? null : List<dynamic>.from(fi.map((x) => x.toJson())),
    "FI": fi,
  };
}


