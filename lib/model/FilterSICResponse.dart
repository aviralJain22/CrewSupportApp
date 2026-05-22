// To parse this JSON data, do
//
//     final filterSicResponse = filterSicResponseFromJson(jsonString);

import 'package:crew_support/model/GetLoginDataResponse.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

FilterSicResponse filterSicResponseFromJson(String str) => FilterSicResponse.fromJson(json.decode(str));


class FilterSicResponse {
  FilterSicResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  SICData? data;

  factory FilterSicResponse.fromJson(Map<String, dynamic> json) => FilterSicResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? null : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"] == null ? null : SICData.fromJson(json["data"]),
  );

}

class SICData {
  SICData({
    required this.pilots,
    required this.sic,
    required this.fa,
    required this.fi,
  });

  dynamic pilots;
  List<Pilot> sic;
  dynamic fa;
  dynamic fi;

  factory SICData.fromJson(Map<String, dynamic> json) => SICData(
    pilots: json["Pilots"],
    sic: json["SIC"] == null ? [] : List<Pilot>.from(json["SIC"].map((x) => Pilot.fromJson(x))),
    fa: json["FA"],
    fi: json["FI"],
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots,
    "SIC": sic == null ? null : List<dynamic>.from(sic.map((x) => x.toJson())),
    "FA": fa,
    "FI": fi,
  };
}


