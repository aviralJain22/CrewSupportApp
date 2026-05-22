import 'dart:convert';

class GetLoginDataResponse {
  int? flag;
  String? msg;
  int? code;
  Data? data;

  GetLoginDataResponse({this.flag, this.msg, this.code, this.data});

  GetLoginDataResponse.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    msg = json['msg'];
    code = json['Code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flag'] = flag;
    data['msg'] = msg;
    data['Code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Pilot? pilot;

  Data({this.pilot});

  Data.fromJson(Map<String, dynamic> json) {
    pilot = json['Pilot'] != null ? new Pilot.fromJson(json['Pilot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (pilot != null) {
      data['Pilot'] = pilot!.toJson();
    }
    return data;
  }
}

class PilotData {
  PilotData({
    this.pilotdata,
  });

  List<Pilot>? pilotdata;

  factory PilotData.fromRawJson(String str) =>
      PilotData.fromJson(json.decode(str));

  factory PilotData.fromJson(Map<String, dynamic> json) => PilotData(
        pilotdata: json["Pilot"] == null
            ? []
            : List<Pilot>.from(json["Pilot"].map((x) => Pilot.fromJson(x))),
      );
}

class Pilot {
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
  String? timeOfInstruct;
  List<Certification>? certification;
  int? fAAMedical;
  String? fAAMedicalDate;
  bool? havePassport;
  bool? isAircraftSpecificTraining;
  String? passportNo;
  String? passportExpDate;
  String? citizenCountry;
  bool? isSpecialTrained;
  int? fkExperianceId;
  bool? internationalExperience;
  bool? currentUnrestrictedUSPass;
  String? internationalVisas;
  bool? cPRTraining;
  bool? cullinaryTraining;
  String? languagesSpoken;
  String? continent;
  String? oceanicExp;
  String? experianceType;
  String? fkAircraftId;
  int? fkAircraftId1;
  String? aircraftType;
  int? fkCategoryId;
  String? categoryType;
  int? fkClassId;
  String? classType;
  String? avionics;
  String? fkAvionicsExperienceId;
  String? avionicsExperienceType;
  int? passOrFail;
  bool? isLoginWithGoogle;
  String? code;
  int? userId;
  String? entryDate;
  bool? isVoid;
  bool? isAccepted;
  int? requestStatus;
  int? deviceType;
  String? deviceToken;
  String? otherNotes;
  double? domPDRate;
  double? domPHRate;
  int? domNegotiate;
  double? interPDRate;
  double? interPHRate;
  int? interNegotiate;
  bool? isFavrouite;
  bool? isNearest;
  bool? isAvailable;
  String? rating;
  String? ratingAirCraftType;
  bool? isReqPrev12MonthTraining;
  String? yearOfExperiance;
  bool? validPassport;
  bool? instrumentInstructor;
  bool? mulEngInstructor;
  String? complexTimeReq;
  String? highPerfomanceTime;
  bool? tailWheelInsrtuctor;
  bool? acrobaticsInstructor;
  String? FromDate;
  String? toDate;
  bool? isAvailability;
  bool? isAllTime;
  bool? isResume;
  int? isAlreadyLoginWithGoogle;
  List<Availability>? availability;
  String? extraField1;
  String? extraField2;
  String? extraField3;
  String? photo;
  String? op;
  int? loggedinpilotid;
  String? picktime;
  int? tripid;
  String? onlyshowprofwithpic;
  int? picktimeaircraftid;
  int? rate;
  String? ratingCount;
  int? instrumentInstructor1;
  int? mulEngInstructor1;
  int? tailWheelInsrtuctor1;
  int? acrobaticsInstructor1;
  String? totalPICTime;
  String? pilotGender;
  String? trainAircraftList;
  String? cullinary;
  String? cullinaryOther;
  String? specialTrained;
  String? specialTrainedOther;
  String? regionExp;
  String? fAImage1;
  String? fAImage2;
  String? fAImage3;
  String? fAImage4;
  String? fAImage5;
  String? fAImage6;
  int? fAIndex;
  String? bio;
  bool? isDefaultCompanyName;
  String? AppVersion;
  dynamic City;
  dynamic State;
  dynamic Zip;
  String? AvailTime;
  String? Availablecity;
  String? AvailableState;
  String? latlong;
  bool? IsSearchAll;
  bool? IsFullTime;
  String? ResumePath;
  bool? IsUpdated;
  String? linkedInProfile;

  Pilot(
      {this.pkPilotId,
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
      this.timeOfInstruct,
      this.certification,
      this.fAAMedical,
      this.fAAMedicalDate,
      this.havePassport,
      this.isAircraftSpecificTraining,
      this.passportNo,
      this.passportExpDate,
      this.citizenCountry,
      this.isSpecialTrained,
      this.fkExperianceId,
      this.internationalExperience,
      this.currentUnrestrictedUSPass,
      this.internationalVisas,
      this.cPRTraining,
      this.cullinaryTraining,
      this.languagesSpoken,
      this.continent,
      this.oceanicExp,
      this.experianceType,
      this.fkAircraftId,
      this.fkAircraftId1,
      this.aircraftType,
      this.fkCategoryId,
      this.categoryType,
      this.fkClassId,
      this.classType,
      this.avionics,
      this.fkAvionicsExperienceId,
      this.avionicsExperienceType,
      this.passOrFail,
      this.isLoginWithGoogle,
      this.code,
      this.userId,
      this.entryDate,
      this.isVoid,
      this.isAccepted,
      this.requestStatus,
      this.deviceType,
      this.deviceToken,
      this.otherNotes,
      this.domPDRate,
      this.domPHRate,
      this.domNegotiate,
      this.interPDRate,
      this.interPHRate,
      this.interNegotiate,
      this.isFavrouite,
      this.isNearest,
      this.isAvailable,
      this.rating,
      this.ratingAirCraftType,
      this.isReqPrev12MonthTraining,
      this.yearOfExperiance,
      this.validPassport,
      this.instrumentInstructor,
      this.mulEngInstructor,
      this.complexTimeReq,
      this.highPerfomanceTime,
      this.tailWheelInsrtuctor,
      this.acrobaticsInstructor,
      this.FromDate,
      this.toDate,
      this.isAvailability,
      this.isAllTime,
      this.isResume,
      this.isAlreadyLoginWithGoogle,
      this.availability,
      this.extraField1,
      this.extraField2,
      this.extraField3,
      this.photo,
      this.op,
      this.loggedinpilotid,
      this.picktime,
      this.tripid,
      this.onlyshowprofwithpic,
      this.picktimeaircraftid,
      this.rate,
      this.ratingCount,
      this.instrumentInstructor1,
      this.mulEngInstructor1,
      this.tailWheelInsrtuctor1,
      this.acrobaticsInstructor1,
      this.totalPICTime,
      this.pilotGender,
      this.trainAircraftList,
      this.cullinary,
      this.cullinaryOther,
      this.specialTrained,
      this.specialTrainedOther,
      this.regionExp,
      this.fAImage1,
      this.fAImage2,
      this.fAImage3,
      this.fAImage4,
      this.fAImage5,
      this.fAImage6,
      this.fAIndex,
      this.bio,
      this.isDefaultCompanyName,
      this.AppVersion,
      this.State,
      this.City,
      this.IsUpdated,
      this.AvailTime,
      this.Availablecity,
      this.AvailableState,
      this.ResumePath,
      this.latlong,
      this.IsSearchAll,
      this.IsFullTime,
      this.Zip,
      this.linkedInProfile});

  Pilot.fromJson(Map<String, dynamic> json) {
    pkPilotId = json['pkPilotId'];
    pilotFname = json['PilotFname'];
    pilotMname = json['PilotMname'];
    pilotLname = json['PilotLname'];
    pilotNname = json['PilotNname'];
    companyName = json['CompanyName'];
    currentLocation = json['CurrentLocation'];
    cuLocCountry = json['CuLocCountry'];
    fkMemberShipId = json['fkMemberShipId'];
    memberShipType = json['MemberShipType'];
    emailId = json['EmailId'];
    oldPssword = json['OldPssword'];
    newPassword = json['NewPassword'];
    photoPath = json['PhotoPath'];
    cellNumber = json['cellNumber'];
    workNumber = json['WorkNumber'];
    totalTime = json['TotalTime'];
    timeOfInstruct = json['TimeOfInstruct'];
    if (json['Certification'] != null) {
      certification = <Certification>[];
      json['Certification'].forEach((v) {
        certification!.add(new Certification.fromJson(v));
      });
    }
    fAAMedical = json['FAAMedical'];
    fAAMedicalDate = json['FAAMedicalDate'];
    havePassport = json['HavePassport'];
    isAircraftSpecificTraining = json['isAircraftSpecificTraining'];
    passportNo = json['PassportNo'];
    passportExpDate = json['PassportExpDate'];
    citizenCountry = json['CitizenCountry'];
    isSpecialTrained = json['IsSpecialTrained'];
    fkExperianceId = json['fkExperianceId'];
    internationalExperience = json['InternationalExperience'];
    currentUnrestrictedUSPass = json['CurrentUnrestrictedUSPass'];
    internationalVisas = json['InternationalVisas'];
    cPRTraining = json['CPRTraining'];
    cullinaryTraining = json['CullinaryTraining'];
    languagesSpoken = json['LanguagesSpoken'];
    continent = json['Continent'];
    oceanicExp = json['OceanicExp'];
    experianceType = json['ExperianceType'];
    fkAircraftId = json['fkAircraftId'];
    fkAircraftId1 = json['fkAircraftId1'];
    aircraftType = json['AircraftType'];
    fkCategoryId = json['fkCategoryId'];
    categoryType = json['CategoryType'];
    fkClassId = json['fkClassId'];
    classType = json['ClassType'];
    avionics = json['Avionics'];
    fkAvionicsExperienceId = json['fkAvionicsExperienceId'];
    avionicsExperienceType = json['AvionicsExperienceType'];
    passOrFail = json['PassOrFail'];
    isLoginWithGoogle = json['IsLoginWithGoogle'];
    code = json['Code'];
    userId = json['UserId'];
    entryDate = json['EntryDate'];
    isVoid = json['isVoid'];
    isAccepted = json['IsAccepted'];
    requestStatus = json['requestStatus'];
    deviceType = json['DeviceType'];
    deviceToken = json['DeviceToken'];
    otherNotes = json['OtherNotes'];
    domPDRate = json['DomPDRate'];
    domPHRate = json['DomPHRate'];
    domNegotiate = json['DomNegotiate'];
    interPDRate = json['InterPDRate'];
    interPHRate = json['InterPHRate'];
    interNegotiate = json['InterNegotiate'];
    isFavrouite = json['isFavrouite'];
    isNearest = json['isNearest'];
    isAvailable = json['IsAvailable'];
    rating = json['rating'];
    ratingAirCraftType = json['RatingAirCraftType'];
    isReqPrev12MonthTraining = json['IsReqPrev12MonthTraining'];
    yearOfExperiance = json['yearOfExperiance'];
    validPassport = json['validPassport'];
    instrumentInstructor = json['InstrumentInstructor'];
    mulEngInstructor = json['MulEngInstructor'];
    complexTimeReq = json['complexTimeReq'];
    highPerfomanceTime = json['highPerfomanceTime'];
    tailWheelInsrtuctor = json['tailWheelInsrtuctor'];
    acrobaticsInstructor = json['acrobaticsInstructor'];
    FromDate = json['FromDate'];
    toDate = json['ToDate'];
    isAvailability = json['IsAvailability'];
    isAllTime = json['IsAllTime'];
    isResume = json['IsResume'];
    isAlreadyLoginWithGoogle = json['IsAlreadyLoginWithGoogle'];
    if (json['Availability'] != null) {
      availability = <Availability>[];
      json['Availability'].forEach((v) {
        availability!.add(new Availability.fromJson(v));
      });
    }
    extraField1 = json['ExtraField1'];
    extraField2 = json['ExtraField2'];
    extraField3 = json['ExtraField3'];
    photo = json['Photo'];
    op = json['op'];
    loggedinpilotid = json['loggedinpilotid'];
    picktime = json['picktime'];
    tripid = json['tripid'];
    onlyshowprofwithpic = json['onlyshowprofwithpic'];
    picktimeaircraftid = json['picktimeaircraftid'];
    rate = json['rate'];
    ratingCount = json['ratingCount'];
    instrumentInstructor1 = json['InstrumentInstructor1'];
    mulEngInstructor1 = json['MulEngInstructor1'];
    tailWheelInsrtuctor1 = json['tailWheelInsrtuctor1'];
    acrobaticsInstructor1 = json['acrobaticsInstructor1'];
    totalPICTime = json['TotalPICTime'];
    pilotGender = json['PilotGender'];
    trainAircraftList = json['TrainAircraftList'];
    cullinary = json['Cullinary'];
    cullinaryOther = json['CullinaryOther'];
    specialTrained = json['SpecialTrained'];
    specialTrainedOther = json['SpecialTrainedOther'];
    regionExp = json['RegionExp'];
    fAImage1 = json['FAImage1'];
    fAImage2 = json['FAImage2'];
    fAImage3 = json['FAImage3'];
    fAImage4 = json['FAImage4'];
    fAImage5 = json['FAImage5'];
    fAImage6 = json['FAImage6'];
    fAIndex = json['FAIndex'];
    isDefaultCompanyName = json['IsDefaultCompanyName'];
    bio = json['Bio'] ?? "";
    AppVersion = json['AppVersion'];
    State = json['State'];
    City = json['City'];
    Zip = json['Zip'];
    linkedInProfile = json['LinkedInProfile'];
    AvailTime = json['AvailTime'];
    Availablecity =
        json['Availablecity'] == null ? null : json['Availablecity'];
    AvailableState =
        json['AvailableState'] == null ? null : json['AvailableState'];
    ResumePath = json['ResumePath'] == null ? null : json['ResumePath'];
    latlong = json['latlong'] == null ? "" : json['latlong'];
    IsSearchAll = json['IsSearchAll'] == null ? "" : json['IsSearchAll'];
    IsFullTime = json['IsFullTime'] == null ? "" : json['IsFullTime'];
    IsUpdated = json["IsUpdated"] == null ? "" : json["IsUpdated"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkPilotId'] = pkPilotId;
    data['PilotFname'] = pilotFname;
    data['PilotMname'] = pilotMname;
    data['PilotLname'] = pilotLname;
    data['PilotNname'] = pilotNname;
    data['CompanyName'] = companyName;
    data['CurrentLocation'] = currentLocation;
    data['CuLocCountry'] = cuLocCountry;
    data['fkMemberShipId'] = fkMemberShipId;
    data['MemberShipType'] = memberShipType;
    data['EmailId'] = emailId;
    data['OldPssword'] = oldPssword;
    data['NewPassword'] = newPassword;
    data['PhotoPath'] = photoPath;
    data['cellNumber'] = cellNumber;
    data['WorkNumber'] = workNumber;
    data['TotalTime'] = totalTime;
    data['TimeOfInstruct'] = timeOfInstruct;
    if (certification != null) {
      data['Certification'] = certification!.map((v) => v.toJson()).toList();
    }
    data['FAAMedical'] = fAAMedical;
    data['FAAMedicalDate'] = fAAMedicalDate;
    data['HavePassport'] = havePassport;
    data['isAircraftSpecificTraining'] = isAircraftSpecificTraining;
    data['PassportNo'] = passportNo;
    data['PassportExpDate'] = passportExpDate;
    data['CitizenCountry'] = citizenCountry;
    data['IsSpecialTrained'] = isSpecialTrained;
    data['fkExperianceId'] = fkExperianceId;
    data['InternationalExperience'] = internationalExperience;
    data['CurrentUnrestrictedUSPass'] = currentUnrestrictedUSPass;
    data['InternationalVisas'] = internationalVisas;
    data['CPRTraining'] = cPRTraining;
    data['CullinaryTraining'] = cullinaryTraining;
    data['LanguagesSpoken'] = languagesSpoken;
    data['Continent'] = continent;
    data['OceanicExp'] = oceanicExp;
    data['ExperianceType'] = experianceType;
    data['fkAircraftId'] = fkAircraftId;
    data['fkAircraftId1'] = fkAircraftId1;
    data['AircraftType'] = aircraftType;
    data['fkCategoryId'] = fkCategoryId;
    data['CategoryType'] = categoryType;
    data['fkClassId'] = fkClassId;
    data['ClassType'] = classType;
    data['Avionics'] = avionics;
    data['fkAvionicsExperienceId'] = fkAvionicsExperienceId;
    data['AvionicsExperienceType'] = avionicsExperienceType;
    data['PassOrFail'] = passOrFail;
    data['IsLoginWithGoogle'] = isLoginWithGoogle;
    data['Code'] = code;
    data['UserId'] = userId;
    data['EntryDate'] = entryDate;
    data['isVoid'] = isVoid;
    data['IsAccepted'] = isAccepted;
    data['requestStatus'] = requestStatus;
    data['DeviceType'] = deviceType;
    data['DeviceToken'] = deviceToken;
    data['OtherNotes'] = otherNotes;
    data['DomPDRate'] = domPDRate;
    data['DomPHRate'] = domPHRate;
    data['DomNegotiate'] = domNegotiate;
    data['InterPDRate'] = interPDRate;
    data['InterPHRate'] = interPHRate;
    data['InterNegotiate'] = interNegotiate;
    data['isFavrouite'] = isFavrouite;
    data['isNearest'] = isNearest;
    data['IsAvailable'] = isAvailable;
    data['rating'] = rating;
    data['RatingAirCraftType'] = ratingAirCraftType;
    data['IsReqPrev12MonthTraining'] = isReqPrev12MonthTraining;
    data['yearOfExperiance'] = yearOfExperiance;
    data['validPassport'] = validPassport;
    data['InstrumentInstructor'] = instrumentInstructor;
    data['MulEngInstructor'] = mulEngInstructor;
    data['complexTimeReq'] = complexTimeReq;
    data['highPerfomanceTime'] = highPerfomanceTime;
    data['tailWheelInsrtuctor'] = tailWheelInsrtuctor;
    data['acrobaticsInstructor'] = acrobaticsInstructor;
    data['FromDate'] = FromDate;
    data['ToDate'] = toDate;
    data['IsAvailability'] = isAvailability;
    data['IsAllTime'] = isAllTime;
    data['IsResume'] = isResume;
    data['IsAlreadyLoginWithGoogle'] = isAlreadyLoginWithGoogle;
    if (availability != null) {
      data['Availability'] = availability!.map((v) => v.toJson()).toList();
    }
    data['ExtraField1'] = extraField1;
    data['ExtraField2'] = extraField2;
    data['ExtraField3'] = extraField3;
    data['Photo'] = photo;
    data['op'] = op;
    data['loggedinpilotid'] = loggedinpilotid;
    data['picktime'] = picktime;
    data['tripid'] = tripid;
    data['onlyshowprofwithpic'] = onlyshowprofwithpic;
    data['picktimeaircraftid'] = picktimeaircraftid;
    data['rate'] = rate;
    data['ratingCount'] = ratingCount;
    data['InstrumentInstructor1'] = instrumentInstructor1;
    data['MulEngInstructor1'] = mulEngInstructor1;
    data['tailWheelInsrtuctor1'] = tailWheelInsrtuctor1;
    data['acrobaticsInstructor1'] = acrobaticsInstructor1;
    data['TotalPICTime'] = totalPICTime;
    data['PilotGender'] = pilotGender;
    data['TrainAircraftList'] = trainAircraftList;
    data['Cullinary'] = cullinary;
    data['CullinaryOther'] = cullinaryOther;
    data['SpecialTrained'] = specialTrained;
    data['SpecialTrainedOther'] = specialTrainedOther;
    data['RegionExp'] = regionExp;
    data['FAImage1'] = fAImage1;
    data['FAImage2'] = fAImage2;
    data['FAImage3'] = fAImage3;
    data['FAImage4'] = fAImage4;
    data['FAImage5'] = fAImage5;
    data['FAImage6'] = fAImage6;
    data['FAIndex'] = fAIndex;
    data['Bio'] = bio;
    data['IsDefaultCompanyName'] = isDefaultCompanyName;
    data['City'] == City;
    data['State'] == State;
    data['Zip'] == Zip;
    data['AvailTime'] == AvailTime;
    data['Availablecity'] == Availablecity;
    data['AvailableState'] == AvailableState;
    data['ResumePath'] == ResumePath;
    data['latlong'] == latlong;
    data['IsSearchAll'] == IsSearchAll;
    data['IsFullTime'] == IsFullTime;
    data['IsUpdated'] == IsUpdated;
    data['LinkedInProfile'] = linkedInProfile;
    return data;
  }
}

class Certification {
  int? pkRatingCertiId;
  int? fkPilotid;
  String? ratingCertification;
  int? fkCategoryId;
  String? cetogoryType;
  int? fkClassId;
  String? classType;
  String? aircraftType;
  String? hours;
  String? pIC;
  double? minimumRate;
  String? currentInType;
  String? entryDate;
  bool? isReqPrev12MonthTraining;
  bool? isVoid;

  Certification(
      {this.pkRatingCertiId,
      this.fkPilotid,
      this.ratingCertification,
      this.fkCategoryId,
      this.cetogoryType,
      this.fkClassId,
      this.classType,
      this.aircraftType,
      this.hours,
      this.pIC,
      this.minimumRate,
      this.currentInType,
      this.entryDate,
      this.isReqPrev12MonthTraining,
      this.isVoid});

  Certification.fromJson(Map<String, dynamic> json) {
    pkRatingCertiId = json['pkRatingCertiId'];
    fkPilotid = json['fkPilotid'];
    ratingCertification = json['RatingCertification'];
    fkCategoryId = json['fkCategoryId'];
    cetogoryType = json['CetogoryType'];
    fkClassId = json['fkClassId'];
    classType = json['ClassType'];
    aircraftType = json['AirCraftType'];
    hours = json['Hours'];
    pIC = json['PIC'];
    minimumRate = json['MinimumRate'];
    currentInType = json['CurrentInType'];
    entryDate = json['EntryDate'];
    isReqPrev12MonthTraining = json['IsReqPrev12MonthTraining'];
    isVoid = json['isVoid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkRatingCertiId'] = pkRatingCertiId;
    data['fkPilotid'] = fkPilotid;
    data['RatingCertification'] = ratingCertification;
    data['fkCategoryId'] = fkCategoryId;
    data['CetogoryType'] = cetogoryType;
    data['fkClassId'] = fkClassId;
    data['ClassType'] = classType;
    data['AirCraftType'] = aircraftType;
    data['Hours'] = hours;
    data['PIC'] = pIC;
    data['MinimumRate'] = minimumRate;
    data['CurrentInType'] = currentInType;
    data['EntryDate'] = entryDate;
    data['IsReqPrev12MonthTraining'] = isReqPrev12MonthTraining;
    data['isVoid'] = isVoid;
    return data;
  }
}

class Availability {
  bool? isInsert;
  bool? isUpdate;
  bool? isDelete;
  int? pkAvailabilityId;
  int? fkPilotid;
  String? fromDate;
  String? toDate;
  bool? isAvailability;
  String? comment;
  String? city;
  String? State;
  bool? isVoid;
  String? entryDate;
  String? op;
  int? pkPilotId;

  Availability(
      {this.isInsert,
      this.isUpdate,
      this.isDelete,
      this.pkAvailabilityId,
      this.fkPilotid,
      this.fromDate,
      this.toDate,
      this.isAvailability,
      this.comment,
      this.State,
      this.city,
      this.isVoid,
      this.entryDate,
      this.op,
      this.pkPilotId});

  Availability.fromJson(Map<String, dynamic> json) {
    isInsert = json['IsInsert'];
    isUpdate = json['IsUpdate'];
    isDelete = json['IsDelete'];
    pkAvailabilityId = json['pkAvailabilityId'];
    fkPilotid = json['fkPilotid'];
    fromDate = json['FromDate'];
    toDate = json['ToDate'];
    isAvailability = json['IsAvailability'];
    comment = json['Comment'];
    State = json['State'];
    city = json['City'];
    isVoid = json['IsVoid'];
    entryDate = json['EntryDate'];
    op = json['op'];
    pkPilotId = json['pkPilotId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsInsert'] = isInsert;
    data['IsUpdate'] = isUpdate;
    data['IsDelete'] = isDelete;
    data['pkAvailabilityId'] = pkAvailabilityId;
    data['fkPilotid'] = fkPilotid;
    data['FromDate'] = fromDate;
    data['ToDate'] = toDate;
    data['IsAvailability'] = isAvailability;
    data['Comment'] = comment;
    data['City'] = city;
    data['State'] = State;
    data['IsVoid'] = isVoid;
    data['EntryDate'] = entryDate;
    data['op'] = op;
    data['pkPilotId'] = pkPilotId;
    return data;
  }
}
