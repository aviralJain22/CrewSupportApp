// To parse this JSON data, do
//
//     final insertupdateFavouriteResponse = insertupdateFavouriteResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

InsertUpdateFavouriteResponse insertupdateFavouriteResponseFromJson(String str) => InsertUpdateFavouriteResponse.fromJson(json.decode(str));

//String insertupdateFavouriteResponseToJson(InsertupdateFavouriteResponse data) => json.encode(data.toJson());

class InsertUpdateFavouriteResponse {
  InsertUpdateFavouriteResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
    required this.datas,
  });

  int flag;
  String msg;
  int code;
  Data? data;
  dynamic datas;

  factory InsertUpdateFavouriteResponse.fromJson(Map<String, dynamic> json) => InsertUpdateFavouriteResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? null : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    datas: json["datas"],
  );

  // Map<String, dynamic> toJson() => {
  //   "flag": flag == null ? null : flag,
  //   "msg": msg == null ? null : msg,
  //   "Code": code == null ? null : code,
  //   "data": data == null ? null : data.toJson(),
  //   "datas": datas,
  // };
}

class Data {
  Data({
    required this.favourite,
  });

  Favourite? favourite;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    favourite: json["Favourite"] == null ? null : Favourite.fromJson(json["Favourite"]),
  );

  // Map<String, dynamic> toJson() => {
  //   "Favourite": favourite == null ? null : favourite.toJson(),
  // };
}

class Favourite {
  Favourite({
    required this.pkFavId,
    required this.fkUserId,
    required this.fkPilotid,
    required this.entryDate,
    required this.isFavourite,
    required this.pilotFname,
    required this.pilotmname,
    required this.pilotlname,
    required this.photoPath,
    required this.memberShipType,
    required this.ratingCount,
  });

  int pkFavId;
  int fkUserId;
  int fkPilotid;
  String entryDate;
  bool isFavourite;
  String pilotFname;
  String pilotmname;
  String pilotlname;
  String photoPath;
  String memberShipType;
  String ratingCount;

  factory Favourite.fromJson(Map<String, dynamic> json) => Favourite(
    pkFavId: json["pkFavId"] == null ? null : json["pkFavId"],
    fkUserId: json["fkUserID"] == null ? null : json["fkUserID"],
    fkPilotid: json["fkPilotid"] == null ? null : json["fkPilotid"],
    entryDate: json["EntryDate"] == null ? null : json["EntryDate"],
    isFavourite: json["isFavourite"] == null ? null : json["isFavourite"],
    pilotFname: json["PilotFname"] == null ? null : json["PilotFname"],
    pilotmname: json["Pilotmname"] == null ? null : json["Pilotmname"],
    pilotlname: json["Pilotlname"] == null ? null : json["Pilotlname"],
    photoPath: json["PhotoPath"] == null ? null : json["PhotoPath"],
    memberShipType: json["MemberShipType"] == null ? null : json["MemberShipType"],
    ratingCount: json["ratingCount"] == null ? null : json["ratingCount"],
  );

  Map<String, dynamic> toJson() => {
    "pkFavId": pkFavId == null ? null : pkFavId,
    "fkUserID": fkUserId == null ? null : fkUserId,
    "fkPilotid": fkPilotid == null ? null : fkPilotid,
    "EntryDate": entryDate == null ? null : entryDate,
    "isFavourite": isFavourite == null ? null : isFavourite,
    "PilotFname": pilotFname == null ? null : pilotFname,
    "Pilotmname": pilotmname == null ? null : pilotmname,
    "Pilotlname": pilotlname == null ? null : pilotlname,
    "PhotoPath": photoPath == null ? null : photoPath,
    "MemberShipType": memberShipType == null ? null : memberShipType,
    "ratingCount": ratingCount == null ? null : ratingCount,
  };
}
