
import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/model/loginswitchModel.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// import '../dataBase/airport_code_model.dart';
// import '../model/GetAllAirportCodeResponse.dart';
// import '../model/GetLoginDataResponse.dart';
// import '../model/loginswitchModel.dart';

bool kIsLogIn = false;
bool kIsFirstTime = false;
bool kIsFirstLoginTime = false;
bool kIsAvailabilityTime = false;
bool isCreateTrip = false;
bool fromPending = false;
String? connectionType;
String? deviceID;
String? PilotFname ;
String? PilotLname;
String? PilotNname;
String? pkPilotId;
String? CurrentLocation ;
String? CuLocCountry;
String? fkMemberShipId;
String? MemberShipType;
String? EmailId;
RxString kPhotoPath = ''.obs;
String? cellNumber;
String? loggedinpilotid;
String? kDeviceToken;
int SelectProfile = 1;
int? liveChatId;
String? installerInfo;
String? oppositeId;
double textDefaultSize = 14.0.sp;
int? pkTripId;

List<Userdatum> switchList= [];
// TODO: Replace with Parse-backed loader / local cache.
// For now, keep the legacy list but store as AirportLite with only ident populated.
final List<AirportLite> airportCode = [
  // Example:
  // AirportLite(sourceId: 0, ident: "VIDP", name: "", latitude: 0, longitude: 0, country: "", region: "", municipality: ""),
];


