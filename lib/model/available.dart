// To parse this JSON data, do
//
//     final available = availableFromJson(jsonString);

import 'dart:convert';

Available availableFromJson(String str) => Available.fromJson(json.decode(str));

String availableToJson(Available data) => json.encode(data.toJson());

class Available {
  Available({
    required  this.flag,
    this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  dynamic msg;
  int code;
  Data data;

  factory Available.fromJson(Map<String, dynamic> json) => Available(
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
    this.pilots,
    this.sic,
    this.fa,
    this.fi,
    required this.availList,
  });

  dynamic pilots;
  dynamic sic;
  dynamic fa;
  dynamic fi;
  List<AvailList> availList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pilots: json["Pilots"],
    sic: json["SIC"],
    fa: json["FA"],
    fi: json["FI"],
    availList: List<AvailList>.from(json["AvailList"].map((x) => AvailList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots,
    "SIC": sic,
    "FA": fa,
    "FI": fi,
    "AvailList": List<dynamic>.from(availList.map((x) => x.toJson())),
  };
}

class AvailList {
  AvailList({
    required this.isInsert,
    required this.isUpdate,
    required this.isDelete,
    required this.pkAvailabilityId,
    required this.fkPilotid,
    required this.fromDate,
    required this.toDate,
    required this.isAvailability,
    required this.comment,
    required this.city,
    required this.isVoid,
    required this.entryDate,
    required this.op,
    required  this.pkPilotId,
    required this.City,
    required this.State,
    required this.IsPast,
  });

  bool isInsert;
  bool isUpdate;
  bool isDelete;
  int pkAvailabilityId;
  int fkPilotid;
  DateTime fromDate;
  DateTime toDate;
  bool isAvailability;
  String comment;
  String city;
  bool isVoid;
  DateTime entryDate;
  String op;
  int pkPilotId;
  String City;
  String State;
  bool IsPast;

  factory AvailList.fromJson(Map<String, dynamic> json) => AvailList(
    isInsert: json["IsInsert"],
    isUpdate: json["IsUpdate"],
    isDelete: json["IsDelete"],
    pkAvailabilityId: json["pkAvailabilityId"],
    fkPilotid: json["fkPilotid"],
    fromDate: DateTime.parse(json["FromDate"]),
    toDate: DateTime.parse(json["ToDate"]),
    isAvailability: json["IsAvailability"],
    comment: json["Comment"],
    city: json["City"],
    isVoid: json["IsVoid"],
    entryDate: DateTime.parse(json["EntryDate"]),
    op: json["op"],
    pkPilotId: json["pkPilotId"],
    City: json["City"]== null ? "" : json["City"],
    State: json["State"] == null ? "" : json["State"],
    IsPast: json["IsPast"],
  );

  Map<String, dynamic> toJson() => {
    "IsInsert": isInsert,
    "IsUpdate": isUpdate,
    "IsDelete": isDelete,
    "pkAvailabilityId": pkAvailabilityId,
    "fkPilotid": fkPilotid,
    "FromDate": fromDate.toIso8601String(),
    "ToDate": toDate.toIso8601String(),
    "IsAvailability": isAvailability,
    "Comment": comment,
    "City": city,
    "IsVoid": isVoid,
    "EntryDate": entryDate.toIso8601String(),
    "op": op,
    "pkPilotId": pkPilotId,
    "City": City,
    "State": State,
    "IsPast": IsPast,
  };
}
