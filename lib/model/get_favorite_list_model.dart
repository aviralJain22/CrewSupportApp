
import 'dart:convert';

class GetFavoriteModel {
  GetFavoriteModel({
     this.flag,
     this.msg,
     this.code,
     this.data,
     this.datas,
  });

  int? flag;
  String? msg;
  int? code;
  dynamic data;
  var datas;

  factory GetFavoriteModel.fromRawJson(String str) => GetFavoriteModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetFavoriteModel.fromJson(Map<String, dynamic> json) => GetFavoriteModel(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? "" : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"]== null ? "" : json["data"],
    datas: json["datas"] == null ? null : Datas.fromJson(json["datas"]),
  );

  Map<String, dynamic> toJson() => {
    "flag": flag == null ? null : flag,
    "msg": msg == null ? null : msg,
    "Code": code == null ? null : code,
    "data": data,
    "datas": datas == null ? [] : datas!.toJson(),
  };
}

class Datas {
  Datas({
     this.favourites,
  });

  List<Favourite>? favourites;

  factory Datas.fromRawJson(String str) => Datas.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datas.fromJson(Map<String, dynamic> json) => Datas(
    favourites: json["favourites"] == null ? [] : List<Favourite>.from(json["favourites"].map((x) => Favourite.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "favourites": favourites == null ? null : List<dynamic>.from(favourites!.map((x) => x.toJson())),
  };
}

class Favourite {
  Favourite({
     this.pkFavId,
    this.fkUserId,
     this.fkPilotid,
     this.entryDate,
     this.isFavourite,
     this.pilotFname,
     this.pilotmname,
     this.pilotlname,
     this.photoPath,
     this.memberShipType,
     this.ratingCount,
  });

  int? pkFavId;
  int? fkUserId;
  int? fkPilotid;
  String? entryDate;
  bool? isFavourite;
  String? pilotFname;
  String? pilotmname;
  String? pilotlname;
  String? photoPath;
  String? memberShipType;
  String? ratingCount;

  factory Favourite.fromRawJson(String str) => Favourite.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

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
