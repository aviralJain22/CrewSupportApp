// To parse this JSON data, do
//
//     final chatMessageBetween = chatMessageBetweenFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class ChatMessageBetween {
  ChatMessageBetween({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  var data;

  factory ChatMessageBetween.fromRawJson(String str) => ChatMessageBetween.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatMessageBetween.fromJson(Map<String, dynamic> json) => ChatMessageBetween(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? "" : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"] == null ? [] : ChatData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "flag": flag == null ? null : flag,
    "msg": msg == null ? null : msg,
    "Code": code == null ? null : code,
    "data": data == null ? null : data.toJson(),
  };
}

class ChatData {
  ChatData({
     this.messages,
  });

  List<Message>? messages;

  factory ChatData.fromRawJson(String str) => ChatData.fromJson(json.decode(str));



  factory ChatData.fromJson(Map<String, dynamic> json) => ChatData(
    messages: json["Messages"] == null ? [] : List<Message>.from(json["Messages"].map((x) => Message.fromJson(x))),
  );


}

class Message {
  Message({
    required this.pkMessageId,
    required this.fkToPilotId,
    required this.fkFromPilotid,
    required this.message,
    required this.messageType,
    required this.receivername,
    required this.sendername,
    required this.photoPath,
    required this.isSend,
    required this.isReceive,
    required this.isDelete,
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
    required this.isRecent,
    required this.toid,
    required this.IsRead,
  });

  int pkMessageId;
  int fkToPilotId;
  int fkFromPilotid;
  String message;
  bool messageType;
  String receivername;
  String sendername;
  String photoPath;
  bool isSend;
  bool isReceive;
  bool isDelete;
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
  int isRecent;
  int toid;
  bool IsRead;

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    pkMessageId: json["pkMessageId"] == null ? null : json["pkMessageId"],
    fkToPilotId: json["fkToPilotId"] == null ? null : json["fkToPilotId"],
    fkFromPilotid: json["fkFromPilotid"] == null ? null : json["fkFromPilotid"],
    message: json["Message"] == null ? null : json["Message"],
    messageType: json["MessageType"] == null ? null : json["MessageType"],
    receivername: json["receivername"] == null ? null : json["receivername"],
    sendername: json["sendername"] == null ? null : json["sendername"],
    photoPath: json["PhotoPath"] == null ? null : json["PhotoPath"],
    isSend: json["IsSend"] == null ? null : json["IsSend"],
    isReceive: json["IsReceive"] == null ? null : json["IsReceive"],
    isDelete: json["IsDelete"] == null ? null : json["IsDelete"],
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
    isRecent: json["IsRecent"] == null ? null : json["IsRecent"],
    toid: json["toid"] == null ? null : json["toid"],
    IsRead: json["IsRead"] == null ? true : json["IsRead"],
  );

  Map<String, dynamic> toJson() => {
    "pkMessageId": pkMessageId == null ? null : pkMessageId,
    "fkToPilotId": fkToPilotId == null ? null : fkToPilotId,
    "fkFromPilotid": fkFromPilotid == null ? null : fkFromPilotid,
    "Message": message == null ? null : message,
    "MessageType": messageType == null ? null : messageType,
    "receivername": receivername == null ? null : receivername,
    "sendername": sendername == null ? null : sendername,
    "PhotoPath": photoPath == null ? null : photoPath,
    "IsSend": isSend == null ? null : isSend,
    "IsReceive": isReceive == null ? null : isReceive,
    "IsDelete": isDelete == null ? null : isDelete,
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
    "IsRecent": isRecent == null ? null : isRecent,
    "toid": toid == null ? null : toid,
    "IsRead": IsRead == null ? true : IsRead,
  };
}
