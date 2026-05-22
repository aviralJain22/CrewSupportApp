import 'package:flutter/material.dart';

class AppColor {
  static  const Color primaryColor =   Color(0xFF488aff);
  static  const Color primaryColor1 =   Color(0xff80afff);
  static const Color secondaryColor = Color(0xFFE8F5FF);
  static  const Color blueIndigoColor = Color(0xFF1a365c);
  static const Color blueColor = Color(0xFF1A9FFF);
  static Color whiteColor = Colors.white;
  static Color whiteColor70 = Colors.white70;
  static Color greyColor70 = Colors.grey;
  static Color redColor = Colors.red;
  static Color redAccentColor = Colors.redAccent;
  static Color greenColor1 = Colors.green;
  static const Color greenColor = Color(0xFF4BAD06);
  static const Color blackColor = Color(0xFF121212);/*Color(0xFF282727);*/
  static const Color blackColor2 = Color(0xFF404040);/*Color(0xFF282727);*/
  static const Color blackColor3 = Color(0xFF595959);/*Color(0xFF282727);*/
  static const Color blackColor87 = Colors.black87;/*Color(0xFF282727);*/
  static const Color greyColor = Color(0xFF3A3939);
  static  Color? disablebutton = Colors.blue[300];
  static  Color? disablebuttonText = Colors.white70;
  static Color blackColor1 = Colors.black;
  // static Color goldenColor = Colors.amber.shade700;
  static Color goldenColor = Colors.yellow.shade800;
  static Color goldenColor1 = Colors.amber;
  static Color goldenColor2 = Colors.amber.shade300;
  static Color indigo = Colors.indigoAccent;
  static  const Color cobaltBlue =   Color(0xff0047ab);
  static  const Color backgroundColor =  Color(0xFF121212);
  static  const Color backgroundColor1 = Color(0xFF595959);
  static Color orangeColor = Colors.orange.shade300;
  static Color navyblueColor = Colors.lightBlue.shade600;



  // Colors for new theme
  static const Color bgColor1 = Color(0xFF121212);
  static const Color bgColor2 = Colors.black87;
  static const Color textColor1 = Colors.white;
  static Color textColor2 = Colors.black;
  static const Color textColor3 = Color(0xFF488aff);
  static  const Color textColor4 = Color(0xFF1a365c);
  static Color dividerColor = Colors.grey;
  static const Color btnColor1 = Color(0xffD4AF37);//D4AF37
  static const Color btnColor2 = Color(0xff80afff);
  static const Color disableIconColor = Color(0xFF3A3939);
  static Color loadingBarrierColor = Colors.white10;

  static const Color secondaryColor1 = Color(0xffD4AF37);//D4AF37 -- 0xffD4AF37
  static Color secondaryColor2 = Colors.grey;//D4AF37
  static const Color secondaryColor4 = Color(0xFF777777);//D4AF37
  static const Color secondaryColor3 = Color(0xfff2d479);//#F2D479
  static Color deleteColor = Colors.red;
  static Color transparent = Colors.transparent;
  static Color currentRead = Colors.orangeAccent;
  static Color futureRead = Colors.lightGreen;
  static Color historyRead = Colors.green;
  static Color pendingRead = Colors.orange;
  static Color uncrewedRead = Colors.deepOrange;
  static Color goldenColorNew = Colors.amber;
  static Color resumeColor = const Color(0xfff6c864);
  static Color highlightColor = Colors.grey.shade300;
  static Color chatSelectedColor = Colors.blue.shade100;
  static Color recieveChatColor = Colors.grey.shade700;
  static Color sendChatColor = secondaryColor1;
  static const Color gradient1 = Color(0xfff8e67d);
  static const Color gradient2 = Color(0xffa56c0b);

  static const MaterialAccentColor orangeAccent =
      MaterialAccentColor(_orangeAccentPrimaryValue, <int, Color>{
        100: Color(0xFFFFD180),
        200: Color(_orangeAccentPrimaryValue),
        400: Color(0xFFFF9100),
        700: Color(0xFFFF6D00),
      });
  static const int _orangeAccentPrimaryValue = 0xFFFFAB40;

  static const MaterialColor red = MaterialColor(_redPrimaryValue, <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(_redPrimaryValue),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  });
  static const int _redPrimaryValue = 0xFFF44336;
}
