import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class RegisterController extends GetxController {
  // ── Text controllers ──────────────────────────────────────────────────────────
  final membershipTypeController = TextEditingController();
  final genderController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Global form key (used by Form widget in the screen)
  final formKey = GlobalKey<FormState>();

  // ── Reactive UI state ────────────────────────────────────────────────────────
  final obscurePass = true.obs;
  final obscureConfirmPass = true.obs;
  final acceptedTerms = false.obs;
  final loading = false.obs;

  // Country picker state
  final selectedCountryCode = ''.obs;   // e.g., "US"
  final selectedDialCode = '+1'.obs;    // e.g., "+1"
  final selectedCountryName = ''.obs;   // e.g., "United States"
  String get dialCodeDigits => selectedDialCode.value.replaceAll('+', '');

  // Selected gender as an integer: 0=Male, 1=Female, 2=Other (for DB storage)
  final genderValue = 0.obs; // default to 0 (Male) or leave as you prefer

  // App version (old code sent this in API)
  // final appVersion = ''.obs;

  // Membership mapping (old code used an int memberTypeValue)
  // Adjust IDs to match backend if needed.
  // final _membershipOptions = const <String, int>{
  //   'Free': 0,
  //   'Standard': 1,
  //   'Premium': 2,
  // };
  final memberTypeValue = 0.obs;

  // Gender options (used by CupertinoPicker)
  final genderOptions = const ['Male', 'Female', 'Other'];

  // Dependency
  // final _repo = AuthRepo();

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Initialize membership & gender defaults if you had defaults in old code
    genderController.text = '';
    membershipTypeController.text = '';
    // _loadAppVersion();
  }

  // Future<void> _loadAppVersion() async {
  //   try {
  //     final pkg = await PackageInfo.fromPlatform();
  //     appVersion.value = pkg.version;
  //   } catch (_) {
  //     appVersion.value = '';
  //   }
  // }

  // ── Actions (bound from UI) ─────────────────────────────────────────────────────────────────
  void togglePassVisibility() => obscurePass.toggle();
  void toggleConfirmPassVisibility() => obscureConfirmPass.toggle();
  void setAcceptedTerms(bool v) => acceptedTerms.value = v;

  /// Membership picker: updates displayed text AND memberTypeValue (int).
  /// Membership picker using CupertinoPicker (old signup_screen.dart style)
void showMembershipPickerCupertino(BuildContext ctx) {
  int type = 0; // temporary index selection

  showCupertinoModalPopup(
    context: ctx,
    builder: (_) => SizedBox(
      height: 300,
      child: Column(
        children: [
          // Header row with Cancel/Done
          Container(
            color: AppColor.bgColor2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1)),
                ),
                TextButton(
                  onPressed: () {
                    if (type == 0) {
                      membershipTypeController.text = "Owner/Operator";
                      memberTypeValue.value = 1;
                    } else if (type == 1) {
                      membershipTypeController.text = "Pilot";
                      memberTypeValue.value = 3;
                    } else if (type == 2) {
                      membershipTypeController.text = "Flight Attendant";
                      memberTypeValue.value = 4;
                    // } else if (type == 3) {
                    //   membershipTypeController.text = "Instructor";
                    //   memberTypeValue.value = 2;
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text("Done", style: TextStyle(color: AppColor.secondaryColor1)),
                ),
              ],
            ),
          ),
          // CupertinoPicker
          SizedBox(
            height: 250,
            child: CupertinoPicker(
              backgroundColor: AppColor.bgColor1,
              itemExtent: 30,
              scrollController: FixedExtentScrollController(initialItem: 0),
              onSelectedItemChanged: (value) {
                type = value; // track index locally
              },
              children: [
                Text("Owner/Operator", style: TextStyle(color: AppColor.textColor1)),
                Text("Pilot", style: TextStyle(color: AppColor.textColor1)),
                Text("Flight Attendant", style: TextStyle(color: AppColor.textColor1)),
                // Text("Instructor", style: TextStyle(color: AppColor.textColor1)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Gender picker using CupertinoPicker inside showCupertinoModalPopup
/// Stores integer in genderValue (0=Male, 1=Female, 2=Other) and updates label text field.
void showGenderPickerCupertino(BuildContext ctx) {
  // Start the wheel at the currently selected gender
  int type = genderValue.value; // 0: Male, 1: Female, 2: Other

  showCupertinoModalPopup(
    context: ctx,
    builder: (_) => SizedBox(
      height: 300,
      child: Column(
        children: [
          // Header row: Cancel / Done
          Container(
            color: AppColor.bgColor2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppColor.secondaryColor1)),
                ),
                TextButton(
                  onPressed: () {
                    // Persist integer value to be saved in DB
                    genderValue.value = type; // 0 | 1 | 2

                    // Keep showing a friendly label in the text field
                    if (type == 0) {
                      genderController.text = "Male";
                    } else if (type == 1) {
                      genderController.text = "Female";
                    } else {
                      genderController.text = "Other";
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text("Done", style: TextStyle(color: AppColor.secondaryColor1)),
                ),
              ],
            ),
          ),
          // Wheel picker
          SizedBox(
            height: 250,
            child: CupertinoPicker(
              backgroundColor: AppColor.bgColor1,
              itemExtent: 30,
              scrollController: FixedExtentScrollController(initialItem: type),
              useMagnifier: true,
              onSelectedItemChanged: (value) {
                // Keep the local selection; commit on Done
                type = value;
              },
              children: const [
                Text('Male'),
                Text('Female'),
                Text('Other'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  /// CountryListPick callback (keep dynamic to avoid tight plugin coupling)
  void onCountryChanged(dynamic code) {
    try {
      selectedCountryCode.value = code?.code?.toString() ?? '';
      selectedDialCode.value = code?.dialCode?.toString() ?? '+1';
      selectedCountryName.value = code?.name?.toString() ?? '';
    } catch (_) {/* ignore */}
  }

  // ── Validators (used by Form fields) ─────────────────────────────────────────
  String? validateNonEmpty(String? value, String fieldLabel) {
    if ((value ?? '').trim().isEmpty) return 'Please enter $fieldLabel';
    return null;
  }

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter your email address';
    // Simple/robust email check; old code accidentally used a password regex.
    final emailReg = RegExp(r'^.+@.+\..+$');
    if (!emailReg.hasMatch(v)) return 'Please enter a valid email address';
    return null;
  }

  String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.trim().isEmpty) return 'Please enter password';
    if (v.length < 5) return 'Minimum 5 characters required';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Please enter confirm password';
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Submit: mirrors old insertPilot() semantics via AuthRepo ────────────────
  Future<void> submit() async {
    debugPrint("membershipType: ${membershipTypeController.value}");
  debugPrint("memberTypeValue: ${memberTypeValue.value}");
  debugPrint("genderValue(int): ${genderValue.value} | genderLabel: ${genderController.text}");

    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!acceptedTerms.value) {
      Get.snackbar('Required', 'Please accept our Terms and Privacy Policy',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    loading.value = true;
    try {
      // NOTE: If your AuthRepo.register signature differs, adjust here.
      // await _repo.register(
      //   email: emailController.text.trim(),
      //   password: passwordController.text,
      //   fullName:
      //       '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim(),
      //   phone: phoneNumberController.text.trim(),
      //   dialCode: dialCodeDigits,
      //   memberTypeValue: memberTypeValue.value,
      //   appVersion: appVersion.value,
      //   gender: genderController.text.trim(),
      // );

      // If your API returns an OTP payload like the old screen,
      // navigate to OTP screen here. Example:
      //
      // if (result.flag == 1) {
      //   Get.to(() => GenerateOtp(
      //     pilotFName: firstNameController.text.trim(),
      //     pilotLName: lastNameController.text.trim(),
      //     country: selectedCountryName.value,
      //     emailId: emailController.text.trim(),
      //     mobileNumber: phoneNumberController.text.trim(),
      //     memberShipId: memberTypeValue.value.toString(),
      //     countryCode: dialCodeDigits,
      //     password: passwordController.text.trim(),
      //     otp: result.data[0].otpnumber, // or whatever your model returns
      //   ));
      // } else {
      //   Get.snackbar('Failed', result.message);
      // }
      //
      // For now, keep the simple success flow:

      // Create a ParseCloudFunction object
  final cloudFunction = ParseCloudFunction('sendOTP');
  final params = <String, dynamic>{'phoneNumber': selectedDialCode.value + phoneNumberController.text.trim()};

  final ParseResponse response = await cloudFunction.execute(parameters: params);

  if (response.success && response.result != null) {
    // If successful, switch the UI to show the OTP field
    Get.toNamed('/otp', arguments: {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'membershipType': memberTypeValue.value,
        'gender': genderValue.value,
        'countryCode': selectedCountryCode.value,
        'dialCode': selectedDialCode.value,
        'countryName': selectedCountryName.value,
        'phoneNumber': phoneNumberController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
      });
  } else {
    EasyLoading.showError((response.error?.message ?? "An unknown error occurred."),
            maskType: EasyLoadingMaskType.custom);
        debugPrint(response.error!.message);
  }

      

      // final user = ParseUser.createUser(emailController.text.trim(), passwordController.text, emailController.text.trim());

      // user.set<int>('membershipType', memberTypeValue.value);
      // user.set<int>('gender', 0);
      // user.set<String>('countryCode', selectedCountryCode.value);
      // user.set<String>('dialCode', selectedDialCode.value);
      // user.set<String>('countryName', selectedCountryName.value);
      // user.set<String>('phoneNumber', phoneNumberController.text.trim());

      // if (firstNameController.text.trim().isNotEmpty) {
      //   user.set<String>('firstName', firstNameController.text.trim());
      // }

      // if (lastNameController.text.trim().isNotEmpty) {
      //   user.set<String>('lastName', lastNameController.text.trim());
      // }

      // var response = await user.signUp();

      // if (response.success) {
      //   EasyLoading.showSuccess("Success!", maskType: EasyLoadingMaskType.custom);
      // } else {
      //   EasyLoading.showError((response.error!.message),
      //       maskType: EasyLoadingMaskType.custom);
      //   debugPrint(response.error!.message);
      // }

      // Get.snackbar('Success', 'Registered. Please verify your email if required.');
      // Get.back(); // go back to login



    } catch (e) {
      EasyLoading.showError((e.toString()),
            maskType: EasyLoadingMaskType.custom);
    } finally {
      loading.value = false;
    }
  }

  // ── Dispose text controllers ────────────────────────────────────────────────
  @override
  void onClose() {
    membershipTypeController.dispose();
    genderController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

// class RegisterController extends GetxController {
//   // final name = TextEditingController();
//   // final email = TextEditingController();
//   // final password = TextEditingController();
//   // final confirm = TextEditingController();
//   // final loading = false.obs;
//   // final _repo = AuthRepo();

//   // Future<void> submit() async {
//   //   if (email.text.isEmpty || password.text.isEmpty) {
//   //     Get.snackbar('Required', 'Email and password are required');
//   //     return;
//   //   }
//   //   if (password.text != confirm.text) {
//   //     Get.snackbar('Mismatch', 'Passwords do not match');
//   //     return;
//   //   }
//   //   loading.value = true;
//   //   try {
//   //     await _repo.register(
//   //       email: email.text,
//   //       password: password.text,
//   //       fullName: name.text,
//   //     );
//   //     Get.snackbar('Success', 'Registered. Please verify your email if required.');
//   //     Get.back(); // go back to login
//   //   } catch (e) {
//   //     Get.snackbar('Registration failed', e.toString(),
//   //         snackPosition: SnackPosition.BOTTOM);
//   //   } finally {
//   //     loading.value = false;
//   //   }
//   // }
// }