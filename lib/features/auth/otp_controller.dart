// lib/features/auth/otp_controller.dart
// New GetX controller converted from old `otp_generate.dart`.
// Matches legacy logic, splits business logic out of UI, and preserves
// EasyLoading + showLoadingDialog/showMyDialog behavior.
//
// NOTE: Ensure you have the `spV2` extension imported somewhere globally.
// If it's defined in your project (e.g., utils/sizer_compat.dart), import it here.
// import 'package:crew_support/utils/sizer_compat.dart';

import 'dart:async';

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/pref_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// App utils & services (same names as legacy code)
// Make sure these files exist and expose the same APIs used in the old screen.
import 'package:crew_support/utils/Utility.dart'; // showLoadingDialog, showMyDialog, getConnectionStringType, getDeviceId

class OtpController extends GetxController {
  // ====== Inputs carried over from old GenerateOtp widget props ======
  late final String email;
  late final String password;
  late final int membershipType;
  late final int gender;
  late final String countryCode;
  late final String dialCode;
  late final String countryName;
  late final String phoneNumber;
  late final String firstName;
  late final String lastName;
  
  String? otp; // incoming OTP (server-generated)

  // ====== UI/State ======
  final otpCodeLength = 4;
  final showTimer = false.obs;
  final otpPressed = false.obs;
  final isFilled = true.obs;
  final inCorrectOtp = false.obs;
  final isFromAndroidOTP = false.obs;

  final otpController = TextEditingController();

  // Internal
  final intRegex = RegExp(r'\d+', multiLine: true);
  late StopWatchTimer _stopWatchTimer;

  // Stream to expose countdown seconds for the UI
  late final Stream<int> secondTimeStream;
  late final ValueNotifier<int> initialSecondTime;

  // ====== Lifecycle ======
  @override
  void onInit() {
    super.onInit();

    // Expecting a Map arguments payload with the below keys.
    final args = Get.arguments as Map<String, dynamic>?;

    email = args?['email'] ?? '';
    password = args?['password'] ?? '';
    membershipType = args?['membershipType'] ?? 0;
    gender = args?['gender'] ?? 0;
    countryCode = args?['countryCode'] ?? '';
    dialCode = args?['dialCode'] ?? '';
    countryName = args?['countryName'] ?? '';
    phoneNumber = args?['phoneNumber'] ?? '';
    firstName = args?['firstName'] ?? '';
    lastName = args?['lastName'] ?? '';
    // otp = args?['otp'];
    

    // _initSignatureAndListener();

    // Prepare countdown (30s) for "Resend OTP"
    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(30),
      onEnded: _setTime,
    );
    secondTimeStream = _stopWatchTimer.secondTime;
    initialSecondTime = ValueNotifier<int>(_stopWatchTimer.secondTime.value);

    // initial UI state
    showTimer.value = false;

    // Start the 30s countdown immediately so user can resend after it ends.
    _startResendCountdown();
  }

  @override
  void onClose() {
    // Stop SMS listener and cleanup
    // SmsVerification.stopListening();
    EasyLoading.dismiss();
    _stopResendCountdown();
    _stopWatchTimer.dispose();
    otpController.dispose();
    super.onClose();
  }

  // ====== SMS Reading ======
  // Future<void> _initSignatureAndListener() async {
  //   await _getSignatureCode();
  //   // _startListeningSms();
  // }

  // Future<void> _getSignatureCode() async {
  //   final signature = await SmsVerification.getAppSignature();
  //   if (kDebugMode) {
  //     debugPrint('signature: $signature');
  //   }
  // }

  // void _startListeningSms() {
  //   SmsVerification.startListeningSms().then((message) {
  //     _otpCode = SmsVerification.getCode(message, intRegex);
  //     if (kDebugMode) debugPrint('OTP is $_otpCode');
  //     isFromAndroidOTP.value = true;
  //     otpController.text = _otpCode;
  //   });
  // }

  // Future<bool> requestPermission(Permission permission) async {
  //   if (await permission.isGranted) return true;
  //   final result = await permission.request();
  //   return result == PermissionStatus.granted;
  // }

  // ====== Timer ======
  void _setTime() {
    showTimer.value = true; // allows "Resend OTP"
  }

  /// Starts (or restarts) the 30s cooldown timer for "Resend OTP".
  void _startResendCountdown() {
    showTimer.value = false; // hide resend until cooldown completes

    // Reset and start the countdown (stop_watch_timer ^3.x API)
    _stopWatchTimer.onResetTimer();
    _stopWatchTimer.onStartTimer();

    // Ensure StreamBuilder initialData is correct right after restart.
    initialSecondTime.value = _stopWatchTimer.secondTime.value;
  }

  /// Stops the cooldown timer (usually not needed, but kept for completeness).
  void _stopResendCountdown() {
    _stopWatchTimer.onStopTimer();
  }

  void _closeAnyDialogSafely() {
    final ctx = Get.context;
    if (ctx == null) return;

    final nav = Navigator.of(ctx, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  // ====== Actions ======
  /// Called when user taps "Resend OTP".
  Future<void> resendOtp() async {
    otpPressed.value = true;
    showLoadingDialog(Get.context!, 'Sending...');
    // if (Platform.isAndroid) {
    //   _startListeningSms();
    // }

    try {
      // Call backend to resend OTP
      final cloudFunction = ParseCloudFunction('sendOTP');
      final params = <String, dynamic>{
        'phoneNumber': dialCode + phoneNumber.trim(),
      };

      final ParseResponse response =
          await cloudFunction.execute(parameters: params);

      if (response.success && response.result != null) {
        // Clear current input and restart cooldown
        otpController.clear();
        otpPressed.value = false;
        _startResendCountdown();
      } else {
        otpPressed.value = false;
        showMyDialog(
          Get.context!,
          response.error?.message ?? 'Failed to resend OTP. Please try again.',
        );
      }
    } catch (e) {
      otpPressed.value = false;
      showMyDialog(Get.context!, 'Failed to resend OTP. Please try again.');
    } finally {
      // ✅ This guarantees the loader goes away.
      _closeAnyDialogSafely();
    }
  }

  /// Called when the user finishes entering the OTP (either typed or auto-read).
  Future<void> otpDone() async {
    showLoadingDialog(Get.context!, 'Logging...');
    debugPrint("otpController.text: ${otpController.text}");

    final cloudFunction = ParseCloudFunction('verifyOTPAndSignUp');
    final params = <String, dynamic>{
      'code': otpController.text,
      'email': email,
      'password': password,
      'membershipType': membershipType,
      'gender': gender,
      'countryCode': countryCode,
      'dialCode': dialCode,
      'countryName': countryName,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
    };

    final ParseResponse response = await cloudFunction.execute(parameters: params);

    if (response.success && response.result != null) {
      // User is created! Navigate to the home screen or login screen.
      debugPrint("account created!");
      debugPrint("now loging in");

      final user = ParseUser(email, password, null);
      
      var loginResponse = await user.login();

      Get.back(); // closes the dialog shown by showLoadingDialog

      if (loginResponse.success) {
        EasyLoading.showSuccess('Logged in');

        // After successful login, read role flags from _User and store selectedProfileType
      try {
        final ParseUser? currentUser =
            await ParseUser.currentUser() as ParseUser?;

        if (currentUser != null) {
          final bool isOwner = currentUser.get<bool>('owner') ?? false;
          final bool isPilot = currentUser.get<bool>('pilot') ?? false;
          final bool isInstructor = currentUser.get<bool>('instructor') ?? false;
          final bool isAttendant = currentUser.get<bool>('attendant') ?? false;

          int selectedProfileType = 0;

          if (isOwner) {
            selectedProfileType = MembershipType.ownerOperator;
          } else if (isPilot) {
            selectedProfileType = MembershipType.pilot;
          } else if (isAttendant) {
            selectedProfileType = MembershipType.flightAttendant;
          } else if (isInstructor) {
            selectedProfileType = MembershipType.instructor;
          } else {
            selectedProfileType = 0;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(PrefKeys.selectedProfileType, selectedProfileType);

          debugPrint(
            'Saved selectedProfileType = $selectedProfileType '
            '(${MembershipType.typeLabels[selectedProfileType] ?? "Unknown"})'
          );
        } else {
          debugPrint('No currentUser found after login.');
        }
      } catch (e) {
        debugPrint('Error while setting selectedProfileType: $e');
      }

        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        EasyLoading.showError('Login failed: ${loginResponse.error!.message}');
      }

    } else {
      Get.back(); // closes the dialog shown by showLoadingDialog
      EasyLoading.showError(response.error?.message ?? "An unknown error occurred.");
    }

    // if (otpController.text == otp) {
      // Proceed with verify/register call
      // try {
      //   final value = await insertZVerifyPilot(
      //     emailId: emailId,
      //     confirmPassword: password,
      //     membershipId: memberShipId,
      //     firstName: pilotFName,
      //     lastName: pilotLName,
      //     gender: gender?.toString() ?? '',
      //     phone: mobileNumber,
      //     otp: otp?.toString() ?? '',
      //     newPassword: password,
      //     country: country,
      //     dileCode: countryCode,
      //   );

      //   if (value?.msg == 'record found') {
      //     // Mirror legacy post-login bookkeeping
      //     for (int i = 0; i < switchList.length; i++) {
      //       if (switchList[i].pkPilotId.toString() ==
      //           value!.data!.pilot.pkPilotId.toString()) {
      //         switchList.remove(switchList[i]);
      //       }
      //     }

      //     final connectionType = await getConnectionStringType();
      //     final deviceID = await getDeviceId();

      //     await UserHelper()
      //         .setUser(value!.data!.pilot, connectionType, deviceID);

      //     // Update the local switch list (same as legacy)
      //     switchList.add(
      //       Userdatum(
      //         pilotMname: value.data!.pilot.pilotMname.toString(),
      //         emailId: value.data!.pilot.emailId.toString(),
      //         workNumber: value.data!.pilot.workNumber.toString(),
      //         newPassword: value.data!.pilot.newPassword.toString(),
      //         pilotNname: value.data!.pilot.pilotNname.toString(),
      //         photoPath: value.data!.pilot.photoPath.toString(),
      //         cellNumber: value.data!.pilot.cellNumber.toString(),
      //         timeOfInstruct: value.data!.pilot.timeOfInstruct.toString(),
      //         companyName: value.data!.pilot.companyName.toString(),
      //         fkMemberShipId: value.data!.pilot.fkMemberShipId,
      //         currentLocation: value.data!.pilot.currentLocation,
      //         pkPilotId: value.data!.pilot.pkPilotId,
      //         memberShipType: value.data!.pilot.memberShipType,
      //         totalTime: value.data!.pilot.totalTime.toString(),
      //         pilotLname: value.data!.pilot.pilotLname.toString(),
      //         oldPssword: value.data!.pilot.oldPssword.toString(),
      //         pilotFname: value.data!.pilot.pilotFname.toString(),
      //         cuLocCountry: value.data!.pilot.cuLocCountry.toString(),
      //         availability: value.data!.pilot.availability,
      //       ),
      //     );

      //     UserHelper().setLoginWelcome(true);
      //     await UserHelper().getLoginWelcome();

      //     // Navigate to the dashboard (new app flow)
      //     if (Get.isDialogOpen ?? false) Get.back();
      //     Get.offAllNamed(AppRoutes.dashboard);
      //   } else {
      //     if (Get.isDialogOpen ?? false) Get.back();
      //     showMyDialog(Get.context!, value?.msg?.toString() ?? 'Unknown error');
      //   }
      // } catch (e) {
      //   if (Get.isDialogOpen ?? false) Get.back();
      //   showMyDialog(Get.context!, 'Something went wrong. Please try again.');
      // }
    // } else {
    //   // OTP mismatch
    //   otpController.clear();
    //   if (Get.isDialogOpen ?? false) Get.back();
    //   EasyLoading.showError('Enter valid OTP');
    // }
  }
}