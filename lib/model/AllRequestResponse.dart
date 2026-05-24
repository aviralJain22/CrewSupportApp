// To parse this JSON data, do
//
//     final allRequestResponse = allRequestResponseFromJson(jsonString);


import 'dart:convert';

AllRequestResponse allRequestResponseFromJson(String str) => AllRequestResponse.fromJson(json.decode(str));

//String allRequestResponseToJson(AllRequestResponse data) => json.encode(data.toJson());

class AllRequestResponse {
  AllRequestResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  Data? data;

  factory AllRequestResponse.fromJson(Map<String, dynamic> json) => AllRequestResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? "" : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  // Map<String, dynamic> toJson() => {
  //   "flag": flag == null ? null : flag,
  //   "msg": msg == null ? null : msg,
  //   "Code": code == null ? null : code,
  //   "data": data == null ? null : data.toJson(),
  // };
}

class Data {
  Data({
    required this.requests,
  });

  List<Request>? requests;

  Data.fromJson(Map<String, dynamic> json) {
    if (json['Requests'] != null) {
      requests = <Request>[];
      json['Requests'].forEach((v) {
        requests!.add(new Request.fromJson(v));
      });
    }
  }

  //  factory Data.fromJson(Map<String, dynamic> json) => Data(
  //   requests: json["Requests"] == null ? [] : List<Request>.from(json["Requests"].map((x) => Request.fromJson(x))),
  // );

  // Map<String, dynamic> toJson() => {
  //   "Requests": requests == null ? [] : List<dynamic>.from(requests.map((x) => x.toJson())),
  // };
}

class Request {
  Request({
    required this.pkRequestId,
    required this.fromPilotId,
    required this.toPilotId,
    required this.isAccepted,
    required this.isRejected,
    required this.receivername,
    required this.sendername,
    required this.memberShipType,
    required this.photoPath,
    required this.notification,
    required this.userId,
    required this.entryDate,
    required this.isVoid,
    required this.requestStatus,
    required this.extraField1,
    required this.extraField2,
    required this.extraField3,
    required this.oppositepilotid,
    required this.loggedinpilotid,
    required this.photopath,
    required this.oppositeName,
    required this.pkpilotid,
    required this.isRecent,
    // required this.linkedInProfile
  });

  int pkRequestId;
  int fromPilotId;
  int toPilotId;
  bool isAccepted;
  bool isRejected;
  String receivername;
  String sendername;
  String memberShipType;
  String photoPath;
  String notification;
  int userId;
  String entryDate;
  bool isVoid;
  int requestStatus;
  String extraField1;
  String extraField2;
  String extraField3;
  int oppositepilotid;
  int loggedinpilotid;
  String photopath;
  String oppositeName;
  int pkpilotid;
  int isRecent;
  // String linkedInProfile;

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    pkRequestId: json["pkRequestId"] == null ? null : json["pkRequestId"],
    fromPilotId: json["FromPilotId"] == null ? null : json["FromPilotId"],
    toPilotId: json["ToPilotId"] == null ? null : json["ToPilotId"],
    isAccepted: json["isAccepted"] == null ? null : json["isAccepted"],
    isRejected: json["isRejected"] == null ? null : json["isRejected"],
    receivername: json["receivername"] == null ? null : json["receivername"],
    sendername: json["sendername"] == null ? null : json["sendername"],
    memberShipType: json["MemberShipType"] == null ? null : json["MemberShipType"],
    photoPath: json["PhotoPath"] == null ? null : json["PhotoPath"],
    notification: json["Notification"] == null ? null : json["Notification"],
    userId: json["UserId"] == null ? null : json["UserId"],
    entryDate: json["EntryDate"] == null ? null : json["EntryDate"],
    isVoid: json["isVoid"] == null ? null : json["isVoid"],
    requestStatus: json["requestStatus"] == null ? null : json["requestStatus"],
    extraField1: json["ExtraField1"] == null ? null : json["ExtraField1"],
    extraField2: json["ExtraField2"] == null ? null : json["ExtraField2"],
    extraField3: json["ExtraField3"] == null ? null : json["ExtraField3"],
    oppositepilotid: json["oppositepilotid"] == null ? null : json["oppositepilotid"],
    loggedinpilotid: json["loggedinpilotid"] == null ? null : json["loggedinpilotid"],
    photopath: json["photopath"] == null ? null : json["photopath"],
    oppositeName: json["oppositeName"] == null ? null : json["oppositeName"],
    pkpilotid: json["pkpilotid"] == null ? null : json["pkpilotid"],
    isRecent: json["IsRecent"] == null ? null : json["IsRecent"],
    // linkedInProfile: json['linkedInProfile'] == null ? null : json["linkedInProfile"],
  );

  Map<String, dynamic> toJson() => {
    "pkRequestId": pkRequestId == null ? null : pkRequestId,
    "FromPilotId": fromPilotId == null ? null : fromPilotId,
    "ToPilotId": toPilotId == null ? null : toPilotId,
    "isAccepted": isAccepted == null ? null : isAccepted,
    "isRejected": isRejected == null ? null : isRejected,
    "receivername": receivername == null ? null : receivername,
    "sendername": sendername == null ? null : sendername,
    "MemberShipType": memberShipType == null ? null : memberShipType,
    "PhotoPath": photoPath == null ? null : photoPath,
    "Notification": notification == null ? null : notification,
    "UserId": userId == null ? null : userId,
    "EntryDate": entryDate == null ? null : entryDate,
    "isVoid": isVoid == null ? null : isVoid,
    "requestStatus": requestStatus == null ? null : requestStatus,
    "ExtraField1": extraField1 == null ? null : extraField1,
    "ExtraField2": extraField2 == null ? null : extraField2,
    "ExtraField3": extraField3 == null ? null : extraField3,
    "oppositepilotid": oppositepilotid == null ? null : oppositepilotid,
    "loggedinpilotid": loggedinpilotid == null ? null : loggedinpilotid,
    "photopath": photopath == null ? null : photopath,
    "oppositeName": oppositeName == null ? null : oppositeName,
    "pkpilotid": pkpilotid == null ? null : pkpilotid,
    "IsRecent": isRecent == null ? null : isRecent,
    // "linkedInProfile": linkedInProfile == null ? null : linkedInProfile,
  };
}
