// To parse this JSON data, do
//
//     final viewProfileResponse = viewProfileResponseFromJson(jsonString);

import 'package:crew_support/model/GetLoginDataResponse.dart';
import 'dart:convert';

ViewProfileResponse viewProfileResponseFromJson(String str) => ViewProfileResponse.fromJson(json.decode(str));

String viewProfileResponseToJson(ViewProfileResponse data) => json.encode(data.toJson());

class ViewProfileResponse {
  ViewProfileResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  Data data;

  factory ViewProfileResponse.fromJson(Map<String, dynamic> json) => ViewProfileResponse(
    flag: json["flag"],
    msg: json["msg"],
    code: json["Code"],
    data: Data.fromJson(json["data"]),
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
    required this.pilot,
  });

  Pilot pilot;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pilot: Pilot.fromJson(json["Pilot"]),
  );

  Map<String, dynamic> toJson() => {
    "Pilot": pilot.toJson(),
  };
}



class Certification {
  Certification({
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
    required this.availTime,
    required this.isCompanyName,
    this.AppVersion,
    this.cellNumber,
    this.City,
    this.State,
    this.Zip,
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
  DateTime availTime;
  bool isCompanyName;
  String? AppVersion;
  String? cellNumber;
  dynamic City;
  dynamic State;
  dynamic Zip;

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
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
    availTime: DateTime.parse(json['AvailTime']),
    isCompanyName: json['IsDefaultCompanyName'],
    AppVersion: json["AppVersion"],
    cellNumber: json["cellNumber"],
    City: json["City"],
    State: json["State"],
    Zip: json["Zip"],
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
    'AvailTime':availTime,
    "IsDefaultCompanyName" : isCompanyName,
    "AppVersion": AppVersion,
    "cellNumber": cellNumber,
    "City": City,
    "State": State,
    "Zip": Zip,
  };
}
