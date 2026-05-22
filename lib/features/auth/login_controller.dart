import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/home/home_controller.dart';
import 'package:crew_support/utils/Utility.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/pref_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();
  // Matches legacy screen: a read-only field with picker + backing value
  // final membershipType = TextEditingController();
  // final memberTypeValue = 0.obs; // 1=Owner/Operator, 3=Pilot, 2=Instructor, 4=Flight Attendant
  
  final loading = false.obs;
  final obscureText = true.obs;

  void toggleObscureText(){
    obscureText.value = !obscureText.value;
  }

  /// Shows the legacy Cupertino membership picker and updates the text/value
  // void showMembershipPicker(BuildContext ctx) {
  //   int tempTypeIndex = 0; // 0 Owner/Operator, 1 Pilot, 2 Instructor, 3 Flight Attendant
  //   showCupertinoModalPopup(
  //     context: ctx,
  //     builder: (_) => SizedBox(
  //       height: 300,
  //       child: Column(
  //         children: [
  //           Container(
  //             color: AppColor.bgColor2, // requires AppColor in screen tree
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 TextButton(
  //                   onPressed: () => Get.back(),
  //                   child: const Text("Cancel",
  //                   style: TextStyle(color: AppColor.secondaryColor1),),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     switch (tempTypeIndex) {
  //                       case 1:
  //                         membershipType.text = "Pilot";
  //                         memberTypeValue.value = 3;
  //                         break;
  //                       case 0:
  //                         membershipType.text = "Owner/Operator";
  //                         memberTypeValue.value = 1;
  //                         break;
  //                       case 2:
  //                         membershipType.text = "Instructor";
  //                         memberTypeValue.value = 2;
  //                         break;
  //                       case 3:
  //                         membershipType.text = "Flight Attendant";
  //                         memberTypeValue.value = 4;
  //                         break;
  //                     }
  //                     Get.back();
  //                   },
  //                   child: const Text("Done",
  //                   style: TextStyle(color: AppColor.secondaryColor1),),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(
  //             height: 250,
  //             child: CupertinoPicker(
  //               backgroundColor: AppColor.bgColor1,
  //               itemExtent: 30,
  //               scrollController: FixedExtentScrollController(initialItem: 0),
  //               onSelectedItemChanged: (i) => tempTypeIndex = i,
  //               children: const [
  //                 Text("Owner/Operator"),
  //                 Text("Pilot"),
  //                 Text("Instructor"),
  //                 Text("Flight Attendant"),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> submit() async {
    if (email.text.trim().isEmpty) {
      EasyLoading.showError('Please enter email or phone number', maskType: EasyLoadingMaskType.custom);
      return;
    }
    if (password.text.trim().isEmpty) {
      EasyLoading.showError('Please enter password', maskType: EasyLoadingMaskType.custom);
      return;
    }
    // if (membershipType.text.trim().isEmpty) {
    //   EasyLoading.showError('Please select membership type', maskType: EasyLoadingMaskType.custom);
    //   return;
    // }

    loading.value = true;
    showLoadingDialog(Get.context!, 'Signing In...');

    // Mock Login Bypass (Allows login without a backend)
    // For now, any non-empty credentials will succeed as a mock login.
    if (email.text.trim().isNotEmpty && password.text.trim().isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      loading.value = false;
      Get.back();
      EasyLoading.showSuccess('Logged in (Mock Mode)');

      final prefs = await SharedPreferences.getInstance();
      // Default to Pilot role for mock; can be switched later in Dashboard
      await prefs.setInt(PrefKeys.selectedProfileType, MembershipType.pilot);
      await prefs.setBool("isLogIn", true);
      await prefs.setString("PilotFname", "John");
      await prefs.setString("PilotLname", "Doe");
      await prefs.setString("pkPilotId", "mock_user_1001");

      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }

    // If your API needs memberTypeValue, pass memberTypeValue.value as needed
    final user = ParseUser(email.text.trim(), password.text.trim(), null);
      
    var response = await user.login();

    loading.value = false;
    Get.back(); // closes the CupertinoAlertDialog shown by showLoadingDialog

    if (response.success) {
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

            // Ensure a fresh Dashboard session. If an old DashboardController/HomeController
      // survived a previous logout, it can show stale data.
      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>(force: true);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>(force: true);
      }

      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      EasyLoading.showError('Login failed: ${response.error!.message}');
    }
    
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    // membershipType.dispose();
    super.onClose();
  }
}