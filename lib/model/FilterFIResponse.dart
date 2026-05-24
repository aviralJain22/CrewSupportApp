// To parse this JSON data, do
//
//     final filterFiResponse = filterFiResponseFromJson(jsonString);

import 'dart:convert';

import 'GetLoginDataResponse.dart';

FilterFiResponse filterFiResponseFromJson(String str) => FilterFiResponse.fromJson(json.decode(str));


class FilterFiResponse {
  FilterFiResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  Data? data;

  factory FilterFiResponse.fromJson(Map<String, dynamic> json) => FilterFiResponse(
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
  dynamic fa;
  List<Pilot> fi;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pilots: json["Pilots"],
    sic: json["SIC"],
    fa: json["FA"],
    fi: json["FI"] == null ? [] : List<Pilot>.from(json["FI"].map((x) => Pilot.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots,
    "SIC": sic,
    "FA": fa,
    "FI": fi == null ? null : List<dynamic>.from(fi.map((x) => x.toJson())),
  };
}


