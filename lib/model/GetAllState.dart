import 'dart:convert';

GetAllState getAllStateFromJson(String str) => GetAllState.fromJson(json.decode(str));

String getAllStateToJson(GetAllState data) => json.encode(data.toJson());

class GetAllState {
  GetAllState({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  StateData data;

  factory GetAllState.fromJson(Map<String, dynamic> json) =>
      GetAllState(
        flag: json["flag"],
        msg: json["msg"],
        code: json["Code"],
        data: StateData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "flag": flag,
    "msg": msg,
    "Code": code,
    "data": data.toJson(),
  };
}

class StateData {
  StateData({
    required this.pilots,
    required this.sic,
    required this.fa,
    required this.fi,
    required this.city,
    required this.state,
    required this.availList,
  });

  dynamic pilots;
  dynamic sic;
  dynamic fa;
  dynamic fi;
  dynamic city;
  List<States> state;
  dynamic availList;

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
    pilots: json["Pilots"],
    sic: json["SIC"],
    fa: json["FA"],
    fi: json["FI"],
    city: json["City"],
    state: List<States>.from(json["State"].map((x) => States.fromJson(x))),
    availList: json["AvailList"],
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots,
    "SIC": sic,
    "FA": fa,
    "FI": fi,
    "City": city,
    "State": List<dynamic>.from(state.map((x) => x.toJson())),
    "AvailList": availList,
  };
}



class States {
  States({
    required this.stateId,
    required this.stateName,
    required this.stateCode,
  });

  int stateId;
  String stateName;
  String stateCode;

  factory States.fromJson(Map<String, dynamic> json) => States(
    stateId: json["StateId"],
    stateName: json["StateName"],
    stateCode: json["StateCode"],
  );

  Map<String, dynamic> toJson() => {
    "StateId": stateId,
    "StateName": stateName,
    "StateCode": stateCode,
  };
}

