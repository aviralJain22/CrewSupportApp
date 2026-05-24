import 'package:crew_support/model/loginswitchModel.dart';

class MockUser {
  static final Userdatum pilot = Userdatum(
    pkPilotId: 1001,
    pilotFname: "John",
    pilotLname: "Doe",
    emailId: "pilot@test.com",
    companyName: "Test Airlines",
    memberShipType: "Pilot",
    fkMemberShipId: 3,
    cellNumber: "+15550001",
    photoPath: "https://i.pravatar.cc/150?u=pilot",
    currentLocation: true,
    cuLocCountry: "USA",
  );

  static final Userdatum attendant = Userdatum(
    pkPilotId: 1002,
    pilotFname: "Jane",
    pilotLname: "Smith",
    emailId: "attendant@test.com",
    companyName: "Test Airlines",
    memberShipType: "Flight Attendant",
    fkMemberShipId: 4,
    cellNumber: "+15550002",
    photoPath: "https://i.pravatar.cc/150?u=attendant",
    currentLocation: true,
    cuLocCountry: "USA",
  );

  static final List<Userdatum> all = [pilot, attendant];
}
