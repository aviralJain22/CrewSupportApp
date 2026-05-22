import 'dart:async';

import 'package:crew_support/model/FilterFlightAttedantResponse.dart';
import 'package:crew_support/model/FilterPilotResponse.dart';
import 'package:crew_support/model/FilterSICResponse.dart';
import 'package:crew_support/model/GetAllAirportCodeResponse.dart';
import 'package:crew_support/model/GetAllAllvailability.dart';
import 'package:crew_support/model/GetAllCityByState.dart';
import 'package:crew_support/model/GetAllState.dart';
import 'package:crew_support/model/GetLoginDataResponse.dart';
import 'package:crew_support/model/InsertTripResponse.dart';
import 'package:crew_support/model/InsertUpdateFavouriteResponse.dart';
import 'package:crew_support/model/PostUncrewResponse.dart';
import 'package:crew_support/model/SendNotificationResponse.dart';
import 'package:crew_support/model/TripDetailsResponse.dart';
import 'package:crew_support/model/available.dart';
import 'package:crew_support/model/get_favorite_list_model.dart';
import 'package:crew_support/model/viewProfileResponse.dart';
import 'package:crew_support/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Calls Back4App Cloud Function: getAllAirportCode
/// - Exact legacy behavior: the function ignores "limit" and always returns all valid codes.
/// - Returns your existing GetAllAirportCodeResponse model.
/// - Wraps the call in a timeout and prints debug info in debug mode.
Future<GetAllAirportCodeResponse?> getAllAirportCode() async {
  try {
    // 1) Prepare cloud function (no params — legacy behavior ignores Limit anyway)
    final cloudFn = ParseCloudFunction('getAllAirportCode');

    // 2) Execute with a timeout (adjust if you like)
    final ParseResponse res = await cloudFn
        .execute() // if you ever want to pass it (even if ignored): .execute(parameters: {'limit': 47000})
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) {
      debugPrint('getAllAirportCode() -> success: ${res.success}, status: ${res.statusCode}');
      debugPrint('getAllAirportCode() -> raw result: ${res.result}');
      debugPrint('getAllAirportCode() -> error: ${res.error?.message}');
    }

    // 3) Parse SDK returns your payload inside "result"
    //    Example:
    //    {
    //      "Code":200,"flag":1,"msg":"List of Airport code.","TotalCount":74586,
    //      "data":{"AirportCode":[{"AirportCode":"DEL","TotalAirportCode":74586}, ...]}
    //    }
    if (res.success && res.result is Map<String, dynamic>) {
      final Map<String, dynamic> payload = res.result as Map<String, dynamic>;

      // your model expects {flag, TotalCount, msg, Code, data:{AirportCode:[...]}}
      final model = GetAllAirportCodeResponse.fromJson(payload);

      // maintain your legacy success check
      if ((model.code ?? 0) == 200) {
        return model;
      } else {
        if (kDebugMode) {
          debugPrint('getAllAirportCode() -> non-200 Code in payload: ${model.code}');
        }
        return null;
      }
    } else {
      // non-success or unexpected structure
      if (kDebugMode) {
        debugPrint('getAllAirportCode() -> request failed or unexpected result shape.');
      }
      return null;
    }
  } on TimeoutException {
    if (kDebugMode) {
      debugPrint('getAllAirportCode() -> timed out.');
    }
    return null;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('getAllAirportCode() -> exception: $e\n$st');
    }
    return null;
  }
}

Future<TripDetailsResponse?> getTripDetail(
    {required String tripId, required String pilotId, String? status}) async {
  print("pkTripId : ${tripId},loggedinid : ${pkPilotId} this trip id and piolt id, Status: ${status}");
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}getTripDetail');
  // log('$finalUri\n pkTripId: $tripId\nloggedinid: $pilotId \n Status: $status');
  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "pkTripId": tripId,
  //       "loggedinid": pilotId,
  //       "Status": status
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     // log("$map");
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = TripDetailsResponse.fromJson(jsonDecode(response.body));

  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

/// Keeps your existing signature so UI code remains unchanged.
/// NOTE:
/// - Cloud Code expects param names like `parampkTripId`, `paramloggedinid`, etc.
/// - Dates should be ISO strings. If you already have ISO (with 'Z'), pass as-is.
/// - isEdit -> decides 'Insert' (new) vs 'Insert(update path)' when pkTripId exists.
Future<InsertTripResponse?> insertTrip({
  required String tripName,
  String? departureCode,
  String? enroutCode,
  String? destinationCode,
  required String tripStartDate,   // expect ISO "yyyy-MM-ddTHH:mm:ss.SSSZ" or "yyyy-MM-dd HH:mm:ss"
  required String tripEndDate,     // same as above
  required String fkAircraftType,  // unused by Cloud Function; kept for compatibility
  required dynamic captain,        // should be 0/1 or bool; we coerce
  required dynamic secondInCommand,
  required dynamic flightAttendant,
  required dynamic flightInstructor,
  required dynamic radius,         // String or number; Cloud Function stores String
  required dynamic fkAircraftId,   // Number-like string or int
  required dynamic pkTripId,       // 0/null for new; number for update
  bool? isEdit,
  String? crewMembers,             // not used by Cloud Function (legacy param), ignored
  required bool? isDirectTrip,
}) async {
  // --- helpers to match Cloud Code’s legacy expectations ---
  int tiny(dynamic v) {
    if (v == null) return 0;
    if (v is bool) return v ? 1 : 0;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true') return 1;
    final n = int.tryParse(s);
    return (n == null) ? 0 : (n != 0 ? 1 : 0);
  }

  int? toIntOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  String isoOrOriginal(String v) {
    // If already ISO (contains 'T' and ends with 'Z'), pass through.
    if (v.contains('T') && (v.endsWith('Z') || v.endsWith('+00:00'))) return v;
    // Try to convert common "yyyy-MM-dd HH:mm:ss" to ISO Z
    try {
      final dt = DateTime.parse(v.replaceFirst(' ', 'T'));
      return dt.toUtc().toIso8601String();
    } catch (_) {
      // Best effort: let server parse. Cloud Code will try new Date(v).
      return v;
    }
  }

  // Decide operation: stick to 'Insert' (function internally upserts)
  final operation = 'Insert';
  final loggedInId = pkPilotId; // keep whatever you used before

  final params = <String, dynamic>{
    // legacy parameter names expected by Cloud Code:
    'paramOpration': operation,
    'parampkTripId': toIntOrNull(pkTripId),              // null/0 => insert path
    'paramloggedinid': toIntOrNull(loggedInId) ?? 0,

    'parmTripName': tripName,
    'paramDepartureCode': departureCode ?? '',
    'paramDestinationCode': destinationCode ?? '',
    'paramenroute_airportCode': enroutCode ?? '',

    'paramDepaLocaton': '',        // your old code sends empty strings; preserved
    'paramDestLocation': '',

    'paramCaptain': tiny(captain),
    'paramSecondInCommand': tiny(secondInCommand),
    'paramFlightAttendant': tiny(flightAttendant),
    'paramFlightInstructor': tiny(flightInstructor),

    'paramtripStartDate': isoOrOriginal(tripStartDate),
    // Cloud function expects paramtripEndStart (legacy name)
    'paramtripEndStart': isoOrOriginal(tripEndDate),

    // IMPORTANT: if your schema currently has fkAircraftId as String, pass String.
    // If you migrated it to Number, pass int.
    'paramnearfkAircraftId': toIntOrNull(fkAircraftId),

    // nearMeCaptain isn’t in the old API body; omit unless you have it:
    // 'paramnearMeCaptain':  toIntOrNull(nearMeCaptain),

    'paramEntryDate': DateTime.now().toUtc().toIso8601String(),
    'paramIsDirectTrip': tiny(isDirectTrip == true ? 1 : 0),

    // Radius upsert (radiustripmaster)
    'paramRadius': radius?.toString() ?? '',
  };

  // If your class still has nearMeCaptain as STRING and you want to set it:
  // params['paramnearMeCaptain'] = (nearMeCaptain == null) ? null : nearMeCaptain.toString();

  try {
    final ParseCloudFunction func = ParseCloudFunction('inserttrip');
    final ParseResponse resp = await func.execute(parameters: params);

    debugPrint("resp: $resp");
    if (resp.success && resp.result != null) {
      // resp.result should look like: { ok: true, ReturnValue: <pkTripId>, operation: 'insert'|'update' }
      final map = Map<String, dynamic>.from(resp.result);
      // Build your InsertTripResponse in-place (or keep your model constructor).
      return InsertTripResponse.fromJson(map);
    } else {
      // you can inspect resp.error for details
      return null;
    }
  } catch (e) {
    // log/trace as you did before
    debugPrint(e.toString());
    return null;
  }
}

Future<TripDetailsResponse?> updateReadUnreadTrip(
    {required int? TripId, required bool IsRead}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}UpdateReadUnreadTrip');
  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "tripid": TripId,
  //       "loggedinpilotid": pkPilotId,
  //       "IsRead": IsRead
  //     }));
  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = TripDetailsResponse.fromJson(jsonDecode(response.body));

  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<FilterPilotResponse?> filterPilot({
  var otherSelectTraining,
  var pilotrate,
  var SICRate,
  required String totalTime,
  bool? sptraning,
  required String totalTimeType,
  required String picTime,
  required String picTimeType,
  required String medicalClass,
  required dynamic validPassport,
  required String ratingType,
  required String continentExp,
  var monthTraining,
  required bool isFavorite,
  required bool isAvailable,
  required bool isNearest,
  required bool searchAll,
  required String tripId,
  var rate,
  required String ratingCount,
  required String aircraftID,
  required String ratingAirCraftType,
  required String oceanicExp,
  var yearofexperience,
  String? miles,
  String? languages,
  bool? showprofile,
  bool? isaircraftspecifictraning,
  String? internationalvisa,
  bool? uspass,
  bool? speacialtrainingbool,
  bool? monthexp,
  String? startDate,
  String? endDate,
}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}filterPilot');
  // print('$rate this is rate from api side ');
  // print(''' {
  //       "loggedinpilotid": ${pkPilotId.toString()},
  //       "TotalTime": $totalTime,
  //       //Total Of SIC
  //       "fkAircraftId1": $totalTimeType,
  //       //SIC Total For Specific Aircraft
  //       "picktime": $picTime,
  //       //Total Of PIC
  //       "picktimeaircraftid": $picTimeType,
  //       //PIC Total For Specific Aircraft
  //       "FAAMedical": $medicalClass,
  //       "HavePassport": $validPassport,
  //       "rating": $ratingType,
  //       // Rating Certificate Name
  //       "RatingAirCraftType": $ratingAirCraftType,
  //       //Rating Certificate Aircraft Name
  //       "Continent": $continentExp,
  //       "IsReqPrev12MonthTraining": $monthTraining,
  //       "pilotRate": $pilotrate,
  //       "IsSpecialTrained": $speacialtrainingbool,
  //       "SICRate": $SICRate,
  //       "yearOfExperiance": ${yearofexperience.toString()},
  //       "tripid": $tripId,
  //       "IsShowProfile": $showprofile,
  //       "LanguagesSpoken": $languages,
  //       "rate": ${rate.toString()},
  //       //Filter Rate
  //       "isNearest": $isNearest,
  //       //Miles
  //       "Miles": $miles,
  //       "isFavrouite": $isFavorite,
  //       "IsAvailable": $isAvailable,
  //       "IsSearchAll": $searchAll,
  //       "ratingCount": $ratingCount,
  //       "OceanicExp": $oceanicExp,
  //       "isAircraftSpecificTraining": $isaircraftspecifictraning,
  //       "InternationalVisas": $internationalvisa,
  //       "CurrentUnrestrictedUSPass": $uspass,
  //       "SpecialTrainedOther": $otherSelectTraining,
  //       "TripStartDate": $startDate,
  //       "TripEndDate": $endDate,
  //     }''');
  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "loggedinpilotid": pkPilotId.toString(),
  //       "TotalTime": totalTime,
  //       //Total Of SIC
  //       "fkAircraftId1": totalTimeType,
  //       //SIC Total For Specific Aircraft
  //       "picktime": picTime,
  //       //Total Of PIC
  //       "picktimeaircraftid": picTimeType,
  //       //PIC Total For Specific Aircraft
  //       "FAAMedical": medicalClass,
  //       "HavePassport": validPassport,
  //       "rating": ratingType,
  //       // Rating Certificate Name
  //       "RatingAirCraftType": ratingAirCraftType,
  //       //Rating Certificate Aircraft Name
  //       "Continent": continentExp,
  //       "IsReqPrev12MonthTraining": monthTraining,
  //       "pilotRate": pilotrate,
  //       "IsSpecialTrained": speacialtrainingbool,
  //       "SICRate": SICRate,
  //       "yearOfExperiance": yearofexperience.toString(),
  //       "tripid": tripId,
  //       "IsShowProfile": showprofile,
  //       "LanguagesSpoken": languages,
  //       "rate": rate.toString(),
  //       //Filter Rate
  //       "isNearest": isNearest,
  //       //Miles
  //       "Miles": miles,
  //       "isFavrouite": isFavorite,
  //       "IsAvailable": isAvailable,
  //       "IsSearchAll": searchAll,
  //       "ratingCount": ratingCount,
  //       "OceanicExp": oceanicExp,
  //       "isAircraftSpecificTraining": isaircraftspecifictraning,
  //       "InternationalVisas": internationalvisa,
  //       "CurrentUnrestrictedUSPass": uspass,
  //       "SpecialTrainedOther": otherSelectTraining,
  //       "TripStartDate": startDate,
  //       "TripEndDate": endDate,
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   print('$map');

  //   if (kDebugMode) {
  //     log("searchByResponse Captain");
  //     log('$map');
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = FilterPilotResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<ViewProfileResponse?> viewProfile(String pilotid) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}/viewProfile');
  // log("$finalUri\n$pilotid");

  // final http.Response response = await client.post(finalUri,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(
  //         <String, dynamic>{"loggedinpilotid": pilotid, "pkPilotId": pilotid}));

  // if (kDebugMode) {}

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = ViewProfileResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<Available?> getAvailble(pilotId) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}AvailabalePilotList');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "pkPilotId": pilotId,
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     log("+++++$map");
  //     print("+++++avil list ${map['data']['AvailList']}");
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = Available.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
}

Future<GetFavoriteModel?> getFavoriteList() async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}GetFavourite');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "fkPilotid": pkPilotId,
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     print(map);
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = GetFavoriteModel.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
}

// Future<GetRatingCertificateResponse?> getRatingCertificate(
    // String pilotID) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}getRatingCerti');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{"fkPilotId": pilotID}));

  // if (kDebugMode) {}

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print("certi");
  //     log("$map");
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel =
  //         GetRatingCertificateResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
// }

Future<InsertUpdateFavouriteResponse?> insertUpdateFavourite({
  required String userId,
  required String pilotID,
  required bool isFavourite,
}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}insertupdateFavourite');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "fkUserID": pkPilotId,
  //       "fkPilotid": userId,
  //       "isFavourite": isFavourite.toString()
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     print(map);
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel =
  //         InsertUpdateFavouriteResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
}

Future<SendNotificationResponse?> sendNotification(
    {required String filterPilotId,
    required String tripId,
    required String SICNumber,
    String? oldCrewMemberId,
    String? membershipId,
    String? startDate,
    String? endDate,
    bool? isEdit,
    required var rate}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}sendNotification');
  // print("In SIC from API ${SICNumber}");
  // print("In filter pilot from API ${filterPilotId}");
  // print('''
  // {
  //       "PilotIdWithMulti": $filterPilotId,
  //       "loggedinpilotid": $pkPilotId,
  //       "SICNumber":$SICNumber,
  //       "tripid": $tripId,
  //       "OldCrewMemberId": $oldCrewMemberId,
  //       "IsEdit": ${isEdit == true ? 1 : 0},
  //       "MemberShipType": $membershipId,
  //       "TripStartDate": $startDate,
  //       "TripEndDate": $endDate,
  //       "rate": $rate
  //     }
  // ''');
  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "PilotIdWithMulti": filterPilotId,
  //       "loggedinpilotid": pkPilotId,
  //       "SICNumber": SICNumber,
  //       "tripid": tripId,
  //       "OldCrewMemberId": oldCrewMemberId,
  //       "IsEdit": isEdit == true ? 1 : 0,
  //       "MemberShipType": membershipId,
  //       "TripStartDate": startDate,
  //       "TripEndDate": endDate,
  //       "rate": rate
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel =
  //         SendNotificationResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<TripDetailsResponse?> getTripDetailMultiplePilot(
    {required int tripId,
    required int oppositeId,
    required String MemberType,
      String? status}) async {
  print(
      "pkTripId : ${tripId},loggedinid : ${pkPilotId} this trip id and piolt id");
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}getTripDetailMultiple');
  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "pkTripId": tripId,
  //       "loggedinid": pkPilotId,
  //       "oppositid": oppositeId,
  //       "MembershipType": MemberType,
  //       "Status" : status
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     // log("$map");
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = TripDetailsResponse.fromJson(jsonDecode(response.body));

  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<TripDetailsResponse?> updateTripNotification(
    {required int? TripId, required String NotificationId}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}UpdateTripNotification');
  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "loggedinpilotid": pkPilotId,
  //       "pkTripNotificationId": NotificationId,
  //       "tripid": TripId
  //     }));
  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = TripDetailsResponse.fromJson(jsonDecode(response.body));

  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future deleteDraft(tripId) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}/forDeletetrip');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{"pkTripId": tripId}));

  // if (kDebugMode) {}

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel = jsonDecode(response.body);
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<FilterSicResponse?> filterSecondInCommand({
  required String totalTime,
  required String totalTimeType,
  required String medicalClass,
  required bool validPassport,
  required String ratingType,
  required String continentExp,
  required String monthTraining,
  required bool isFavorite,
  required bool isAvailable,
  required bool searchAll,
  required String miles,
  required bool isNearest,
  required int tripId,
  required int airCraftId,
  required String rate,
  required String ratingCount,
  required String ratingAirCraftType,
  String? startDate,
  String? endDate,
  String? fAAMedical,
}) async {
  print(totalTime);
  print(totalTimeType);
  print(medicalClass);
  print(validPassport);
  print(ratingType);
  print(continentExp);
  print(monthTraining);
  print(isFavorite);
  print(isAvailable);
  print(isNearest);
  print(tripId);
  print(airCraftId);
  print(rate);
  print(ratingCount);
  print(ratingAirCraftType);
  print(fAAMedical);
  print(miles);
//   ApiConfig apiConfig = ApiConfig();
//   var str = await apiConfig.geturlString();
//   Uri finalUri = Uri.parse('${str}filterSecondInCommand');
//   log('''
// {
//         "loggedinpilotid": $pkPilotId,
//         "TotalTime": $totalTime,
//         "fkAircraftId1": $totalTimeType,
//         "FAAMedical": $medicalClass,
//         "HavePassport": $validPassport,
//         "rating": $ratingType,
//         "RatingAirCraftType": $ratingAirCraftType,
//         "Continent": $continentExp,
//         "IsReqPrev12MonthTraining": $monthTraining,
//         "tripid": $tripId,
//         "rate": $rate,
//         "Miles": $miles,
//         "isNearest": $isNearest,
//         "isFavrouite": $isFavorite,
//         "IsSearchAll": $searchAll,
//         "IsAvailable": $isAvailable,
//         "ratingCount": ${ratingCount == "0" ? "" : ratingCount},
//         "TripStartDate": $startDate,
//         "TripEndDate": $endDate
//       }
// ''');

//   final http.Response response = await client.post(finalUri,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(<String, dynamic>{
//         "loggedinpilotid": pkPilotId,
//         "TotalTime": totalTime,
//         "fkAircraftId1": totalTimeType,
//         "FAAMedical": medicalClass,
//         "HavePassport": validPassport,
//         "rating": ratingType,
//         "RatingAirCraftType": ratingAirCraftType,
//         "Continent": continentExp,
//         "IsReqPrev12MonthTraining": monthTraining,
//         "tripid": tripId,
//         "rate": rate,
//         "Miles": miles,
//         "isNearest": isNearest,
//         "isFavrouite": isFavorite,
//         "IsSearchAll": searchAll,
//         "IsAvailable": isAvailable,
//         "ratingCount": ratingCount == "0" ? "" : ratingCount,
//         "TripStartDate": startDate,
//         "TripEndDate": endDate
//       }));

//   try {
//     Map<String, dynamic> map = json.decode(response.body);

//     if (kDebugMode) {
//       print(map);
//     }

//     if (response.statusCode == 200) {
//       var userModel = FilterSicResponse.fromJson(jsonDecode(response.body));
//       return userModel;
//     } else {
//       return null;
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print(e.toString());
//     }

//     return null;
//   }
}

Future<FilterFlightAttedantResponse?> filterFlightAttedant({
  required String yrExp,
  required bool aircraftSpeTraining,
  // bool? unrestrictedUSPass,
  required bool specialTraining,
  required String languageSpoken,
  required bool validPassport,
  required String internationalVisa,
  required String continentExp,
  required String ocenicexp,
  required String internationalVisas,
  bool? monthTraining,
  required bool profile,
  required bool gender,
  required bool isFavorite,
  required bool isAvailable,
  required bool searchAll,
  required bool isNearest,
  required int tripId,
  required String miles,
  required int airCraftId,
  required String rate,
  required String ratingCount,
  required String specialTrainedName,
  required String otherSelectTraining,
  String? startDate,
  String? endDate,
}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}filterFlightAttedant');

  // log('''
  // {
  //        "loggedinpilotid": $pkPilotId,
  //       "InternationalVisas": "",
  //       "yearOfExperiance": $yrExp, //4 no FA Experience=2
  //       "HavePassport": $validPassport, //No=0,Yes=1
  //       "Continent": ${continentExp.toString()}, //4 no FA has not continent
  //       "isAircraftSpecificTraining": $aircraftSpeTraining, //0=false,1=true
  //       "LanguagesSpoken": ${languageSpoken.toString()},
  //       "CullinaryTraining": true,
  //       "Cullinary": "",
  //       "CullinaryOther": "",
  //       "IsSpecialTrained": $specialTraining,
  //       "SpecialTrained": $specialTrainedName,
  //       "SpecialTrainedOther": $otherSelectTraining,
  //       "IsReqPrev12MonthTraining": false,
  //       "onlyshowprofwithpic": ${profile == true ? "1" : "0"},
  //       "HideGender": $gender,
  //       "tripid": $tripId,
  //       "Miles": $miles,
  //       "rating": $rate, //4 No FA Rate Is 100(Domestic) For InterNational 200
  //       "ratingCount": $ratingCount,
  //       "isNearest": $isNearest,
  //       "isFavrouite": $isFavorite,
  //       "IsSearchAll": $searchAll,
  //       "TripStartDate": $startDate,
  //       "TripEndDate": $endDate,
  //       "IsAvailable": $isAvailable
  //     }
  // ''');
  // // if (yrExp == "Less than 1 year") {
  // //   yrExp = "1-2";
  // // } else if (yrExp == "1-3 years") {
  // //   yrExp = "1-3";
  // // } else if (yrExp == "3-5 years") {
  // //   yrExp = "3-5";
  // // } else if (yrExp == "5-10 years") {
  // //   yrExp = "5-10";
  // // } else if (yrExp == "More than 10 years") {
  // //   yrExp = "5-10";
  // // }

  // print(
  //     "Pilotid: $pkPilotId YOE: $yrExp ValidPass: $validPassport Continent: ${continentExp.toString()} aircraft: $aircraftSpeTraining language: ${languageSpoken.toString()} special: $specialTraining specialName: $specialTrainedName othertrain: $otherSelectTraining monthtrain: $monthTraining profile: $profile tripid: $tripId radius: $miles rate: $rate ratingCount: $ratingCount isAvail: $isAvailable isFav: $isFavorite isNear: $isNearest Gender: $gender");

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "loggedinpilotid": pkPilotId,
  //       "InternationalVisas": "",
  //       "yearOfExperiance": yrExp, //4 no FA Experience=2
  //       "HavePassport": validPassport, //No=0,Yes=1
  //       "Continent": continentExp.toString(), //4 no FA has not continent
  //       "isAircraftSpecificTraining": aircraftSpeTraining, //0=false,1=true
  //       "LanguagesSpoken": languageSpoken.toString(),
  //       "CullinaryTraining": true,
  //       "Cullinary": "",
  //       "CullinaryOther": "",
  //       "IsSpecialTrained": specialTraining,
  //       "SpecialTrained": specialTrainedName,
  //       "SpecialTrainedOther": otherSelectTraining,
  //       "IsReqPrev12MonthTraining": false,
  //       // "CurrentUnrestrictedUSPass": false,
  //       "onlyshowprofwithpic": profile == true ? "1" : "0",
  //       "HideGender": gender,
  //       "tripid": tripId,
  //       "Miles": miles,
  //       "rating": rate, //4 No FA Rate Is 100(Domestic) For InterNational 200
  //       "ratingCount": ratingCount,
  //       "isNearest": isNearest,
  //       "isFavrouite": isFavorite,
  //       "IsSearchAll": searchAll,
  //       "TripStartDate": startDate,
  //       "TripEndDate": endDate,
  //       "IsAvailable": isAvailable
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     log("$map");
  //     // print(map);
  //   }

  //   if (response.statusCode == 200) {
  //     var userModel =
  //         FilterFlightAttedantResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }

  //   return null;
  // }
}

Future<PostUncrewResponse?> postUncrewRequest( {
  required String oppositeId,
 required String tripId,
  required String rate,
  required String startDate,
  required String endDate,
  required String membershiptype,
}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}PostUncrewedTrip');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "PilotIdWithMulti": "",

  //       "loggedinpilotid": oppositeId,

  //       "tripid": tripId,

  //       "rate": rate,

  //       "SICNumber": "",

  //       "OldCrewMemberId": "",

  //       "MemberShipType": membershiptype,

  //       "TripStartDate": startDate,

  //       "TripEndDate": endDate,

  //       "IsEdit": 1
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     print(map);
  //     print('');
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = PostUncrewResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
}

// Future<GetLoginDataResponse?> updateProfileImage({
//   required String photo,
// }) async {
//   ApiConfig apiConfig = ApiConfig();
//   var str = await apiConfig.geturlString();
//   Uri finalUri = Uri.parse('${str}updateProfileImage');


//   final http.Response response = await client.post(finalUri,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(<String, dynamic>{
//         "pkPilotId": pkPilotId,
//         "PhotoPath": photo,
//       }));

//   try {
//     Map<String, dynamic> map = json.decode(response.body);

//     if (kDebugMode) {
//       print('update profile pic response');
//       print(map);
//     }

//     if (response.statusCode == 200) {
//       var userModel = GetLoginDataResponse.fromJson(jsonDecode(response.body));
//       return userModel;
//     } else {
//       return null;
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print(e.toString());
//     }

//     return null;
//   }
// }

Future<GetAvailability?> getAvailability({required String? fkPilotid}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}SelectAllAvailability');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "fkPilotid": fkPilotid,
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     // log("$map");
  //     print(map);
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = GetAvailability.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
  return null;
}

Future<GetLoginDataResponse?> updateAvailability({
  required String commentText,
  required String fromDate,
  required String toDate,
  required String State,
  required String city,
  required int? availableId,
  required bool isUpdate,
  required bool isDelete,
  required String zip,
  bool? available,
}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}UpdateAvailability');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "pkAvailabilityId": availableId,
  //       "fkPilotid": pkPilotId,
  //       "Comment": commentText,
  //       "FromDate": fromDate,
  //       "ToDate": toDate,
  //       "State": State,
  //       "City": city,
  //       "Zip": zip,
  //       "IsAvailability": available == true ? 1 : 0,
  //       //true mean 1 , false mean 0
  //       "IsUpdate": isUpdate.toString(),
  //       "IsDelete": isDelete.toString()
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     print(map);
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = GetLoginDataResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
  return null;
}

// Future<GetAllState?> getAllState() async {
//   // ApiConfig apiConfig = ApiConfig();
//   // var str = await apiConfig.geturlString();
//   // Uri finalUri = Uri.parse('${str}/GetAllCityState');

//   // final http.Response response = await client.post(finalUri);

//   // try {
//   //   Map<String, dynamic> map = json.decode(response.body);

//   //   if (kDebugMode) {
//   //     print(map);
//   //   }
//   //   if (response.statusCode == 200) {
//   //     var userModel = GetAllState.fromJson(jsonDecode(response.body));
//   //     return userModel;
//   //   } else {
//   //     return null;
//   //   }
//   // } catch (e) {
//   //   return null;
//   // }
//   return null;
// }

Future<GetAllCityByState?> getAllCityByState({required String state}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}/GetAllCityByStateWise');

  // final http.Response response = await client.post(
  //   finalUri,
  //   headers: {
  //     'Content-Type': 'application/json',
  //   },
  //   body: jsonEncode(<String, dynamic>{"State": state.toString()}),
  // );

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);

  //   if (kDebugMode) {
  //     print(map);
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = GetAllCityByState.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   return null;
  // }
  return null;
}

Future<GetLoginDataResponse?> insertAvailability({
  required String commentText,
  required String fromDate,
  required String toDate,
  required String State,
  required String city,
  required String Zip,
  bool? availability,
}) async {
  // ApiConfig apiConfig = ApiConfig();
  // var str = await apiConfig.geturlString();
  // Uri finalUri = Uri.parse('${str}InsertAvailability');

  // final http.Response response = await client.post(finalUri,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       "fkPilotid": pkPilotId,
  //       "Comment": commentText,
  //       "FromDate": fromDate, //mm/dd/yyyy
  //       "ToDate": toDate, //mm/dd/yyyy
  //       "State": State,
  //       "ZIp": Zip,
  //       "City": city,
  //       "IsAvailability": availability.toString()
  //     }));

  // try {
  //   Map<String, dynamic> map = json.decode(response.body);
  //   if (kDebugMode) {
  //     print(map);
  //   }
  //   if (response.statusCode == 200) {
  //     var userModel = GetLoginDataResponse.fromJson(jsonDecode(response.body));
  //     return userModel;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e.toString());
  //   }
  //   return null;
  // }
  return null;
}

//Profile related code ===================================

/// Calls Back4App Cloud Code: updateOwnerProfile
Future<bool> updateOwnerProfileOnBack4App({
  required bool isDefaultCompanyName,
  required String firstName,
  required String lastName,
  required String companyName,
  required String gender,
  required String currentLocation, // "ON" or "OFF"
  required String bio,
  required String instagram,
  required String facebook,
  required String linkedin,
}) async {
  try {
    final cloudFunction = ParseCloudFunction('updateOwnerProfile');

    // These keys must match request.params.* used in Cloud Code
    final Map<String, dynamic> params = {
      'isDefaultCompanyName': isDefaultCompanyName,
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'gender': gender,
      'currentLocation': currentLocation,
      'bio': bio,
      'instagram': instagram,
      'facebook': facebook,
      'linkedin': linkedin,
    };

    final ParseResponse response =
        await cloudFunction.execute(parameters: params);

    if (response.success == true &&
        response.result is Map &&
        (response.result['success'] == true)) {
      return true;
    }

    // Optional: log reason
    debugPrint('updateOwnerProfileOnBack4App failed: ${response.error?.message}');
    return false;
  } catch (e) {
    debugPrint('updateOwnerProfileOnBack4App exception: $e');
    return false;
  }
}

// Future<InsertRatingCertificateResponse?> insertRatingCertificate({
//   required String certificate,
//   required int category,
//   required String classRating,
//   required String modelAircraft,
//   required String hours,
//   required String piC,
//   required String minimumRate,
//   required String simulatorCurrent,
//   required String current,
// }) async {
//   // ApiConfig apiConfig = ApiConfig();
//   // var str = await apiConfig.geturlString();
//   // Uri finalUri = Uri.parse('${str}insertRatingCerti');
//   // log('''
//   // {
//   //       "RatingCertification": ${certificate}, //Pass Name Of Rating Certification
//   //       "fkPilotid": ${pkPilotId},
//   //       "fkCategoryId": ${category},
//   //       "fkClassId": ${classRating},
//   //       "AirCraftType": ${modelAircraft}, ////Pass Name Of AirCraftType
//   //       "Hours": $hours, //Pass Numeric
//   //       "PIC": $piC, //Pass Numeric
//   //       "MinimumRate": $minimumRate, //Pass Numeric
//   //       "CurrentInType": $current, //Pass PIC Or SIC Or Both
//   //       "IsReqPrev12MonthTraining": $simulatorCurrent, //Pass PIC Or SIC Or Both
//   //       "EntryDate": "01/03/2019"
//   //     }
//   // ''');
//   // final http.Response response = await client.post(finalUri,
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //     },
//   //     body: jsonEncode(<String, dynamic>{
//   //       "RatingCertification": certificate, //Pass Name Of Rating Certification
//   //       "fkPilotid": pkPilotId,
//   //       "fkCategoryId": category,
//   //       "fkClassId": classRating,
//   //       "AirCraftType": modelAircraft, ////Pass Name Of AirCraftType
//   //       "Hours": hours, //Pass Numeric
//   //       "PIC": piC, //Pass Numeric
//   //       "MinimumRate": minimumRate, //Pass Numeric
//   //       "CurrentInType": current, //Pass PIC Or SIC Or Both
//   //       "IsReqPrev12MonthTraining": simulatorCurrent, //Pass PIC Or SIC Or Both
//   //       "EntryDate": "01/03/2019"
//   //     }));

//   // if (kDebugMode) {}

//   // try {
//   //   Map<String, dynamic> map = json.decode(response.body);

//   //   if (kDebugMode) {
//   //     print(map);
//   //   }

//   //   if (response.statusCode == 200) {
//   //     var userModel =
//   //         InsertRatingCertificateResponse.fromJson(jsonDecode(response.body));
//   //     return userModel;
//   //   } else {
//   //     return null;
//   //   }
//   // } catch (e) {
//   //   if (kDebugMode) {
//   //     print(e.toString());
//   //   }

//   //   return null;
//   // }
// }
