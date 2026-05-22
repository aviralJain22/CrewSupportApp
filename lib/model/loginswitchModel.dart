import 'package:crew_support/model/GetLoginDataResponse.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

GetSwitchLoginDataResponse getSwitchLoginDataResponseFromJson(String str) => GetSwitchLoginDataResponse.fromJson(json.decode(str));

String getSwitchLoginDataResponseToJson(GetSwitchLoginDataResponse data) => json.encode(data.toJson());

class GetSwitchLoginDataResponse {
  GetSwitchLoginDataResponse({
    required this.userdata,
  });

  List<Userdatum> userdata;

  factory GetSwitchLoginDataResponse.mock() => GetSwitchLoginDataResponse(
    userdata: [
      Userdatum(
        pkPilotId: 1001,
        pilotFname: "John",
        pilotLname: "Doe",
        emailId: "pilot@test.com",
        companyName: "Test Airlines",
        memberShipType: "Pilot",
        fkMemberShipId: 3,
        cellNumber: "+15550001",
        photoPath: "https://i.pravatar.cc/150?u=pilot",
        currentLocation: true,
        cuLocCountry: "USA",
      ),
      Userdatum(
        pkPilotId: 1002,
        pilotFname: "Jane",
        pilotLname: "Smith",
        emailId: "attendant@test.com",
        companyName: "Test Airlines",
        memberShipType: "Flight Attendant",
        fkMemberShipId: 4,
        cellNumber: "+15550002",
        photoPath: "https://i.pravatar.cc/150?u=attendant",
        currentLocation: true,
        cuLocCountry: "USA",
      ),
    ],
  );


  factory GetSwitchLoginDataResponse.fromJson(Map<String, dynamic> json) => GetSwitchLoginDataResponse(
    userdata:  List<Userdatum>.from(json["userdata"].map((x) => Userdatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userdata": List<dynamic>.from(userdata.map((x) => x.toJson())),
  };
}

class Userdatum {


  int? pkPilotId;
  String? pilotFname;
  String? pilotMname;
  String? pilotLname;
  String? pilotNname;
  String? companyName;
  bool? currentLocation;
  String? cuLocCountry;
  int? fkMemberShipId;
  String? memberShipType;
  String? emailId;
  String? oldPssword;
  String? newPassword;
  String? photoPath;
  String? cellNumber;
  String? workNumber;
  String? totalTime;
  String? connectionType;
  String? timeOfInstruct;
  List<Availability>? availability;
  Userdatum({
     this.pkPilotId,
     this.pilotFname,
     this.pilotMname,
     this.pilotLname,
     this.pilotNname,
     this.companyName,
     this.currentLocation,
     this.cuLocCountry,
     this.fkMemberShipId,
     this.memberShipType,
     this.emailId,
     this.oldPssword,
     this.newPassword,
     this.photoPath,
     this.cellNumber,
     this.workNumber,
     this.totalTime,
    this.connectionType,
     this.timeOfInstruct,
     this.availability
  });



  Userdatum.fromJson(Map<String, dynamic> json) {
    pkPilotId=  json["pkPilotId"];
    pilotFname=   json["PilotFname"];
    pilotMname= json["PilotMname"];
    pilotLname=  json["PilotLname"];
    pilotNname=  json["PilotNname"];
    companyName=  json["CompanyName"];
    currentLocation=  json["CurrentLocation"];
    cuLocCountry=  json["CuLocCountry"];
    fkMemberShipId=  json["fkMemberShipId"];
    memberShipType=  json["MemberShipType"];
    emailId=  json["EmailId"];
    oldPssword=  json["OldPssword"];
    newPassword=  json["NewPassword"];
    photoPath=json["PhotoPath"];
    cellNumber= json["cellNumber"];
    workNumber=  json["WorkNumber"];
    totalTime=  json["TotalTime"];
    connectionType = json['connectionType'];
    timeOfInstruct=  json["TimeOfInstruct"];
      if (json['Availability'] != null) {
  availability = <Availability>[];
  json['Availability'].forEach((v) {
  availability!.add(new Availability.fromJson(v));
  });
}}




  Map<String, dynamic> toJson() => {
    "pkPilotId": pkPilotId == null ? null : pkPilotId,
    "PilotFname": pilotFname == null ? null : pilotFname,
    "PilotMname": pilotMname == null ? null : pilotMname,
    "PilotLname": pilotLname == null ? null : pilotLname,
    "PilotNname": pilotNname == null ? null : pilotNname,
    "CompanyName": companyName == null ? null : companyName,
    "CurrentLocation": currentLocation == null ? null : currentLocation,
    "CuLocCountry": cuLocCountry == null ? null : cuLocCountry,
    "fkMemberShipId": fkMemberShipId == null ? null : fkMemberShipId,
    "MemberShipType": memberShipType == null ? null : memberShipType,
    "EmailId": emailId == null ? null : emailId,
    "OldPssword": oldPssword == null ? null : oldPssword,
    "NewPassword": newPassword == null ? null : newPassword,
    "PhotoPath": photoPath == null ? null : photoPath,
    "cellNumber": cellNumber == null ? null : cellNumber,
    "WorkNumber": workNumber == null ? null : workNumber,
    "TotalTime": totalTime == null ? null : totalTime,
    "connectionType" :connectionType ?? '',
    "TimeOfInstruct": timeOfInstruct == null ? null : timeOfInstruct,
    "Availability": availability == null? []: this.availability!.map((v) => v.toJson()).toList()
  };
}
