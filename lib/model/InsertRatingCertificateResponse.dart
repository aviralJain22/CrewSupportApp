// To parse this JSON data, do
//
//     final insertRatingCertificateResponse = insertRatingCertificateResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

InsertRatingCertificateResponse insertRatingCertificateResponseFromJson(String str) => InsertRatingCertificateResponse.fromJson(json.decode(str));

String insertRatingCertificateResponseToJson(InsertRatingCertificateResponse data) => json.encode(data.toJson());

class InsertRatingCertificateResponse {
  InsertRatingCertificateResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  var data;

  factory InsertRatingCertificateResponse.fromJson(Map<String, dynamic> json) => InsertRatingCertificateResponse(
    flag: json["flag"],
    msg: json["msg"],
    code: json["Code"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "flag": flag,
    "msg": msg,
    "Code": code,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    required this.ratingCertificate,
  });

  List<RatingCertificate> ratingCertificate;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ratingCertificate: List<RatingCertificate>.from(json["RatingCertificate"].map((x) => RatingCertificate.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "RatingCertificate": List<dynamic>.from(ratingCertificate.map((x) => x.toJson())),
  };
}

class RatingCertificate {
  RatingCertificate({
    required this.pkRatingCertiId,
    required this.fkPilotid,
    required this.ratingCertification,
    required this.fkCategoryId,
    required this.cetogoryType,
    required this.fkClassId,
    required this.classType,
    required this.aircraftType,
    required this.hours,
    required this.pic,
    required this.minimumRate,
    required this.currentInType,
    required this.entryDate,
    required this.isReqPrev12MonthTraining,
    required this.isVoid,
  });

  int pkRatingCertiId;
  int fkPilotid;
  String ratingCertification;
  int fkCategoryId;
  String cetogoryType;
  int fkClassId;
  String classType;
  String aircraftType;
  String hours;
  String pic;
  double minimumRate;
  String currentInType;
  DateTime entryDate;
  bool isReqPrev12MonthTraining;
  bool isVoid;

  factory RatingCertificate.fromJson(Map<String, dynamic> json) => RatingCertificate(
    pkRatingCertiId: json["pkRatingCertiId"],
    fkPilotid: json["fkPilotid"],
    ratingCertification: json["RatingCertification"],
    fkCategoryId: json["fkCategoryId"],
    cetogoryType: json["CetogoryType"],
    fkClassId: json["fkClassId"],
    classType: json["ClassType"],
    aircraftType: json["AirCraftType"],
    hours: json["Hours"],
    pic: json["PIC"],
    minimumRate: json["MinimumRate"],
    currentInType: json["CurrentInType"],
    entryDate: DateTime.parse(json["EntryDate"]),
    isReqPrev12MonthTraining: json["IsReqPrev12MonthTraining"],
    isVoid: json["isVoid"],
  );

  Map<String, dynamic> toJson() => {
    "pkRatingCertiId": pkRatingCertiId,
    "fkPilotid": fkPilotid,
    "RatingCertification": ratingCertification,
    "fkCategoryId": fkCategoryId,
    "CetogoryType": cetogoryType,
    "fkClassId": fkClassId,
    "ClassType": classType,
    "AirCraftType": aircraftType,
    "Hours": hours,
    "PIC": pic,
    "MinimumRate": minimumRate,
    "CurrentInType": currentInType,
    "EntryDate": entryDate.toIso8601String(),
    "IsReqPrev12MonthTraining": isReqPrev12MonthTraining,
    "isVoid": isVoid,
  };
}
