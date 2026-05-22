import 'dart:async';

import 'package:crew_support/app/routes.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapAsyncNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor2,
      body: Center(
        child: Hero(
          tag: 'appLogo',
          child: SizedBox(
            width: 60.w,
            height: 40.h,
            child: SvgPicture.asset(
              'assets/logo.svg',
            ),
          ),
        ),
      ),
    );
  }

  void _bootstrapAsyncNavigation() {
    Future.microtask(() async {
      final hasLoggedIn = await hasUserLogged();

      if (!mounted) return;

      Future.delayed(const Duration(seconds: 0), () {
        if (!mounted) return;
        Get.offAllNamed(hasLoggedIn ? AppRoutes.dashboard : AppRoutes.login);
      });
    });
  }

  // ParseUser? currentUser;

  // Future<ParseUser?> getUser() async {
  //   currentUser = await ParseUser.currentUser() as ParseUser?;
  //   return currentUser;
  // }

  Future<bool> hasUserLogged() async {
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      return false;
    }
    //Checks whether the user's session token is valid
    final ParseResponse? parseResponse =
        await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);

    if (parseResponse?.success == null || !parseResponse!.success) {
      //Invalid session. Logout
      await currentUser.logout();
      return false;
    } else {
      debugPrint(
          "${currentUser.emailAddress} ${currentUser.get("phoneNumber")} is logged in");
      return true;
    }
  }

}
