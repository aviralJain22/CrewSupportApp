// Backward-compatible model for InsertTripResponse
// Accepts partial payloads and Parse Date objects ({"__type":"Date","iso":"..."})

import 'dart:convert';

InsertTripResponse insertTripResponseFromJson(String str) => InsertTripResponse.fromJson(json.decode(str));
String insertTripResponseToJson(InsertTripResponse data) => json.encode(data.toJson());

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    if (v is String) {
      return DateTime.parse(v);
    }
    if (v is Map && v.containsKey('iso')) {
      final iso = v['iso'];
      if (iso is String && iso.isNotEmpty) return DateTime.parse(iso);
    }
  } catch (_) {}
  return null;
}

T _as<T>(dynamic v, T fallback) {
  if (v == null) return fallback;
  try {
    return v as T;
  } catch (_) {
    return fallback;
  }
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) {
    final n = int.tryParse(v);
    return n ?? fallback;
  }
  return fallback;
}

double _asDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) {
    final n = double.tryParse(v);
    return n ?? fallback;
  }
  return fallback;
}

bool _asBool(dynamic v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return fallback;
}

class InsertTripResponse {
  InsertTripResponse({this.flag = 0, this.msg = '', this.code = 200, this.data});

  int flag;
  String msg;
  int code; // maps from "Code"
  Data? data;

  factory InsertTripResponse.fromJson(Map<String, dynamic> json) => InsertTripResponse(
        flag: _asInt(json['flag'], 0),
        msg: _as<String>(json['msg'], ''),
        code: _asInt(json['Code'], 200),
        data: json['data'] == null ? null : Data.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'flag': flag,
        'msg': msg,
        'Code': code,
        'data': data?.toJson(),
      };
}

class Data {
  Data({this.trip});
  Trip? trip;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        trip: json['Trip'] == null ? null : Trip.fromJson(json['Trip'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'Trip': trip?.toJson(),
      };
}

class Trip {
  Trip({
    this.pkTripId = 0,
    this.fkPIlotid = 0,
    this.partialAmount = '',
    this.offsetAmount = '',
    this.fkAircraftId,
    this.aircraftType = '',
    this.loggedinid = 0,
    this.tripName = '',
    this.tripCreater = '',
    this.captain,
    this.finalPilotid = 0,
    this.secondInCommand,
    this.finalSecondInCommand = 0,
    this.flightAttendant,
    this.finalFlightAttendant = 0,
    this.flightInstructor,
    this.finalFlightInstructor = 0,
    this.pilotRate = 0.0,
    this.sicRate = 0.0,
    this.faRate = 0.0,
    this.fiRate = 0.0,
    this.updatepilotRate = 0.0,
    this.updateSicRate = 0.0,
    this.updateFaRate = 0.0,
    this.updateFiRate = 0.0,
    this.destinationCode = '',
    this.departureCode = '',
    this.enrouteAirportCode = '',
    this.depaLocaton = '',
    this.destLocation = '',
    this.isRecent = false,
    this.isCancelled = false,
    this.tripStartDate,
    this.tripEndDate,
    this.nearMeCaptain,
    this.isVoid = false,
    this.entryDate,
    this.oppositid = 0,
    this.amount = '',
    this.isfavourite = '',
    this.aircraftTotalTime = '',
    this.totalTimeAircraftId = '',
    this.picTimeAircraftId = '',
    this.aircraftPiCtime = '',
    this.faaMedical = 0,
    this.havePassport = false,
    this.rating = '',
    this.ratingAirCraftType = '',
    this.continent = '',
    this.ocean = '',
    this.isReqPrev12MonthTraining = false,
    this.rate = 0.0,
    this.ratingCount = '',
    this.yearexp = '',
    this.spTraining = '',
    this.specialTrainedOther = '',
    this.visa = false,
    this.currentUnrestrictedUsPass = false,
    this.langSpoken = '',
    this.showprofile = 0,
    this.aircraftSpecifictraining = false,
    this.totalTime = '',
    this.timeOfInstruct = '',
    this.complexTimeReqr = '',
    this.highPerfomanceTime = '',
    this.instrumentInstructor = false,
    this.mulEngInstructor = false,
    this.tailWheelInsrtuctor = false,
    this.acrobaticsInstructor = false,
  });

  int pkTripId;
  int fkPIlotid;
  String partialAmount;
  String offsetAmount;
  int? fkAircraftId;
  String aircraftType;
  int loggedinid;
  String tripName;
  String tripCreater;
  dynamic captain; // bool or number
  int finalPilotid;
  dynamic secondInCommand; // bool or number
  int finalSecondInCommand;
  dynamic flightAttendant; // bool or number
  int finalFlightAttendant;
  dynamic flightInstructor; // bool or number
  int finalFlightInstructor;
  double pilotRate;
  double sicRate;
  double faRate;
  double fiRate;
  double updatepilotRate;
  double updateSicRate;
  double updateFaRate;
  double updateFiRate;
  String destinationCode;
  String departureCode;
  String enrouteAirportCode;
  String depaLocaton;
  String destLocation;
  bool isRecent;
  bool isCancelled;
  DateTime? tripStartDate;
  DateTime? tripEndDate;
  dynamic nearMeCaptain;
  bool isVoid;
  DateTime? entryDate;
  int oppositid;
  String amount;
  String isfavourite;
  String aircraftTotalTime;
  String totalTimeAircraftId;
  String picTimeAircraftId;
  String aircraftPiCtime;
  int faaMedical;
  bool havePassport;
  String rating;
  String ratingAirCraftType;
  String continent;
  String ocean;
  bool isReqPrev12MonthTraining;
  double rate;
  String ratingCount;
  String yearexp;
  String spTraining;
  String specialTrainedOther;
  bool visa;
  bool currentUnrestrictedUsPass;
  String langSpoken;
  int showprofile;
  bool aircraftSpecifictraining;
  String totalTime;
  String timeOfInstruct;
  String complexTimeReqr;
  String highPerfomanceTime;
  bool instrumentInstructor;
  bool mulEngInstructor;
  bool tailWheelInsrtuctor;
  bool acrobaticsInstructor;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        pkTripId: _asInt(json['pkTripId'], 0),
        fkPIlotid: _asInt(json['fkPIlotid'], 0),
        partialAmount: _as<String>(json['PartialAmount'], ''),
        offsetAmount: _as<String>(json['OffsetAmount'], ''),
        fkAircraftId: json['fkAircraftId'] == null ? null : _asInt(json['fkAircraftId']),
        aircraftType: _as<String>(json['AircraftType'], ''),
        loggedinid: _asInt(json['loggedinid'], 0),
        tripName: _as<String>(json['TripName'], ''),
        tripCreater: _as<String>(json['TripCreater'], ''),
        captain: json['Captain'],
        finalPilotid: _asInt(json['finalPilotid'], 0),
        secondInCommand: json['SecondInCommand'],
        finalSecondInCommand: _asInt(json['finalSecondInCommand'], 0),
        flightAttendant: json['FlightAttendant'],
        finalFlightAttendant: _asInt(json['finalFlightAttendant'], 0),
        flightInstructor: json['FlightInstructor'],
        finalFlightInstructor: _asInt(json['finalFlightInstructor'], 0),
        pilotRate: _asDouble(json['pilotRate'], 0.0),
        sicRate: _asDouble(json['SICRate'], 0.0),
        faRate: _asDouble(json['FARate'], 0.0),
        fiRate: _asDouble(json['FIRate'], 0.0),
        updatepilotRate: _asDouble(json['updatepilotRate'], 0.0),
        updateSicRate: _asDouble(json['updateSICRate'], 0.0),
        updateFaRate: _asDouble(json['updateFARate'], 0.0),
        updateFiRate: _asDouble(json['updateFIRate'], 0.0),
        destinationCode: _as<String>(json['DestinationCode'], ''),
        departureCode: _as<String>(json['DepartureCode'], ''),
        enrouteAirportCode: _as<String>(json['enroute_airportCode'], ''),
        depaLocaton: _as<String>(json['DepaLocaton'], ''),
        destLocation: _as<String>(json['DestLocation'], ''),
        isRecent: _asBool(json['IsRecent'], false),
        isCancelled: _asBool(json['IsCancelled'], false),
        tripStartDate: _parseDate(json['tripStartDate']),
        tripEndDate: _parseDate(json['tripEndDate']),
        nearMeCaptain: json['nearMeCaptain'],
        isVoid: _asBool(json['isVoid'], false),
        entryDate: _parseDate(json['EntryDate']),
        oppositid: _asInt(json['oppositid'], 0),
        amount: _as<String>(json['amount'], ''),
        isfavourite: _as<String>(json['isfavourite'], ''),
        aircraftTotalTime: _as<String>(json['AircraftTotalTime'], ''),
        totalTimeAircraftId: _as<String>(json['TotalTimeAircraftId'], ''),
        picTimeAircraftId: _as<String>(json['PICTimeAircraftId'], ''),
        aircraftPiCtime: _as<String>(json['AircraftPICtime'], ''),
        faaMedical: _asInt(json['FAAMedical'], 0),
        havePassport: _asBool(json['HavePassport'], false),
        rating: _as<String>(json['rating'], ''),
        ratingAirCraftType: _as<String>(json['ratingAirCraftType'], ''),
        continent: _as<String>(json['Continent'], ''),
        ocean: _as<String>(json['Ocean'], ''),
        isReqPrev12MonthTraining: _asBool(json['IsReqPrev12MonthTraining'], false),
        rate: _asDouble(json['rate'], 0.0),
        ratingCount: _as<String>(json['RatingCount'], ''),
        yearexp: _as<String>(json['YEAREXP'], ''),
        spTraining: _as<String>(json['SP_TRAINING'], ''),
        specialTrainedOther: _as<String>(json['SpecialTrainedOther'], ''),
        visa: _asBool(json['VISA'], false),
        currentUnrestrictedUsPass: _asBool(json['CurrentUnrestrictedUSPass'], false),
        langSpoken: _as<String>(json['LANG_SPOKEN'], ''),
        showprofile: _asInt(json['SHOWPROFILE'], 0),
        aircraftSpecifictraining: _asBool(json['AircraftSpecifictraining'], false),
        totalTime: _as<String>(json['TotalTime'], ''),
        timeOfInstruct: _as<String>(json['TimeOfInstruct'], ''),
        complexTimeReqr: _as<String>(json['complexTimeReqr'], ''),
        highPerfomanceTime: _as<String>(json['highPerfomanceTime'], ''),
        instrumentInstructor: _asBool(json['InstrumentInstructor'], false),
        mulEngInstructor: _asBool(json['MulEngInstructor'], false),
        tailWheelInsrtuctor: _asBool(json['tailWheelInsrtuctor'], false),
        acrobaticsInstructor: _asBool(json['acrobaticsInstructor'], false),
      );

  Map<String, dynamic> toJson() => {
        'pkTripId': pkTripId,
        'fkPIlotid': fkPIlotid,
        'PartialAmount': partialAmount,
        'OffsetAmount': offsetAmount,
        'fkAircraftId': fkAircraftId,
        'AircraftType': aircraftType,
        'loggedinid': loggedinid,
        'TripName': tripName,
        'TripCreater': tripCreater,
        'Captain': captain,
        'finalPilotid': finalPilotid,
        'SecondInCommand': secondInCommand,
        'finalSecondInCommand': finalSecondInCommand,
        'FlightAttendant': flightAttendant,
        'finalFlightAttendant': finalFlightAttendant,
        'FlightInstructor': flightInstructor,
        'finalFlightInstructor': finalFlightInstructor,
        'pilotRate': pilotRate,
        'SICRate': sicRate,
        'FARate': faRate,
        'FIRate': fiRate,
        'updatepilotRate': updatepilotRate,
        'updateSICRate': updateSicRate,
        'updateFARate': updateFaRate,
        'updateFIRate': updateFiRate,
        'DestinationCode': destinationCode,
        'DepartureCode': departureCode,
        'enroute_airportCode': enrouteAirportCode,
        'DepaLocaton': depaLocaton,
        'DestLocation': destLocation,
        'IsRecent': isRecent,
        'IsCancelled': isCancelled,
        'tripStartDate': tripStartDate?.toIso8601String(),
        'tripEndDate': tripEndDate?.toIso8601String(),
        'nearMeCaptain': nearMeCaptain,
        'isVoid': isVoid,
        'EntryDate': entryDate?.toIso8601String(),
        'oppositid': oppositid,
        'amount': amount,
        'isfavourite': isfavourite,
        'AircraftTotalTime': aircraftTotalTime,
        'TotalTimeAircraftId': totalTimeAircraftId,
        'PICTimeAircraftId': picTimeAircraftId,
        'AircraftPICtime': aircraftPiCtime,
        'FAAMedical': faaMedical,
        'HavePassport': havePassport,
        'rating': rating,
        'ratingAirCraftType': ratingAirCraftType,
        'Continent': continent,
        'Ocean': ocean,
        'IsReqPrev12MonthTraining': isReqPrev12MonthTraining,
        'rate': rate,
        'RatingCount': ratingCount,
        'YEAREXP': yearexp,
        'SP_TRAINING': spTraining,
        'SpecialTrainedOther': specialTrainedOther,
        'VISA': visa,
        'CurrentUnrestrictedUSPass': currentUnrestrictedUsPass,
        'LANG_SPOKEN': langSpoken,
        'SHOWPROFILE': showprofile,
        'AircraftSpecifictraining': aircraftSpecifictraining,
        'TotalTime': totalTime,
        'TimeOfInstruct': timeOfInstruct,
        'complexTimeReqr': complexTimeReqr,
        'highPerfomanceTime': highPerfomanceTime,
        'InstrumentInstructor': instrumentInstructor,
        'MulEngInstructor': mulEngInstructor,
        'tailWheelInsrtuctor': tailWheelInsrtuctor,
        'acrobaticsInstructor': acrobaticsInstructor,
      };
}
