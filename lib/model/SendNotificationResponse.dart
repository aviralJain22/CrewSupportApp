// To parse this JSON data, do
//
//     final sendNotificationResponse = sendNotificationResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

SendNotificationResponse sendNotificationResponseFromJson(String str) => SendNotificationResponse.fromJson(json.decode(str));

String sendNotificationResponseToJson(SendNotificationResponse data) => json.encode(data.toJson());

class SendNotificationResponse {
  SendNotificationResponse({
     required this.flag,
     required this.msg,
     required this.code,
    @required this.data,
  });

  int flag;
  String msg;
  int code;
  dynamic data;

  factory SendNotificationResponse.fromJson(Map<String, dynamic> json) => SendNotificationResponse(
    flag: json["flag"] == null ? null : json["flag"],
    msg: json["msg"] == null ? null : json["msg"],
    code: json["Code"] == null ? null : json["Code"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "flag": flag == null ? null : flag,
    "msg": msg == null ? null : msg,
    "Code": code == null ? null : code,
    "data": data,
  };
}
