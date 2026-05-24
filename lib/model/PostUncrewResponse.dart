class PostUncrewResponse {
  int? flag;
  String? msg;
  int? code;
  Data? data;

  PostUncrewResponse({this.flag, this.msg, this.code, this.data});

  PostUncrewResponse.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    msg = json['msg'];
    code = json['Code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   data['flag'] = flag;
//   data['msg'] = msg;
//   data['Code'] = code;
//   if (this.data != null) {
//     data['data'] = this.data!.toJson();
//   }
//   return data;
// }
}

class Data {
  List<Trip>? trip;

  Data({this.trip});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['Trip'] != null) {
      trip = <Trip>[];
      json['Trip'].forEach((v) {
        trip!.add(new Trip.fromJson(v));
      });
    }
  }

// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   if (trip != null) {
//     data['Trip'] = trip!.map((v) => v.toJson()).toList();
//   }
//   return data;
// }
}

class Trip {
  dynamic membershipType;
  int? pkTripId;
  int? fkPIlotid;
  String? partialAmount;
  String? offsetAmount;
  int? fkAircraftId;
  String? aircraftType;
  dynamic status;
  int? loggedinid;
  String? tripName;
  String? tripCreater;
  bool? captain;
  int? finalPilotid;
  bool? isRead;
  bool? secondInCommand;
  int? finalSecondInCommand;
  bool? flightAttendant;
  int? finalFlightAttendant;
  bool? flightInstructor;
  int? finalFlightInstructor;
  num? pilotRate;
  num? sICRate;
  num? fARate;
  num? fIRate;
  num? updatepilotRate;
  num? updateSICRate;
  num? updateFARate;
  num? updateFIRate;
  String? destinationCode;
  String? departureCode;
  String? enrouteAirportCode;
  String? depaLocaton;
  String? destLocation;
  dynamic radius;
  dynamic sPTRAININGOTHER;
  dynamic photoPath;
  bool? isRecent;
  bool? isCancelled;
  String? tripStartDate;
  String? tripEndDate;
  int? nearMeCaptain;
  bool? isVoid;
  String? entryDate;
  int? oppositid;
  String? amount;
  String? isfavourite;
  String? aircraftTotalTime;
  String? totalTimeAircraftId;
  String? pICTimeAircraftId;
  String? aircraftPICtime;
  int? fAAMedical;
  bool? havePassport;
  String? rating;
  String? ratingAirCraftType;
  String? continent;
  String? ocean;
  bool? havePassPortFA;
  bool? hideGenderFA;
  bool? isReqPrev12MonthTrainingFA;
  dynamic yEAREXPFA;
  bool? isSpecialTrainingFA;
  dynamic specTrainingFA;
  dynamic lANGSPOKENFA;
  bool? isShowprofileFA;
  bool? aircraftSpecifictrainingFA;
  dynamic internationalVisaHeldFA;
  bool? isReqPrev12MonthTraining;
  num? rate;
  String? ratingCount;
  String? yEAREXP;
  String? sPTRAINING;
  String? specialTrainedOther;
  bool? isExpiredTrip;
  bool? isReadByOwner;
  bool? vISA;
  bool? currentUnrestrictedUSPass;
  String? lANGSPOKEN;
  dynamic internationalVisaHeld;
  dynamic totalTimeInstructor;
  dynamic ratingCoutInstruct;
  int? sHOWPROFILE;
  bool? isShowprofile;
  bool? aircraftSpecifictraining;
  bool? isSpecialTraining;
  String? totalTime;
  dynamic aircraftTotalTimeSIC;
  dynamic totalTimeAircraftIdSIC;
  int? fAAMedicalSIC;
  bool? havePassportSIC;
  dynamic ratingSIC;
  dynamic ratingAirCraftTypeSIC;
  dynamic continentSIC;
  bool? isReqPrev12MonthTrainingSIC;
  num? rateSIC;
  dynamic ratingCountSIC;
  String? timeOfInstruct;
  String? complexTimeReqr;
  String? highPerfomanceTime;
  bool? instrumentInstructor;
  bool? mulEngInstructor;
  bool? tailWheelInsrtuctor;
  bool? acrobaticsInstructor;
  bool? isEdit;
  bool? isDirectTrip;
  String? multipleCrewMember;

  Trip(
      {this.membershipType,
        this.pkTripId,
        this.fkPIlotid,
        this.partialAmount,
        this.offsetAmount,
        this.fkAircraftId,
        this.aircraftType,
        this.status,
        this.loggedinid,
        this.tripName,
        this.tripCreater,
        this.captain,
        this.finalPilotid,
        this.isRead,
        this.secondInCommand,
        this.finalSecondInCommand,
        this.flightAttendant,
        this.finalFlightAttendant,
        this.flightInstructor,
        this.finalFlightInstructor,
        this.pilotRate,
        this.sICRate,
        this.fARate,
        this.fIRate,
        this.updatepilotRate,
        this.updateSICRate,
        this.updateFARate,
        this.updateFIRate,
        this.destinationCode,
        this.departureCode,
        this.enrouteAirportCode,
        this.depaLocaton,
        this.destLocation,
        this.radius,
        this.sPTRAININGOTHER,
        this.photoPath,
        this.isRecent,
        this.isCancelled,
        this.tripStartDate,
        this.tripEndDate,
        this.nearMeCaptain,
        this.isVoid,
        this.entryDate,
        this.oppositid,
        this.amount,
        this.isfavourite,
        this.aircraftTotalTime,
        this.totalTimeAircraftId,
        this.pICTimeAircraftId,
        this.aircraftPICtime,
        this.fAAMedical,
        this.havePassport,
        this.rating,
        this.ratingAirCraftType,
        this.continent,
        this.ocean,
        this.havePassPortFA,
        this.hideGenderFA,
        this.isReqPrev12MonthTrainingFA,
        this.yEAREXPFA,
        this.isSpecialTrainingFA,
        this.specTrainingFA,
        this.lANGSPOKENFA,
        this.isShowprofileFA,
        this.aircraftSpecifictrainingFA,
        this.internationalVisaHeldFA,
        this.isReqPrev12MonthTraining,
        this.rate,
        this.ratingCount,
        this.yEAREXP,
        this.sPTRAINING,
        this.specialTrainedOther,
        this.isExpiredTrip,
        this.isReadByOwner,
        this.vISA,
        this.currentUnrestrictedUSPass,
        this.lANGSPOKEN,
        this.internationalVisaHeld,
        this.totalTimeInstructor,
        this.ratingCoutInstruct,
        this.sHOWPROFILE,
        this.isShowprofile,
        this.aircraftSpecifictraining,
        this.isSpecialTraining,
        this.totalTime,
        this.aircraftTotalTimeSIC,
        this.totalTimeAircraftIdSIC,
        this.fAAMedicalSIC,
        this.havePassportSIC,
        this.ratingSIC,
        this.ratingAirCraftTypeSIC,
        this.continentSIC,
        this.isReqPrev12MonthTrainingSIC,
        this.rateSIC,
        this.ratingCountSIC,
        this.timeOfInstruct,
        this.complexTimeReqr,
        this.highPerfomanceTime,
        this.instrumentInstructor,
        this.mulEngInstructor,
        this.tailWheelInsrtuctor,
        this.acrobaticsInstructor,
        this.isEdit,
        this.isDirectTrip,
        this.multipleCrewMember});

  Trip.fromJson(Map<String, dynamic> json) {
    membershipType = json['MembershipType'];
    pkTripId = json['pkTripId'];
    fkPIlotid = json['fkPIlotid'];
    partialAmount = json['PartialAmount'];
    offsetAmount = json['OffsetAmount'];
    fkAircraftId = json['fkAircraftId'];
    aircraftType = json['AircraftType'];
    status = json['Status'];
    loggedinid = json['loggedinid'];
    tripName = json['TripName'];
    tripCreater = json['TripCreater'];
    captain = json['Captain'];
    finalPilotid = json['finalPilotid'];
    isRead = json['IsRead'];
    secondInCommand = json['SecondInCommand'];
    finalSecondInCommand = json['finalSecondInCommand'];
    flightAttendant = json['FlightAttendant'];
    finalFlightAttendant = json['finalFlightAttendant'];
    flightInstructor = json['FlightInstructor'];
    finalFlightInstructor = json['finalFlightInstructor'];
    pilotRate = json['pilotRate'];
    sICRate = json['SICRate'];
    fARate = json['FARate'];
    fIRate = json['FIRate'];
    updatepilotRate = json['updatepilotRate'];
    updateSICRate = json['updateSICRate'];
    updateFARate = json['updateFARate'];
    updateFIRate = json['updateFIRate'];
    destinationCode = json['DestinationCode'];
    departureCode = json['DepartureCode'];
    enrouteAirportCode = json['enroute_airportCode'];
    depaLocaton = json['DepaLocaton'];
    destLocation = json['DestLocation'];
    radius = json['Radius'];
    sPTRAININGOTHER = json['SP_TRAINING_OTHER'];
    photoPath = json['PhotoPath'];
    isRecent = json['IsRecent'];
    isCancelled = json['IsCancelled'];
    tripStartDate = json['tripStartDate'];
    tripEndDate = json['tripEndDate'];
    nearMeCaptain = json['nearMeCaptain'];
    isVoid = json['isVoid'];
    entryDate = json['EntryDate'];
    oppositid = json['oppositid'];
    amount = json['amount'];
    isfavourite = json['isfavourite'];
    aircraftTotalTime = json['AircraftTotalTime'];
    totalTimeAircraftId = json['TotalTimeAircraftId'];
    pICTimeAircraftId = json['PICTimeAircraftId'];
    aircraftPICtime = json['AircraftPICtime'];
    fAAMedical = json['FAAMedical'];
    havePassport = json['HavePassport'];
    rating = json['rating'];
    ratingAirCraftType = json['ratingAirCraftType'];
    continent = json['Continent'];
    ocean = json['Ocean'];
    havePassPortFA = json['HavePassPort_FA'];
    hideGenderFA = json['HideGender_FA'];
    isReqPrev12MonthTrainingFA = json['IsReqPrev12MonthTraining_FA'];
    yEAREXPFA = json['YEAREXP_FA'];
    isSpecialTrainingFA = json['IsSpecialTraining_FA'];
    specTrainingFA = json['SpecTraining_FA'];
    lANGSPOKENFA = json['LANG_SPOKEN_FA'];
    isShowprofileFA = json['IsShowprofile_FA'];
    aircraftSpecifictrainingFA = json['AircraftSpecifictraining_FA'];
    internationalVisaHeldFA = json['InternationalVisaHeld_FA'];
    isReqPrev12MonthTraining = json['IsReqPrev12MonthTraining'];
    rate = json['rate'];
    ratingCount = json['RatingCount'];
    yEAREXP = json['YEAREXP'];
    sPTRAINING = json['SP_TRAINING'];
    specialTrainedOther = json['SpecialTrainedOther'];
    isExpiredTrip = json['IsExpiredTrip'];
    isReadByOwner = json['IsReadByOwner'];
    vISA = json['VISA'];
    currentUnrestrictedUSPass = json['CurrentUnrestrictedUSPass'];
    lANGSPOKEN = json['LANG_SPOKEN'];
    internationalVisaHeld = json['InternationalVisaHeld'];
    totalTimeInstructor = json['TotalTimeInstructor'];
    ratingCoutInstruct = json['RatingCoutInstruct'];
    sHOWPROFILE = json['SHOWPROFILE'];
    isShowprofile = json['IsShowprofile'];
    aircraftSpecifictraining = json['AircraftSpecifictraining'];
    isSpecialTraining = json['IsSpecialTraining'];
    totalTime = json['TotalTime'];
    aircraftTotalTimeSIC = json['AircraftTotalTimeSIC'];
    totalTimeAircraftIdSIC = json['TotalTimeAircraftIdSIC'];
    fAAMedicalSIC = json['FAAMedicalSIC'];
    havePassportSIC = json['HavePassportSIC'];
    ratingSIC = json['ratingSIC'];
    ratingAirCraftTypeSIC = json['ratingAirCraftTypeSIC'];
    continentSIC = json['ContinentSIC'];
    isReqPrev12MonthTrainingSIC = json['IsReqPrev12MonthTrainingSIC'];
    rateSIC = json['rateSIC'];
    ratingCountSIC = json['RatingCountSIC'];
    timeOfInstruct = json['TimeOfInstruct'];
    complexTimeReqr = json['complexTimeReqr'];
    highPerfomanceTime = json['highPerfomanceTime'];
    instrumentInstructor = json['InstrumentInstructor'];
    mulEngInstructor = json['MulEngInstructor'];
    tailWheelInsrtuctor = json['tailWheelInsrtuctor'];
    acrobaticsInstructor = json['acrobaticsInstructor'];
    isEdit = json['IsEdit'];
    isDirectTrip = json['IsDirectTrip'];
    multipleCrewMember = json['MultipleCrewMember'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MembershipType'] = membershipType;
    data['pkTripId'] = pkTripId;
    data['fkPIlotid'] = fkPIlotid;
    data['PartialAmount'] = partialAmount;
    data['OffsetAmount'] = offsetAmount;
    data['fkAircraftId'] = fkAircraftId;
    data['AircraftType'] = aircraftType;
    data['Status'] = status;
    data['loggedinid'] = loggedinid;
    data['TripName'] = tripName;
    data['TripCreater'] = tripCreater;
    data['Captain'] = captain;
    data['finalPilotid'] = finalPilotid;
    data['IsRead'] = isRead;
    data['SecondInCommand'] = secondInCommand;
    data['finalSecondInCommand'] = finalSecondInCommand;
    data['FlightAttendant'] = flightAttendant;
    data['finalFlightAttendant'] = finalFlightAttendant;
    data['FlightInstructor'] = flightInstructor;
    data['finalFlightInstructor'] = finalFlightInstructor;
    data['pilotRate'] = pilotRate;
    data['SICRate'] = sICRate;
    data['FARate'] = fARate;
    data['FIRate'] = fIRate;
    data['updatepilotRate'] = updatepilotRate;
    data['updateSICRate'] = updateSICRate;
    data['updateFARate'] = updateFARate;
    data['updateFIRate'] = updateFIRate;
    data['DestinationCode'] = destinationCode;
    data['DepartureCode'] = departureCode;
    data['enroute_airportCode'] = enrouteAirportCode;
    data['DepaLocaton'] = depaLocaton;
    data['DestLocation'] = destLocation;
    data['Radius'] = radius;
    data['SP_TRAINING_OTHER'] = sPTRAININGOTHER;
    data['PhotoPath'] = photoPath;
    data['IsRecent'] = isRecent;
    data['IsCancelled'] = isCancelled;
    data['tripStartDate'] = tripStartDate;
    data['tripEndDate'] = tripEndDate;
    data['nearMeCaptain'] = nearMeCaptain;
    data['isVoid'] = isVoid;
    data['EntryDate'] = entryDate;
    data['oppositid'] = oppositid;
    data['amount'] = amount;
    data['isfavourite'] = isfavourite;
    data['AircraftTotalTime'] = aircraftTotalTime;
    data['TotalTimeAircraftId'] = totalTimeAircraftId;
    data['PICTimeAircraftId'] = pICTimeAircraftId;
    data['AircraftPICtime'] = aircraftPICtime;
    data['FAAMedical'] = fAAMedical;
    data['HavePassport'] = havePassport;
    data['rating'] = rating;
    data['ratingAirCraftType'] = ratingAirCraftType;
    data['Continent'] = continent;
    data['Ocean'] = ocean;
    data['HavePassPort_FA'] = havePassPortFA;
    data['HideGender_FA'] = hideGenderFA;
    data['IsReqPrev12MonthTraining_FA'] = isReqPrev12MonthTrainingFA;
    data['YEAREXP_FA'] = yEAREXPFA;
    data['IsSpecialTraining_FA'] = isSpecialTrainingFA;
    data['SpecTraining_FA'] = specTrainingFA;
    data['LANG_SPOKEN_FA'] = lANGSPOKENFA;
    data['IsShowprofile_FA'] = isShowprofileFA;
    data['AircraftSpecifictraining_FA'] = aircraftSpecifictrainingFA;
    data['InternationalVisaHeld_FA'] = internationalVisaHeldFA;
    data['IsReqPrev12MonthTraining'] = isReqPrev12MonthTraining;
    data['rate'] = rate;
    data['RatingCount'] = ratingCount;
    data['YEAREXP'] = yEAREXP;
    data['SP_TRAINING'] = sPTRAINING;
    data['SpecialTrainedOther'] = specialTrainedOther;
    data['IsExpiredTrip'] = isExpiredTrip;
    data['IsReadByOwner'] = isReadByOwner;
    data['VISA'] = vISA;
    data['CurrentUnrestrictedUSPass'] = currentUnrestrictedUSPass;
    data['LANG_SPOKEN'] = lANGSPOKEN;
    data['InternationalVisaHeld'] = internationalVisaHeld;
    data['TotalTimeInstructor'] = totalTimeInstructor;
    data['RatingCoutInstruct'] = ratingCoutInstruct;
    data['SHOWPROFILE'] = sHOWPROFILE;
    data['IsShowprofile'] = isShowprofile;
    data['AircraftSpecifictraining'] = aircraftSpecifictraining;
    data['IsSpecialTraining'] = isSpecialTraining;
    data['TotalTime'] = totalTime;
    data['AircraftTotalTimeSIC'] = aircraftTotalTimeSIC;
    data['TotalTimeAircraftIdSIC'] = totalTimeAircraftIdSIC;
    data['FAAMedicalSIC'] = fAAMedicalSIC;
    data['HavePassportSIC'] = havePassportSIC;
    data['ratingSIC'] = ratingSIC;
    data['ratingAirCraftTypeSIC'] = ratingAirCraftTypeSIC;
    data['ContinentSIC'] = continentSIC;
    data['IsReqPrev12MonthTrainingSIC'] = isReqPrev12MonthTrainingSIC;
    data['rateSIC'] = rateSIC;
    data['RatingCountSIC'] = ratingCountSIC;
    data['TimeOfInstruct'] = timeOfInstruct;
    data['complexTimeReqr'] = complexTimeReqr;
    data['highPerfomanceTime'] = highPerfomanceTime;
    data['InstrumentInstructor'] = instrumentInstructor;
    data['MulEngInstructor'] = mulEngInstructor;
    data['tailWheelInsrtuctor'] = tailWheelInsrtuctor;
    data['acrobaticsInstructor'] = acrobaticsInstructor;
    data['IsEdit'] = isEdit;
    data['IsDirectTrip'] = isDirectTrip;
    data['MultipleCrewMember'] = multipleCrewMember;
    return data;
  }
}
