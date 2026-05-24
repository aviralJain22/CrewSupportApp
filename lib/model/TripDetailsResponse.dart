// To parse this JSON data, do
//
//     final tripDetailsResponse = tripDetailsResponseFromJson(jsonString);

import 'dart:convert';

TripDetailsResponse tripDetailsResponseFromJson(String str) =>
    TripDetailsResponse.fromJson(json.decode(str));

class TripDetailsResponse {
  TripDetailsResponse({
    required this.flag,
    required this.msg,
    required this.code,
    required this.data,
    required this.comment,
  });

  int flag;
  var comment;
  String msg;
  int code;
  TripDetailsData? data;

  factory TripDetailsResponse.fromJson(Map<String, dynamic> json) =>
      TripDetailsResponse(
        flag: json["flag"] == null ? null : json["flag"],
        comment: json['Commentmsg'] == null ? null : json['Commentmsg'],
        msg: json["msg"] == null ? null : json["msg"],
        code: json["Code"] == null ? null : json["Code"],
        data: json["data"] == null
            ? null
            : TripDetailsData.fromJson(json["data"]),
      );
}

class TripDetailsData {
  TripDetailsData({
    required this.trip,
    required this.summary,
    required this.shortsummary
  });

  List<TripDetails> trip;
  List<Summary> summary;
  List<ShortSummary> shortsummary;

  factory TripDetailsData.fromJson(Map<String, dynamic> json) =>
      TripDetailsData(
        trip: json["Trip"] == null
            ? []
            : List<TripDetails>.from(
            json["Trip"].map((x) => TripDetails.fromJson(x))),
        summary: json["Summary"] == null
            ? []
            : List<Summary>.from(
            json["Summary"].map((x) => Summary.fromJson(x))),
        shortsummary: json["ShortSummary"] == null
            ? []
            : List<ShortSummary>.from(
            json["ShortSummary"].map((x) => ShortSummary.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "Trip": trip == null
        ? null
        : List<dynamic>.from(trip.map((x) => x.toJson())),
    "Summary": summary == null
        ? null
        : List<dynamic>.from(summary.map((x) => x.toJson())),
    "ShortSummary": shortsummary == null
        ? null
        : List<dynamic>.from(shortsummary.map((x) => x.toJson())),
  };
}

class Summary {
  Summary({
    required this.photoPath,
    required this.type,
    required this.oppositId,
    required this.name,
    required this.designation,
    required this.negotiateAmount,
    required this.rattingForId,
    required this.rattingForDesignation,
    required this.comment,
    required this.rattingNum,
    required this.rattingFromName,
    required this.rattingFromId,
    required this.rattingFromDesignation,
    required this.message,
    required this.pkTripId,
    required this.entryDate,
    required this.isAlreadyAccepted,
    required this.isEscrow,
    required this.isPartial,
    required this.partialAmount,
    required this.commentmsg,
    required this.pkTripNotificationId,
    required this.toid,
  });

  String photoPath;
  String commentmsg;
  int type;
  int oppositId;
  int toid;
  String name;
  String designation;
  double negotiateAmount;
  String rattingForId;
  String rattingForDesignation;
  String comment;
  double rattingNum;
  String rattingFromName;
  int rattingFromId;
  String rattingFromDesignation;
  String message;
  int pkTripId;
  String entryDate;
  bool isAlreadyAccepted;
  bool isEscrow;
  bool isPartial;
  int pkTripNotificationId;
  double partialAmount;

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    toid: json["ToId"] == null ? "" : json["ToId"],
    commentmsg: json["Commentmsg"] == null ? '' : json["Commentmsg"],
    photoPath: json["PhotoPath"] == null ? null : json["PhotoPath"],
    type: json["type"] == null ? null : json["type"],
    oppositId: json["oppositId"] == null ? null : json["oppositId"],
    name: json["Name"] == null ? null : json["Name"],
    designation: json["Designation"] == null ? null : json["Designation"],
    negotiateAmount:
    json["negotiateAmount"] == null ? null : json["negotiateAmount"],
    rattingForId:
    json["RattingForId"] == null ? null : json["RattingForId"],
    rattingForDesignation: json["RattingForDesignation"] == null
        ? null
        : json["RattingForDesignation"],
    comment: json["Comment"] == null ? null : json["Comment"],
    rattingNum: json["RattingNum"] == null ? null : json["RattingNum"],
    rattingFromName:
    json["RattingFromName"] == null ? null : json["RattingFromName"],
    rattingFromId:
    json["RattingFromId"] == null ? null : json["RattingFromId"],
    rattingFromDesignation: json["RattingFromDesignation"] == null
        ? null
        : json["RattingFromDesignation"],
    message: json["Message"] == null ? null : json["Message"],
    pkTripId: json["pkTripId"] == null ? null : json["pkTripId"],
    entryDate: json["EntryDate"] == null ? null : json["EntryDate"],
    isAlreadyAccepted: json["IsAlreadyAccepted"] == null
        ? null
        : json["IsAlreadyAccepted"],
    isEscrow: json["IsEscrow"] == null ? null : json["IsEscrow"],
    isPartial: json["IsPartial"] == null ? null : json["IsPartial"],
    pkTripNotificationId: json["pkTripNotificationId"] == null ? null : json["pkTripNotificationId"],
    partialAmount:
    json["PartialAmount"] == null ? null : json["PartialAmount"],
  );

  Map<String, dynamic> toJson() => {
    "ToId": toid == null ? null : toid,
    "Commentmsg": commentmsg == null ? null : commentmsg,
    "PhotoPath": photoPath == null ? null : photoPath,
    "type": type == null ? null : type,
    "oppositId": oppositId == null ? null : oppositId,
    "Name": name == null ? null : name,
    "Designation": designation == null ? null : designation,
    "negotiateAmount": negotiateAmount == null ? null : negotiateAmount,
    "RattingForId": rattingForId == null ? null : rattingForId,
    "RattingForDesignation":
    rattingForDesignation == null ? null : rattingForDesignation,
    "Comment": comment == null ? null : comment,
    "RattingNum": rattingNum == null ? null : rattingNum,
    "RattingFromName": rattingFromName == null ? null : rattingFromName,
    "RattingFromId": rattingFromId == null ? null : rattingFromId,
    "RattingFromDesignation":
    rattingFromDesignation == null ? null : rattingFromDesignation,
    "Message": message == null ? null : message,
    "pkTripId": pkTripId == null ? null : pkTripId,
    "EntryDate": entryDate == null ? null : entryDate,
    "IsAlreadyAccepted":
    isAlreadyAccepted == null ? null : isAlreadyAccepted,
    "IsEscrow": isEscrow == null ? null : isEscrow,
    "IsPartial": isPartial == null ? null : isPartial,
    "pkTripNotificationId": pkTripNotificationId == null ? null : pkTripNotificationId,
    "PartialAmount": partialAmount == null ? null : partialAmount,
  };
}

class ShortSummary {
  ShortSummary({
    required this.photoPath,
    required this.oppositId,
    required this.name,
    required this.designation,
  });

  String photoPath;
  int oppositId;
  String name;
  String designation;

  factory ShortSummary.fromJson(Map<String, dynamic> json) => ShortSummary(
    photoPath: json["PhotoPath"] == null ? null : json["PhotoPath"],
    oppositId: json["oppositId"] == null ? null : json["oppositId"],
    name: json["Name"] == null ? null : json["Name"],
    designation: json["Designation"] == null ? null : json["Designation"],
  );

  Map<String, dynamic> toJson() => {
    "PhotoPath": photoPath == null ? null : photoPath,
    "oppositId": oppositId == null ? null : oppositId,
    "Name": name == null ? null : name,
    "Designation": designation == null ? null : designation,
  };
}

class TripDetails {
  TripDetails(
      {required this.speacialtrainingbool,
        required this.sp_traning_other,
        required this.isshowprofile,
        required this.pkTripId,
        required this.fkPIlotid,
        required this.partialAmount,
        required this.offsetAmount,
        required this.fkAircraftId,
        required this.aircraftType,
        required this.loggedinid,
        required this.tripName,
        required this.tripCreater,
        required this.captain,
        required this.finalPilotid,
        required this.secondInCommand,
        required this.finalSecondInCommand,
        required this.flightAttendant,
        required this.finalFlightAttendant,
        required this.flightInstructor,
        required this.finalFlightInstructor,
        required this.pilotRate,
        required this.sicRate,
        required this.faRate,
        required this.fiRate,
        required this.updatepilotRate,
        required this.updateSicRate,
        required this.updateFaRate,
        required this.updateFiRate,
        required this.destinationCode,
        required this.departureCode,
        required this.enrouteAirportCode,
        required this.depaLocaton,
        required this.destLocation,
        required this.isRecent,
        required this.isCancelled,
        required this.tripStartDate,
        required this.tripEndDate,
        required this.nearMeCaptain,
        required this.isVoid,
        required this.entryDate,
        required this.oppositid,
        required this.amount,
        required this.isfavourite,
        required this.aircraftTotalTime,
        required this.totalTimeAircraftId,
        required this.picTimeAircraftId,
        required this.aircraftPiCtime,
        required this.faaMedical,
        required this.havePassport,
        required this.rating,
        required this.ratingAirCraftType,
        required this.continent,
        required this.ocean,
        required this.isReqPrev12MonthTraining,
        required this.rate,
        required this.ratingCount,
        required this.yearexp,
        required this.spTraining,
        required this.specialTrainedOther,
        required this.visa,
        required this.currentUnrestrictedUsPass,
        required this.langSpoken,
        required this.showprofile,
        required this.aircraftSpecifictraining,
        required this.totalTime,
        required this.timeOfInstruct,
        required this.complexTimeReqr,
        required this.highPerfomanceTime,
        required this.instrumentInstructor,
        required this.mulEngInstructor,
        required this.tailWheelInsrtuctor,
        required this.acrobaticsInstructor,
        required this.radius,
        required this.internationalvisa,
        required this.totalTimeInstructor,
        required this.ratingcountInstruct,
        required this.speacialtrainingbool2,

        required this.IsReqPrev12MonthTraining_FA,
        required this.AircraftTotalTimeSIC,
        required this.TotalTimeAircraftIdSIC,
        required this.FAAMedicalSIC,
        required this.HavePassportSIC,
        required this.ratingSIC,
        required this.ratingAirCraftTypeSIC,
        required this.ContinentSIC,
        required this.IsReqPrev12MonthTrainingSIC,
        required this.rateSIC,
        required this.RatingCountSIC,
        required this.YEAREXP_FA,
        required this.IsSpecialTraining_FA,
        required this.LANG_SPOKEN_FA,
        required this.IsShowprofile_FA,
        required this.AircraftSpecifictraining_FA,
        required this.InternationalVisaHeld_FA,
        this.MultipleAmt,
        required this.HavePassPort_FA,
        required this.HideGender_FA,
        required this.IsExpiredTrip,
        required this.IsDirectTrip,
        required this.SpecTraining_FA,});

  var sp_traning_other;
  var radius;
  int pkTripId;
  int fkPIlotid;
  String partialAmount;
  String offsetAmount;
  var fkAircraftId;
  String aircraftType;
  int loggedinid;
  String tripName;
  String tripCreater;
  var captain;
  var finalPilotid;
  var secondInCommand;
  var finalSecondInCommand;
  var flightAttendant;
  var finalFlightAttendant;
  var flightInstructor;
  var finalFlightInstructor;
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
  String tripStartDate;
  String tripEndDate;
  int nearMeCaptain;
  bool isVoid;
  String entryDate;
  int oppositid;
  String amount;
  String isfavourite;
  String aircraftTotalTime;
  String totalTimeAircraftId;
  String picTimeAircraftId;
  String aircraftPiCtime;
  int faaMedical;
  int FAAMedicalSIC;
  bool havePassport;
  bool HavePassportSIC;
  String rating;
  String ratingAirCraftType;
  String continent;
  String ocean;
  bool isReqPrev12MonthTraining;
  var rate;
  String ratingCount;
  String yearexp;
  String spTraining;
  String specialTrainedOther;
  bool visa;
  bool currentUnrestrictedUsPass;
  String langSpoken;
  int showprofile;
  double rateSIC;
  bool aircraftSpecifictraining;
  String totalTime;
  String timeOfInstruct;
  String complexTimeReqr;
  String highPerfomanceTime;
  bool instrumentInstructor;
  bool mulEngInstructor;
  bool tailWheelInsrtuctor;
  bool acrobaticsInstructor;
  bool isshowprofile;
  String internationalvisa;
  dynamic speacialtrainingbool;
  String totalTimeInstructor;
  var ratingcountInstruct;
  var speacialtrainingbool2;
  String? MultipleAmt;
  bool IsReqPrev12MonthTraining_FA;
  String YEAREXP_FA;
  bool IsSpecialTraining_FA;
  String LANG_SPOKEN_FA;
  bool IsShowprofile_FA;
  bool AircraftSpecifictraining_FA;
  String InternationalVisaHeld_FA;
  bool HavePassPort_FA;
  bool IsReqPrev12MonthTrainingSIC;
  bool HideGender_FA;
  bool IsExpiredTrip;
  bool IsDirectTrip;
  String SpecTraining_FA;
  String ratingSIC;
  String ratingAirCraftTypeSIC;
  String RatingCountSIC;
  String ContinentSIC;
  String AircraftTotalTimeSIC;
  String TotalTimeAircraftIdSIC;

  factory TripDetails.fromJson(Map<String, dynamic> json) => TripDetails(
    sp_traning_other: json["SP_TRAINING_OTHER"] == null
        ? null
        : json["SP_TRAINING_OTHER"],
    pkTripId: json["pkTripId"] == null ? null : json["pkTripId"],
    fkPIlotid: json["fkPIlotid"] == null ? null : json["fkPIlotid"],
    partialAmount:
    json["PartialAmount"] == null ? null : json["PartialAmount"],
    offsetAmount:
    json["OffsetAmount"] == null ? null : json["OffsetAmount"],
    fkAircraftId:
    json["fkAircraftId"] == null ? null : json["fkAircraftId"],
    aircraftType:
    json["AircraftType"] == null ? null : json["AircraftType"],
    loggedinid: json["loggedinid"] == null ? null : json["loggedinid"],
    tripName: json["TripName"] == null ? null : json["TripName"],
    tripCreater: json["TripCreater"] == null ? null : json["TripCreater"],
    captain: json["Captain"] == null ? null : json["Captain"],
    finalPilotid:
    json["finalPilotid"] == null ? null : json["finalPilotid"],
    secondInCommand:
    json["SecondInCommand"] == null ? null : json["SecondInCommand"],
    finalSecondInCommand: json["finalSecondInCommand"] == null
        ? null
        : json["finalSecondInCommand"],
    flightAttendant:
    json["FlightAttendant"] == null ? null : json["FlightAttendant"],
    finalFlightAttendant: json["finalFlightAttendant"] == null
        ? null
        : json["finalFlightAttendant"],
    flightInstructor:
    json["FlightInstructor"] == null ? null : json["FlightInstructor"],
    finalFlightInstructor: json["finalFlightInstructor"] == null
        ? null
        : json["finalFlightInstructor"],
    pilotRate: json["pilotRate"] == null ? null : json["pilotRate"],
    sicRate: json["SICRate"] == null ? null : json["SICRate"],
    faRate: json["FARate"] == null ? null : json["FARate"],
    fiRate: json["FIRate"] == null ? null : json["FIRate"],
    updatepilotRate:
    json["updatepilotRate"] == null ? null : json["updatepilotRate"],
    updateSicRate:
    json["updateSICRate"] == null ? null : json["updateSICRate"],
    updateFaRate:
    json["updateFARate"] == null ? null : json["updateFARate"],
    updateFiRate:
    json["updateFIRate"] == null ? null : json["updateFIRate"],
    destinationCode:
    json["DestinationCode"] == null ? null : json["DestinationCode"],
    departureCode:
    json["DepartureCode"] == null ? null : json["DepartureCode"],
    enrouteAirportCode: json["enroute_airportCode"] == null
        ? null
        : json["enroute_airportCode"],
    depaLocaton: json["DepaLocaton"] == null ? null : json["DepaLocaton"],
    destLocation:
    json["DestLocation"] == null ? null : json["DestLocation"],
    isRecent: json["IsRecent"] == null ? null : json["IsRecent"],
    isCancelled: json["IsCancelled"] == null ? null : json["IsCancelled"],
    tripStartDate:
    json["tripStartDate"] == null ? null : json["tripStartDate"],
    tripEndDate: json["tripEndDate"] == null ? null : json["tripEndDate"],
    nearMeCaptain:
    json["nearMeCaptain"] == null ? null : json["nearMeCaptain"],
    isVoid: json["isVoid"] == null ? null : json["isVoid"],
    entryDate: json["EntryDate"] == null ? null : json["EntryDate"],
    oppositid: json["oppositid"] == null ? null : json["oppositid"],
    amount: json["amount"] == null ? null : json["amount"],
    isfavourite: json["isfavourite"] == null ? null : json["isfavourite"],
    aircraftTotalTime: json["AircraftTotalTime"] == null
        ? null
        : json["AircraftTotalTime"],
    totalTimeAircraftId: json["TotalTimeAircraftId"] == null
        ? null
        : json["TotalTimeAircraftId"],
    picTimeAircraftId: json["PICTimeAircraftId"] == null
        ? null
        : json["PICTimeAircraftId"],
    aircraftPiCtime:
    json["AircraftPICtime"] == null ? null : json["AircraftPICtime"],
    faaMedical: json["FAAMedical"] == null ? null : json["FAAMedical"],
    havePassport:
    json["HavePassport"] == null ? null : json["HavePassport"],
    rating: json["rating"] == null ? null : json["rating"],
    ratingAirCraftType: json["ratingAirCraftType"] == null
        ? null
        : json["ratingAirCraftType"],
    continent: json["Continent"] == null ? null : json["Continent"],
    ocean: json["Ocean"] == null ? null : json["Ocean"],
    isReqPrev12MonthTraining: json["IsReqPrev12MonthTraining"] == null
        ? null
        : json["IsReqPrev12MonthTraining"],
    rate: json["rate"] == null ? null : json["rate"],
    ratingCount: json["RatingCount"] == null ? null : json["RatingCount"],
    yearexp: json["YEAREXP"] == null ? null : json["YEAREXP"],
    spTraining: json["SP_TRAINING"] == null ? null : json["SP_TRAINING"],
    specialTrainedOther: json["SpecialTrainedOther"] == null
        ? null
        : json["SpecialTrainedOther"],
    internationalvisa: json["InternationalVisaHeld"] == null
        ? null
        : json["InternationalVisaHeld"],
    visa: json["VISA"] == null ? null : json["VISA"],
    currentUnrestrictedUsPass: json["CurrentUnrestrictedUSPass"] == null
        ? null
        : json["CurrentUnrestrictedUSPass"],
    langSpoken: json["LANG_SPOKEN"] == null ? null : json["LANG_SPOKEN"],
    showprofile: json["SHOWPROFILE"] == null ? null : json["SHOWPROFILE"],
    FAAMedicalSIC: json["FAAMedicalSIC"] == null ? null : json["FAAMedicalSIC"],
    rateSIC: json["rateSIC"] == null ? null : json["rateSIC"],
    isshowprofile:
    json["IsShowprofile"] == null ? null : json["IsShowprofile"],
    aircraftSpecifictraining: json["AircraftSpecifictraining"] == null
        ? null
        : json["AircraftSpecifictraining"],
    totalTime: json["TotalTime"] == null ? null : json["TotalTime"],
    totalTimeInstructor: json["TotalTimeInstructor"] == null
        ? null
        : json["TotalTimeInstructor"],
    timeOfInstruct:
    json["TimeOfInstruct"] == null ? null : json["TimeOfInstruct"],
    complexTimeReqr:
    json["complexTimeReqr"] == null ? null : json["complexTimeReqr"],
    highPerfomanceTime: json["highPerfomanceTime"] == null
        ? null
        : json["highPerfomanceTime"],
    instrumentInstructor: json["InstrumentInstructor"] == null
        ? null
        : json["InstrumentInstructor"],
    mulEngInstructor:
    json["MulEngInstructor"] == null ? null : json["MulEngInstructor"],
    tailWheelInsrtuctor: json["tailWheelInsrtuctor"] == null
        ? null
        : json["tailWheelInsrtuctor"],
    acrobaticsInstructor: json["acrobaticsInstructor"] == null
        ? null
        : json["acrobaticsInstructor"],
    radius: json['Radius'] == null ? null : json['Radius'],
    speacialtrainingbool:
    json["IsSpecialTrained"] == null ? null : json["IsSpecialTrained"],
    speacialtrainingbool2: json["IsSpecialTraining"] == null
        ? null
        : json["IsSpecialTraining"],
    ratingcountInstruct: json["RatingCoutInstruct"] == null
        ? null
        : json["RatingCoutInstruct"],
    MultipleAmt: json["MultipleAmt"] == null ? "" : json["MultipleAmt"],
    IsReqPrev12MonthTraining_FA: json["IsReqPrev12MonthTraining_FA"] == null ? null : json["IsReqPrev12MonthTraining_FA"],
    YEAREXP_FA: json["YEAREXP_FA"] == null ? "" : json["YEAREXP_FA"],
    IsSpecialTraining_FA: json["IsSpecialTraining_FA"] == null ? null : json["IsSpecialTraining_FA"],
    LANG_SPOKEN_FA: json["LANG_SPOKEN_FA"] == null ? "" : json["LANG_SPOKEN_FA"],
    IsShowprofile_FA: json["IsShowprofile_FA"] == null ? null : json["IsShowprofile_FA"],
    AircraftSpecifictraining_FA: json["AircraftSpecifictraining_FA"] == null ? null : json["AircraftSpecifictraining_FA"],
    InternationalVisaHeld_FA: json["InternationalVisaHeld_FA"] == null ? "" : json["InternationalVisaHeld_FA"],
    HavePassPort_FA: json["HavePassPort_FA"] == null ? null : json["HavePassPort_FA"],
    HideGender_FA: json["HideGender_FA"] == null ? null : json["HideGender_FA"],
    IsExpiredTrip: json["IsExpiredTrip"] == null ? null : json["IsExpiredTrip"],
    IsDirectTrip: json["IsDirectTrip"] == null ? null : json["IsDirectTrip"],
    HavePassportSIC: json["HavePassportSIC"] == null ? null : json["HavePassportSIC"],
    IsReqPrev12MonthTrainingSIC: json["IsReqPrev12MonthTrainingSIC"] == null ? null : json["IsReqPrev12MonthTrainingSIC"],
    SpecTraining_FA: json["SpecTraining_FA"] == null ? "" : json["SpecTraining_FA"],
    AircraftTotalTimeSIC: json["AircraftTotalTimeSIC"] == null ? "" : json["AircraftTotalTimeSIC"],
    ContinentSIC: json["ContinentSIC"] == null ? "" : json["ContinentSIC"],
    ratingAirCraftTypeSIC: json["ratingAirCraftTypeSIC"] == null ? "" : json["ratingAirCraftTypeSIC"],
    RatingCountSIC: json["RatingCountSIC"] == null ? "" : json["RatingCountSIC"],
    ratingSIC: json["ratingSIC"] == null ? "" : json["ratingSIC"],
    TotalTimeAircraftIdSIC: json["TotalTimeAircraftIdSIC"] == null ? "" : json["TotalTimeAircraftIdSIC"],
  );

  Map<String, dynamic> toJson() => {
    "SP_TRAINING_OTHER": sp_traning_other == null ? null : sp_traning_other,
    "RatingCoutInstruct":
    ratingcountInstruct == null ? null : ratingcountInstruct,
    "TotalTimeInstructor":
    totalTimeInstructor == null ? null : totalTimeInstructor,
    "InternationalVisaHeld":
    internationalvisa == null ? null : internationalvisa,
    "IsShowprofile": isshowprofile == null ? null : isshowprofile,
    "Radius": radius == null ? null : radius,
    "pkTripId": pkTripId == null ? null : pkTripId,
    "fkPIlotid": fkPIlotid == null ? null : fkPIlotid,
    "PartialAmount": partialAmount == null ? null : partialAmount,
    "OffsetAmount": offsetAmount == null ? null : offsetAmount,
    "fkAircraftId": fkAircraftId == null ? null : fkAircraftId,
    "AircraftType": aircraftType == null ? null : aircraftType,
    "loggedinid": loggedinid == null ? null : loggedinid,
    "TripName": tripName == null ? null : tripName,
    "TripCreater": tripCreater == null ? null : tripCreater,
    "Captain": captain == null ? null : captain,
    "finalPilotid": finalPilotid == null ? null : finalPilotid,
    "SecondInCommand": secondInCommand == null ? null : secondInCommand,
    "finalSecondInCommand":
    finalSecondInCommand == null ? null : finalSecondInCommand,
    "FlightAttendant": flightAttendant == null ? null : flightAttendant,
    "finalFlightAttendant":
    finalFlightAttendant == null ? null : finalFlightAttendant,
    "FlightInstructor": flightInstructor == null ? null : flightInstructor,
    "finalFlightInstructor":
    finalFlightInstructor == null ? null : finalFlightInstructor,
    "pilotRate": pilotRate == null ? null : pilotRate,
    "SICRate": sicRate == null ? null : sicRate,
    "FARate": faRate == null ? null : faRate,
    "FIRate": fiRate == null ? null : fiRate,
    "updatepilotRate": updatepilotRate == null ? null : updatepilotRate,
    "updateSICRate": updateSicRate == null ? null : updateSicRate,
    "updateFARate": updateFaRate == null ? null : updateFaRate,
    "updateFIRate": updateFiRate == null ? null : updateFiRate,
    "DestinationCode": destinationCode == null ? null : destinationCode,
    "DepartureCode": departureCode == null ? null : departureCode,
    "enroute_airportCode":
    enrouteAirportCode == null ? null : enrouteAirportCode,
    "DepaLocaton": depaLocaton == null ? null : depaLocaton,
    "DestLocation": destLocation == null ? null : destLocation,
    "IsRecent": isRecent == null ? null : isRecent,
    "IsCancelled": isCancelled == null ? null : isCancelled,
    "tripStartDate": tripStartDate == null ? null : tripStartDate,
    "tripEndDate": tripEndDate == null ? null : tripEndDate,
    "nearMeCaptain": nearMeCaptain == null ? null : nearMeCaptain,
    "isVoid": isVoid == null ? null : isVoid,
    "EntryDate": entryDate == null ? null : entryDate,
    "oppositid": oppositid == null ? null : oppositid,
    "amount": amount == null ? null : amount,
    "isfavourite": isfavourite == null ? null : isfavourite,
    "AircraftTotalTime":
    aircraftTotalTime == null ? null : aircraftTotalTime,
    "TotalTimeAircraftId":
    totalTimeAircraftId == null ? null : totalTimeAircraftId,
    "PICTimeAircraftId":
    picTimeAircraftId == null ? null : picTimeAircraftId,
    "AircraftPICtime": aircraftPiCtime == null ? null : aircraftPiCtime,
    "FAAMedical": faaMedical == null ? null : faaMedical,
    "HavePassport": havePassport == null ? null : havePassport,
    "rating": rating == null ? null : rating,
    "ratingAirCraftType":
    ratingAirCraftType == null ? null : ratingAirCraftType,
    "Continent": continent == null ? null : continent,
    "Ocean": ocean == null ? null : ocean,
    "IsReqPrev12MonthTraining":
    isReqPrev12MonthTraining == null ? null : isReqPrev12MonthTraining,
    "rate": rate == null ? null : rate,
    "RatingCount": ratingCount == null ? null : ratingCount,
    "YEAREXP": yearexp == null ? null : yearexp,
    "IsSpecialTrained":
    speacialtrainingbool == null ? null : speacialtrainingbool,
    "IsSpecialTraining":
    speacialtrainingbool2 == null ? null : speacialtrainingbool2,
    "SP_TRAINING": spTraining == null ? null : spTraining,
    "SpecialTrainedOther":
    specialTrainedOther == null ? null : specialTrainedOther,
    "VISA": visa == null ? null : visa,
    "CurrentUnrestrictedUSPass": currentUnrestrictedUsPass == null
        ? null
        : currentUnrestrictedUsPass,
    "LANG_SPOKEN": langSpoken == null ? null : langSpoken,
    "SHOWPROFILE": showprofile == null ? null : showprofile,
    "AircraftSpecifictraining":
    aircraftSpecifictraining == null ? null : aircraftSpecifictraining,
    "TotalTime": totalTime == null ? null : totalTime,
    "TimeOfInstruct": timeOfInstruct == null ? null : timeOfInstruct,
    "complexTimeReqr": complexTimeReqr == null ? null : complexTimeReqr,
    "highPerfomanceTime":
    highPerfomanceTime == null ? null : highPerfomanceTime,
    "InstrumentInstructor":
    instrumentInstructor == null ? null : instrumentInstructor,
    "MulEngInstructor": mulEngInstructor == null ? null : mulEngInstructor,
    "tailWheelInsrtuctor":
    tailWheelInsrtuctor == null ? null : tailWheelInsrtuctor,
    "acrobaticsInstructor":
    acrobaticsInstructor == null ? null : acrobaticsInstructor,
    "MultipleAmt": MultipleAmt == null ? "" : MultipleAmt,
    "IsReqPrev12MonthTraining_FA": IsReqPrev12MonthTraining_FA == null ? null : IsReqPrev12MonthTraining_FA,
    "YEAREXP_FA": YEAREXP_FA == null ? "" : YEAREXP_FA,
    "IsSpecialTraining_FA": IsSpecialTraining_FA == null ? null : IsSpecialTraining_FA,
    "LANG_SPOKEN_FA": LANG_SPOKEN_FA == null ? "" : LANG_SPOKEN_FA,
    "IsShowprofile_FA": IsShowprofile_FA == null ? null : IsShowprofile_FA,
    "AircraftSpecifictraining_FA": AircraftSpecifictraining_FA == null ? null : AircraftSpecifictraining_FA,
    "InternationalVisaHeld_FA": InternationalVisaHeld_FA == null ? "" : InternationalVisaHeld_FA,
    "HavePassPort_FA": HavePassPort_FA == null ? null : HavePassPort_FA,
    "HideGender_FA": HideGender_FA == null ? null : HideGender_FA,
    "IsExpiredTrip": IsExpiredTrip == null ? null : IsExpiredTrip,
    "IsDirectTrip": IsDirectTrip == null ? null : IsDirectTrip,
    "SpecTraining_FA": SpecTraining_FA == null ? "" : SpecTraining_FA,
    "AircraftTotalTimeSIC": AircraftTotalTimeSIC == null ? "" : AircraftTotalTimeSIC,
    "TotalTimeAircraftIdSIC": TotalTimeAircraftIdSIC == null ? "" : TotalTimeAircraftIdSIC,
    "FAAMedicalSIC": FAAMedicalSIC == null ? null : FAAMedicalSIC,
    "HavePassportSIC": HavePassportSIC == null ? null : HavePassportSIC,
    "ratingSIC": ratingSIC == null ? "" : ratingSIC,
    "ratingAirCraftTypeSIC": ratingAirCraftTypeSIC == null ? "" : ratingAirCraftTypeSIC,
    "ContinentSIC": ContinentSIC == null ? "" : ContinentSIC,
    "IsReqPrev12MonthTrainingSIC": IsReqPrev12MonthTrainingSIC == null ? null : IsReqPrev12MonthTrainingSIC,
    "rateSIC": rateSIC == null ? null : rateSIC,
    "RatingCountSIC": RatingCountSIC == null ? "" : RatingCountSIC,


  };
}
