
import 'package:crew_support/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHelper{
  SharedPreferences? sharedPreferences;
  Future<void> clearUser() async {
    //kUserID = 0;
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.remove("PilotFname");
    sharedPreferences?.remove("PilotLname");
    sharedPreferences?.remove("PilotNname");
    sharedPreferences?.remove("fkMemberShipId");
    sharedPreferences?.remove("EmailId");
    sharedPreferences?.remove("cellNumber");
    sharedPreferences?.remove('loggedinpilotid');
    sharedPreferences?.remove("PhotoPath");
    sharedPreferences?.remove("pkPilotId");
    sharedPreferences?.remove("isLogIn");
    sharedPreferences?.remove("CompanyName");
    sharedPreferences?.remove("CurrentLocation");
    //sharedPreferences?.remove("isNotification");
  }
  Future<void> clearCurrent() async {
    //kUserID = 0;
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences!.remove('isCreateTrip');
  }
  Future<void> clearPending() async {
    //kUserID = 0;
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences!.remove("PendingScreen");
  }
  Future<void> setinstallerInfo(var installerInfo) async{
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setString("installerInfo", installerInfo.toString());
  }
  Future<void> getinstallerInfo() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    installerInfo = sharedPreferences.getString('installerInfo');
  }
  Future<void> setAppType(var appType) async{
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setString("appType", appType.toString());
  }
  Future<void> getAppType() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    installerInfo = sharedPreferences.getString('appType');
  }
  Future<void> setUser(var user,String connectionType,String deviceID) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setString("PilotFname", user.pilotFname.toString());
    sharedPreferences?.setString("PilotLname", user.pilotLname.toString());
    sharedPreferences?.setString("PilotNname", user.pilotLname.toString());
    sharedPreferences?.setString("CompanyName", user.pilotLname.toString());
    sharedPreferences?.setString("CurrentLocation", user.currentLocation.toString());
    sharedPreferences?.setString("CuLocCountry", user.cuLocCountry.toString());
    sharedPreferences?.setString("fkMemberShipId", user.fkMemberShipId.toString());
    sharedPreferences?.setString('EmailId', user.emailId.toString());
    sharedPreferences?.setString('MemberShipType', user.memberShipType.toString());
    sharedPreferences?.setString("connectionType", '');
    sharedPreferences?.setString("deviceID", '');

    sharedPreferences?.setString("cellNumber", user.cellNumber.toString());
    sharedPreferences?.setString("PhotoPath", user.photoPath.toString());
    sharedPreferences?.setString("loggedinpilotid", '');
    sharedPreferences?.setString("pkPilotId", user.pkPilotId!.toString());
    sharedPreferences?.setBool("isLogIn", true);



    //print('$pilotFname $kUserLastName $kUserEmail $kProfilePic');

  }

  Future<void> getUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    kIsLogIn = sharedPreferences.getBool('isLogIn') ?? false;
    PilotFname = sharedPreferences.getString('PilotFname');
    PilotLname = sharedPreferences.getString('PilotLname');
    PilotNname = sharedPreferences.getString('PilotNname');
    pkPilotId = sharedPreferences.getString('pkPilotId');
    CurrentLocation = sharedPreferences.getString('CurrentLocation');
    CuLocCountry = sharedPreferences.getString('CuLocCountry');
    fkMemberShipId = sharedPreferences.getString('fkMemberShipId');
    MemberShipType = sharedPreferences.getString('MemberShipType');
    EmailId = sharedPreferences.getString('EmailId');
    kPhotoPath.value = sharedPreferences.getString('PhotoPath')!;
    cellNumber = sharedPreferences.getString('cellNumber');
    loggedinpilotid = sharedPreferences.getString('loggedinpilotid');
    connectionType = sharedPreferences.getString('connectionType') ?? '';
    deviceID = sharedPreferences.getString('deviceID') ?? '';
    //kAppCurrency = sharedPreferences.getString('currency');
    //kUserID = sharedPreferences.getInt('userId');


  }
  Future<void> setWelcome() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setBool("kIsFirstTime", true);
  }
  Future<void> getWelcome() async {
    sharedPreferences = await SharedPreferences.getInstance();
    kIsFirstTime = sharedPreferences!.getBool("kIsFirstTime")! ;
  }

  Future<void> setLoginWelcome(bool isTrue) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setBool("kIsFirstLoginTime", isTrue);
  }
  Future<void> getLoginWelcome() async {
    sharedPreferences = await SharedPreferences.getInstance();
    kIsFirstLoginTime = sharedPreferences!.getBool("kIsFirstLoginTime")! ;
  }
  Future<void> setAvailability(bool isTrue) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setBool("kIsAvailabilityTime", isTrue);
  }
  Future<void> getAvailability() async {
    sharedPreferences = await SharedPreferences.getInstance();
    kIsAvailabilityTime = sharedPreferences!.getBool("kIsAvailabilityTime")! ;
  }
  Future<void> fromPendingDetail(bool isTrue) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setBool("PendingScreen", isTrue);
  }
  Future<void> getPendingDetail() async {
    sharedPreferences = await SharedPreferences.getInstance();
    fromPending = sharedPreferences!.getBool("PendingScreen")! ;
  }
  Future<void> updateUserPhoto(String  userImage) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setString("PhotoPath", userImage);
  }
  Future<void> setIsCreateTripFlag(bool isCreateTrip) async{
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setBool('isCreateTrip', isCreateTrip);
  }
  Future<void> getIsCreateTrip() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isCreateTrip = sharedPreferences!.getBool('isCreateTrip')!;
  }
  Future<void> setSelectProfile(int profile) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.setInt("Profile", profile);
  }
}

String getMembershipTypeText(int? type) {
  switch (type) {
    case 1:
      return 'Owner/Operator';
    case 2:
      return 'Instructor';
    case 3:
      return 'Pilot';
    case 4:
      return 'Flight Attendant';
    default:
      return 'Unknown';
  }
}

String getGenderText(int? gender) {
  switch (gender) {
    case 0:
      return 'Male';
    case 1:
      return 'Female';
    case 2:
      return 'Other';
    default:
      return 'Unknown';
  }
}

String getMembershipTitle(String? type) {
  switch (type) {
    case '1':
      return 'Owner/Operator';
    case '2':
      return 'Instructor';
    case '3':
      return 'Pilot';
    case '4':
      return 'Flight Attendant';
    default:
      return 'Unknown';
  }
}


// For ratingCertification:

// Class list (same as old code)
final List<String> classList = const [
  "Multi Engine land",
  "Single Engine land",
  "Multi Engine sea",
  "Single Engine Sea",
];

int getClassRatingFromText(String? classText) {
  int classRating = 0;
  if (classText == classList[0]) {
    classRating = 1;
  } else if (classText == classList[1]) {
    classRating = 2;
  } else if (classText == classList[2]) {
    classRating = 3;
  } else if (classText == classList[3]) {
    classRating = 4;
  }
  return classRating;
}

String getClassRatingTextFromId(int? id) {
  switch (id) {
    case 1:
      return 'Multi Engine land';
    case 2:
      return 'Single Engine land';
    case 3:
      return 'Multi Engine sea';
    case 4:
      return 'Single Engine sea';
    default:
      return "Unknown";
  }
}

final List<String> categoryList = const [
  "Airplane",
  "Helicopter",
];

int getCategoryValueFromText(String? categoryText) {
  int categoryValue = 0;
  if (categoryText == categoryList[0]) {
    categoryValue = 1;
  } else if (categoryText == categoryList[1]) {
    categoryValue = 3;
  }
  return categoryValue;
}

String getCategoryTextFromId(int? id) {
  switch (id) {
    case 1:
      return 'Airplane';
    case 3:
      return 'Helicopter';
    default:
      return "Unknown";
  }
}