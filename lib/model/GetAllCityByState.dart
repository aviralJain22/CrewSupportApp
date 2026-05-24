import 'dart:convert';

GetAllCityByState getAllCityByStateFromJson(String str) =>
    GetAllCityByState.fromJson(json.decode(str));

String getAllCityByStateToJson(GetAllCityByState data) =>
    json.encode(data.toJson());

class GetAllCityByState {
  GetAllCityByState({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
  });

  int flag;
  String msg;
  int code;
  CityData data;

  factory GetAllCityByState.fromJson(Map<String, dynamic> json) =>
      GetAllCityByState(
        flag: json["flag"],
        msg: json["msg"],
        code: json["Code"],
        data: CityData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "flag": flag,
    "msg": msg,
    "Code": code,
    "data": data.toJson(),
  };
}

class CityData {
  CityData({
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
  List<City> city;
  dynamic state;
  dynamic availList;

  factory CityData.fromJson(Map<String, dynamic> json) => CityData(
    pilots: json["Pilots"],
    sic: json["SIC"],
    fa: json["FA"],
    fi: json["FI"],
    city: List<City>.from(json["City"].map((x) => City.fromJson(x))),
    state: json["State"],
    availList: json["AvailList"],
  );

  Map<String, dynamic> toJson() => {
    "Pilots": pilots,
    "SIC": sic,
    "FA": fa,
    "FI": fi,
    "City": List<dynamic>.from(city.map((x) => x.toJson())),
    "State": state,
    "AvailList": availList,
  };
}

class City {
  City({
    required this.cityId,
    required this.stateName,
    required this.cityName,
  });

  int cityId;
  String stateName;
  String cityName;

  factory City.fromJson(Map<String, dynamic> json) => City(
    cityId: json["CityId"],
    stateName: json["StateName"],
    cityName: json["CityName"],
  );

  Map<String, dynamic> toJson() => {
    "CityId": cityId,
    "StateName": stateName,
    "CityName": cityName,
  };
}