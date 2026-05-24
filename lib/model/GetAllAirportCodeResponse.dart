class GetAllAirportCodeResponse {
  int? flag;
  int? totalCount;
  String? msg;
  int? code;
  //var data;
  AirportCodeData? data;

  GetAllAirportCodeResponse(
      {this.flag, this.totalCount, this.msg, this.code, this.data});

  GetAllAirportCodeResponse.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    totalCount = json['TotalCount'];
    msg = json['msg'];
    code = json['Code'];
    //data = json['data'];
    data = json['data'] != null ? new AirportCodeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flag'] = this.flag;
    data['TotalCount'] = this.totalCount;
    data['msg'] = this.msg;
    data['Code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AirportCodeData {
  List<AirportCode>? airportCode;

  AirportCodeData({this.airportCode});

  AirportCodeData.fromJson(Map<String, dynamic> json) {
    if (json['AirportCode'] != null) {
      airportCode = <AirportCode>[];
      json['AirportCode'].forEach((v) {
        airportCode!.add(new AirportCode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.airportCode != null) {
      data['AirportCode'] = this.airportCode!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AirportCode {
  int? pkAirportcodeId;
  String? cityName;
  String? country;
  String? airportCode;
  bool? isVoid;
  int? limit;
  String? name;

  AirportCode(
      {this.pkAirportcodeId,
        this.cityName,
        this.country,
        this.airportCode,
        this.isVoid,
        this.limit,
        this.name});

  AirportCode.fromJson(Map<String, dynamic> json) {
    pkAirportcodeId = json['pkAirportcodeId'];
    cityName = json['CityName'];
    country = json['Country'];
    airportCode = json['AirportCode'];
    isVoid = json['isVoid'];
    limit = json['Limit'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkAirportcodeId'] = this.pkAirportcodeId;
    data['CityName'] = this.cityName;
    data['Country'] = this.country;
    data['AirportCode'] = this.airportCode;
    data['isVoid'] = this.isVoid;
    data['Limit'] = this.limit;
    data['Name'] = this.name;
    return data;
  }
}
