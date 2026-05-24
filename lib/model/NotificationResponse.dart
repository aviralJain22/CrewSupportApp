// To parse this JSON data, do
//
//     final notificationResponse = notificationResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

NotificationResponse notificationResponseFromJson(String str) => NotificationResponse.fromJson(json.decode(str));

//String notificationResponseToJson(NotificationResponse data) => json.encode(data.toJson());

class NotificationResponse {
  NotificationResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  Data? data;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) => NotificationResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? null : json["msg"],
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
    required this.notification,
  });

  List<Notifications> notification;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    notification: json["Notification"] == null ? [] : List<Notifications>.from(json["Notification"].map((x) => Notifications.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Notification": notification == null ? null : List<dynamic>.from(notification.map((x) => x.toJson())),
  };
}

class Notifications {
  Notifications({
    required this.pkNotifyId,
    required this.oppositePilotId,
    required this.fkPilotId,
    required this.fkRequestId,
    required this.summary,
    required this.photoPath,
    required this.oppositePilotName,
    required this.requestStatus,
    required this.isRecent,
    this.IsRead,
  });

  int pkNotifyId;
  int oppositePilotId;
  int fkPilotId;
  int fkRequestId;
  String summary;
  String photoPath;
  String oppositePilotName;
  int requestStatus;
  int isRecent;
  bool? IsRead;

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
    pkNotifyId: json["pkNotifyId"] == null ? null : json["pkNotifyId"],
    oppositePilotId: json["oppositePilotId"] == null ? null : json["oppositePilotId"],
    fkPilotId: json["fkPilotId"] == null ? null : json["fkPilotId"],
    fkRequestId: json["fkRequestId"] == null ? null : json["fkRequestId"],
    summary: json["summary"] == null ? null : json["summary"],
    photoPath: json["photoPath"] == null ? null : json["photoPath"],
    oppositePilotName: json["oppositePilotName"] == null ? null : json["oppositePilotName"],
    requestStatus: json["requestStatus"] == null ? null : json["requestStatus"],
    isRecent: json["IsRecent"] == null ? null : json["IsRecent"],
    IsRead: json["IsRead"] == null ? null : json["IsRead"],
  );

  Map<String, dynamic> toJson() => {
    "pkNotifyId": pkNotifyId == null ? null : pkNotifyId,
    "oppositePilotId": oppositePilotId == null ? null : oppositePilotId,
    "fkPilotId": fkPilotId == null ? null : fkPilotId,
    "fkRequestId": fkRequestId == null ? null : fkRequestId,
    "summary": summary == null ? null : summary,
    "photoPath": photoPath == null ? null : photoPath,
    "oppositePilotName": oppositePilotName == null ? null : oppositePilotName,
    "requestStatus": requestStatus == null ? null : requestStatus,
    "IsRecent": isRecent == null ? null : isRecent,
    "IseRead": IsRead == null ? null : IsRead,
  };
}
