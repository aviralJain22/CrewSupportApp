// To parse this JSON data, do
//
//     final getAvailability = getAvailabilityFromJson(jsonString);

import 'dart:convert';

GetAvailability getAvailabilityFromJson(String str) =>
    GetAvailability.fromJson(json.decode(str));

String getAvailabilityToJson(GetAvailability data) =>
    json.encode(data.toJson());

class GetAvailability {
  GetAvailability({
    this.flag,
    this.msg,
    this.code,
    this.data,
  });

  int? flag;
  dynamic msg;
  int? code;
  var data;

  factory GetAvailability.fromJson(Map<String, dynamic> json) =>
      GetAvailability(
        flag: json["flag"] == null ? null : json["flag"],
        msg: json["msg"] == null ? "" : json["msg"],
        code: json["Code"] == null ? null : json["Code"],
        data: json["data"] == null ? [] : AvailData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "flag": flag == null ? null : flag,
        "msg": msg == null ? null : msg,
        "Code": code == null ? null : code,
        "data": data == null ? null : data.toJson(),
      };
}

class AvailData {
  AvailData({
    this.availList,
  });

  List<AvailList>? availList;

  factory AvailData.fromRawJson(String str) =>
      AvailData.fromJson(json.decode(str));

  factory AvailData.fromJson(Map<String, dynamic> json) => AvailData(
        availList: json["AvailList"] == null
            ? []
            : List<AvailList>.from(
                json["AvailList"].map((x) => AvailList.fromJson(x))),
      );
}

class AvailList {
  AvailList({
    this.isInsert,
    this.isUpdate,
    this.isDelete,
    this.pkAvailabilityId,
    this.fkPilotid,
    this.fromDate,
    this.toDate,
    this.isAvailability,
    this.state,
    this.city,
    this.isVoid,
    this.entryDate,
    this.op,
    this.pkPilotId,
    this.comment,
    this.isCurrent,
    this.isFuture,
    this.isPast,
    this.zip,
  });

  bool? isInsert;
  bool? isUpdate;
  bool? isDelete;
  int? pkAvailabilityId;
  int? fkPilotid;
  String? fromDate;
  String? toDate;
  bool? isAvailability;
  String? state;
  String? city;
  bool? isVoid;
  String? entryDate;
  String? op;
  int? pkPilotId;
  String? comment;
  bool? isCurrent;
  bool? isFuture;
  bool? isPast;
  String? zip;

  factory AvailList.fromJson(Map<String, dynamic> json) => AvailList(
        isInsert: json["IsInsert"] == null ? null : json["IsInsert"],
        isUpdate: json["IsUpdate"] == null ? null : json["IsUpdate"],
        isDelete: json["IsDelete"] == null ? null : json["IsDelete"],
        pkAvailabilityId:
            json["pkAvailabilityId"] == null ? null : json["pkAvailabilityId"],
        fkPilotid: json["fkPilotid"] == null ? null : json["fkPilotid"],
        fromDate: json["FromDate"] == null ? null : json["FromDate"],
        toDate: json["ToDate"] == null ? null : json["ToDate"],
        isAvailability:
            json["IsAvailability"] == null ? null : json["IsAvailability"],
        state: json["State"] == null ? null : json["State"],
        city: json["City"] == null ? null : json["City"],
        zip: json["Zip"] == null ? null : json["Zip"],
        comment: json['Comment'] == null ? null : json["Comment"],
        isVoid: json["IsVoid"] == null ? null : json["IsVoid"],
        entryDate: json["EntryDate"] == null ? null : json["EntryDate"],
        op: json["op"] == null ? null : json["op"],
        pkPilotId: json["pkPilotId"] == null ? null : json["pkPilotId"],
        isCurrent: json["IsCurrent"] == null ? null : json["IsCurrent"],
        isFuture: json["IsFuture"] == null ? null : json["IsFuture"],
        isPast: json["IsPast"] == null ? null : json["IsPast"],
      );

  Map<String, dynamic> toJson() => {
        "IsInsert": isInsert == null ? null : isInsert,
        "IsUpdate": isUpdate == null ? null : isUpdate,
        "IsDelete": isDelete == null ? null : isDelete,
        "pkAvailabilityId": pkAvailabilityId == null ? null : pkAvailabilityId,
        "fkPilotid": fkPilotid == null ? null : fkPilotid,
        "FromDate": fromDate == null ? null : fromDate,
        "ToDate": toDate == null ? null : toDate,
        "IsAvailability": isAvailability == null ? null : isAvailability,
        "State": state == null ? null : state,
        "City": city == null ? null : city,
        "Zip": zip == null ? null : zip,
        'comment': comment == null ? null : comment,
        "IsVoid": isVoid == null ? null : isVoid,
        "EntryDate": entryDate == null ? null : entryDate,
        "op": op == null ? null : op,
        "pkPilotId": pkPilotId == null ? null : pkPilotId,
        "IsCurrent": isCurrent == null ? null : isCurrent,
        "IsFuture": isFuture == null ? null : isFuture,
        "IsPast": isPast == null ? null : isPast,
      };
}
