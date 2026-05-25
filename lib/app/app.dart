import 'package:crew_support/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'routes.dart';
import 'package:sizer/sizer.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer( 
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Crew Support',
          theme: AppThemeData.dark(),
          // 👇 this line makes all controllers from AppBindings available
          initialBinding: AppBindings(),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,

          builder: (context, child) {
            // Initialize EasyLoading first
            final easyLoadingBuilder = EasyLoading.init();
            final builtChild = easyLoadingBuilder(context, child);

            // Disable system text scaling (iOS Text Size / Accessibility)
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: builtChild,
            );
          },
        );
      },
    );
  }
}
