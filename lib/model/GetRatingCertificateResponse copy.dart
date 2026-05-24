
import 'dart:convert';

GetRatingCertificateResponse getRatingCertificateResponseFromJson(String str) => GetRatingCertificateResponse.fromJson(json.decode(str));


class GetRatingCertificateResponse {
  GetRatingCertificateResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

   int? flag;
   String? msg;
   int? code;
   Data? data;

  factory GetRatingCertificateResponse.fromJson(Map<String, dynamic> json) => GetRatingCertificateResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? null : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

}

class Data {
  Data({
    required this.ratingCertificates,
  });

   List<RatingCertificate>? ratingCertificates;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ratingCertificates: json["RatingCertificates"] == null ? [] : List<RatingCertificate>.from(json["RatingCertificates"].map((x) => RatingCertificate.fromJson(x))),
  );


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

   int? pkRatingCertiId;
   int? fkPilotid;
   String? ratingCertification;
   int? fkCategoryId;
   String? cetogoryType;
   int? fkClassId;
   String? classType;
   String? aircraftType;
   String? hours;
   String? pic;
  double? minimumRate;
   String? currentInType;
   DateTime? entryDate;
   bool? isReqPrev12MonthTraining;
   bool? isVoid;

  factory RatingCertificate.fromJson(Map<String, dynamic> json) => RatingCertificate(
    pkRatingCertiId: json["pkRatingCertiId"] == null ? null : json["pkRatingCertiId"],
    fkPilotid: json["fkPilotid"] == null ? null : json["fkPilotid"],
    ratingCertification: json["RatingCertification"] == null ? null : json["RatingCertification"],
    fkCategoryId: json["fkCategoryId"] == null ? null : json["fkCategoryId"],
    cetogoryType: json["CetogoryType"] == null ? null : json["CetogoryType"],
    fkClassId: json["fkClassId"] == null ? null : json["fkClassId"],
    classType: json["ClassType"] == null ? null : json["ClassType"],
    aircraftType: json["AirCraftType"] == null ? "" : json["AirCraftType"],
    hours: json["Hours"] == null ? null : json["Hours"],
    pic: json["PIC"] == null ? null : json["PIC"],
    minimumRate: json["MinimumRate"] == null ? null : json["MinimumRate"],
    currentInType: json["CurrentInType"] == null ? null : json["CurrentInType"],
    entryDate: json["EntryDate"] == null ? null : DateTime.parse(json["EntryDate"]),
    isReqPrev12MonthTraining: json["IsReqPrev12MonthTraining"] == null ? null : json["IsReqPrev12MonthTraining"],
    isVoid: json["isVoid"] == null ? null : json["isVoid"],
  );

  Map<String, dynamic> toJson() => {
    "pkRatingCertiId": pkRatingCertiId == null ? null : pkRatingCertiId,
    "fkPilotid": fkPilotid == null ? null : fkPilotid,
    "RatingCertification": ratingCertification == null ? null : ratingCertification,
    "fkCategoryId": fkCategoryId == null ? null : fkCategoryId,
    "CetogoryType": cetogoryType == null ? null : cetogoryType,
    "fkClassId": fkClassId == null ? null : fkClassId,
    "ClassType": classType == null ? null : classType,
    "AirCraftType": aircraftType == null ? "" : aircraftType,
    "Hours": hours == null ? null : hours,
    "PIC": pic == null ? null : pic,
    "MinimumRate": minimumRate == null ? null : minimumRate,
    "CurrentInType": currentInType == null ? null : currentInType,
    "EntryDate": entryDate == null ? null : entryDate,
    "IsReqPrev12MonthTraining": isReqPrev12MonthTraining == null ? null : isReqPrev12MonthTraining,
    "isVoid": isVoid == null ? null : isVoid,
  };
}
