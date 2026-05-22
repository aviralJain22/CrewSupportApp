// FAQ Controller (GetX) — mirrors the legacy FAQ_Screen.dart content 1:1
// Notes:
// • All strings, order, spacing match the old file.
// • Uses spV2 for the one place that used 14.sp in the old code.
// • Keeps StoreChecker mapping so the tap on "Search Bar" can show install source (as before).

import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:store_checker/store_checker.dart';


/// Types of entries in the list (to exactly match the old static layout)
enum FaqEntryType { header, panel, divider, spacer }

/// Base entry
abstract class FaqEntry {
  final FaqEntryType type;
  const FaqEntry(this.type);
}

/// Section header like "Registration", "Login / Account Related", etc.
class FaqHeader extends FaqEntry {
  final String title;
  const FaqHeader(this.title) : super(FaqEntryType.header);
}

/// A divider line with the same styling as before
class FaqDivider extends FaqEntry {
  const FaqDivider() : super(FaqEntryType.divider);
}

/// A vertical spacer (e.g., SizedBox(height: 2) / (25) in the legacy file)
class FaqSpacer extends FaqEntry {
  final double height;
  const FaqSpacer(this.height) : super(FaqEntryType.spacer);
}

/// Expandable FAQ panel entry
class FaqPanelEntry extends FaqEntry {
  final String title;
  final Widget Function(BuildContext context) bodyBuilder;
  final ExpandableController controller;
  FaqPanelEntry({
    required this.title,
    required this.bodyBuilder,
    ExpandableController? controller,
  })  : controller = controller ?? ExpandableController(),
        super(FaqEntryType.panel);
}

class FaqController extends GetxController {
  /// Full ordered list of UI entries (headers, panels, dividers, spacers)
  late final List<FaqEntry> entries;

  @override
  void onInit() {
    super.onInit();
    entries = _buildEntries();
  }

  /// Legacy helper from old file (was getDownloadedPlace),
  /// now accessible from anywhere via controller.
  // Future<String> getDownloadedPlace() async {
  //   final installationSource = await StoreChecker.getSource;
  //   switch (installationSource) {
  //     case Source.IS_INSTALLED_FROM_PLAY_STORE:
  //       return "Play Store";
  //     case Source.IS_INSTALLED_FROM_LOCAL_SOURCE:
  //       return "Local Source";
  //     case Source.IS_INSTALLED_FROM_AMAZON_APP_STORE:
  //       return "Amazon Store";
  //     case Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY:
  //       return "Huawei App Gallery";
  //     case Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE:
  //       return "Samsung Galaxy Store";
  //     case Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE:
  //       return "Samsung Smart Switch Mobile";
  //     case Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS:
  //       return "Xiaomi Get Apps";
  //     case Source.IS_INSTALLED_FROM_OPPO_APP_MARKET:
  //       return "Oppo App Market";
  //     case Source.IS_INSTALLED_FROM_VIVO_APP_STORE:
  //       return "Vivo App Store";
  //     case Source.IS_INSTALLED_FROM_OTHER_SOURCE:
  //       return "Other Source";
  //     case Source.IS_INSTALLED_FROM_APP_STORE:
  //       return "App Store";
  //     case Source.IS_INSTALLED_FROM_TEST_FLIGHT:
  //       return "Test Flight";
  //     case Source.UNKNOWN:
  //       return "Unknown Source";
  //     default:
  //       return "default";
  //   }
  // }

  // ---------- Styles (kept here so both screen & entries use the same values)

  TextStyle get headerH1 => TextStyle(
        // old: fontSize: 17 (kept as-is; only sp usage converts to spV2)
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColor.secondaryColor1,
      );

  TextStyle get appBarTitle => TextStyle(
        // old: fontSize: 20, bold
        fontSize: 20,
        color: AppColor.secondaryColor1,
        fontWeight: FontWeight.bold,
      );

  TextStyle get h2 => TextStyle(
        // old: TextStyle(color: AppColor.secondaryColor1, fontWeight: bold) for panel headers
        fontWeight: FontWeight.bold,
        color: AppColor.secondaryColor1,
      );

  TextStyle get regular2 => TextStyle(
        color: AppColor.secondaryColor2,
      );

  TextStyle get regular1 => TextStyle(
        color: AppColor.secondaryColor1,
      );

  TextStyle get bold1 => TextStyle(
        color: AppColor.textColor1,
        fontWeight: FontWeight.bold,
      );

  // ---------- Data builder (exact order and content from the legacy file)

  List<FaqEntry> _buildEntries() {
    final list = <FaqEntry>[];

    // Top intro
    list.addAll([
      // "Frequently Asked Questions:"  (14.sp in legacy -> 14.spV2)
      IntroTitleEntry(styleBuilder: () => TextStyle(
            fontSize: 14.spV2,
            fontWeight: FontWeight.bold,
            color: AppColor.secondaryColor1,
          )),
      IntroSubtitleEntry(styleBuilder: () => regular2), // grey subtitle
      const FaqHeader("Registration"),
    ]);

    // Panels under "Registration"
    list.addAll([
      FaqPanelEntry(
        title: "How do I register?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'You can register by clicking on', style: regular2),
            TextSpan(text: ' "Join Now"', style: bold1),
            TextSpan(
                text: ' which will be visible on Sign In page.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title:
            "How do I register for another account when I am already logged in with one account?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'You can register by clicking on', style: regular2),
            TextSpan(text: ' "Add Account"', style: bold1),
            TextSpan(
                text:
                    ' which will be visible when you ( click on the icon ) which is located at the top right corner of the App',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "Do I need to register before creating a trip on Crew Support?",
        bodyBuilder: (_) => Text(
          "Yes, you do need to register before traveling with us.",
          style: regular2,
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title:
            "Can I register in multiple modules while using the same mobile number / email ID?",
        bodyBuilder: (_) => Text(
          "From each email ID and mobile number you can create a total of four accounts (Owner Operator, Pilot, Flight Attendant, and Instructor)",
          style: regular2,
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(25),
    ]);

    // Header: Login / Account Related
    list.add(const FaqHeader("Login / Account Related"));

    list.addAll([
      FaqPanelEntry(
        title: "What is a Profile?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: '"Profile"', style: bold1),
            TextSpan(
                text:
                    ' is the section where you can review and edit your personal information.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "I am unable to login. What should I do?",
        bodyBuilder: (_) => Text(
          "You may have entered incorrect login details. Please enter the correct information and try again or reset your password.",
          style: regular2,
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "How do I login if I forgot my password?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(
                text: 'If you forgot your password, you can click on',
                style: regular2),
            TextSpan(text: ' "Forgot Password"', style: bold1),
            TextSpan(text: ' on the', style: regular2),
            TextSpan(text: ' "Sign In"', style: bold1),
            TextSpan(
                text:
                    ' Page. It will ask you a few questions and another OTP will be sent to your registered mobile number.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(25),
    ]);

    // Header: Manage Availability
    list.add(const FaqHeader("Manage Availability"));

    list.addAll([
      FaqPanelEntry(
        title: "How can I create an availability?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'Click on', style: regular2),
            TextSpan(text: ' " Add new availability"', style: bold1),
            TextSpan(
                text:
                    ' to create a new availability. \n \nBy clicking on',
                style: regular2),
            TextSpan(text: ' " Manage Availability"', style: bold1),
            TextSpan(
                text:
                    ' you can edit or delete your availability in the current or future tab.',
                style: regular2),
          ]),
        ),
      ),
      // (One Q under Manage Availability was commented out in legacy; we keep it that way.)
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "How do I edit / delete my Availability?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(
                text:
                    'If you entered your availability, then only you are eligible to edit or delete availability. \n \n',
                style: regular2),
            TextSpan(text: '• For editing,', style: bold1),
            TextSpan(
                text:
                    ' click on the pencil button which is shown beside the details.\n \n',
                style: regular2),
            TextSpan(text: '• For deleting,', style: bold1),
            TextSpan(
                text:
                    ' Click on the bin button which is shown beside the details.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(25),
    ]);

    // Header: Trip
    list.add(const FaqHeader("Trip"));

    list.addAll([
      FaqPanelEntry(
        title: "Who can create a trip?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'If you are an ', style: regular2),
            TextSpan(text: ' Owner Operator', style: bold1),
            TextSpan(
                text:
                    ' then you can create a trip. If you are a ',
                style: regular2),
            TextSpan(
                text: ' Pilot, Flight Attendant, or Instructor',
                style: bold1),
            TextSpan(text: ' then you will receive a trip.', style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "Who has the right to cancel a trip?",
        bodyBuilder: (_) => Text(
          "All users have a right to send a request for cancellation. If the person on the other side accepts your request, your trip would be canceled.",
          style: regular2,
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(25),
    ]);

    // Header: Functionalities
    list.add(const FaqHeader("Functionalities"));

    list.addAll([
      FaqPanelEntry(
        title: "How can I send a friend request?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'You can search for a person in the', style: regular2),
            TextSpan(text: ' Search Bar', style: bold1),
            TextSpan(
                text:
                    ' and you will see a list of users. Click on the person you want and at the bottom of the page click the',
                style: regular2),
            TextSpan(text: ' "Send Friend Request"', style: bold1),
            TextSpan(text: ' button.', style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "How can I communicate with others?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'If you are an ', style: regular2),
            TextSpan(text: ' Owner operator', style: bold1),
            TextSpan(
                text:
                    ' then you can message anyone by finding that person in the list of users, which will be displayed as the result of a',
                style: regular2),
            TextSpan(text: ' Search', style: bold1),
            TextSpan(
                text:
                    '\n\nOtherwise, you must first send a friend request to another user to communicate with them.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "What is the use of the heart icon?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(
                text:
                    'By clicking that icon, there will be a list of your favorite crew members or favorite operators. That list will be available during the process of creating a trip.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),

      FaqPanelEntry(
        title: "How can I look for a particular crew member?",
        bodyBuilder: (context) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(text: 'You can search by name in the', style: regular2),
            TextSpan(
              text: ' Search Bar',
              style: bold1,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  // // Preserve legacy behavior: show install source in a SnackBar
                  // final source = await getDownloadedPlace();
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text(source)),
                  // );
                },
            ),
            TextSpan(
                text: ' and send them a friend request or a message.',
                style: regular2),
            TextSpan(
                text:
                    '\n\nOnce a friend request is accepted, that person can be added to your ‘favorites’ list.',
                style: regular2),
            TextSpan(text: '\n\nOn the ', style: regular2),
            TextSpan(text: 'Owner/Operator', style: bold1),
            TextSpan(text: ' account there is an option to select', style: regular2),
            TextSpan(text: ' Pilots/Attendants', style: bold1),
            TextSpan(text: ' from the', style: regular2),
            TextSpan(text: ' ‘Favorites’', style: bold1),
            TextSpan(
                text: '  list during the process of creating a trip.',
                style: regular2),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(25),
    ]);

    // Header: Payment
    list.add(const FaqHeader("Payment"));

    list.addAll([
      FaqPanelEntry(
        title: "How can I pay?",
        bodyBuilder: (_) => RichText(
          text: TextSpan(style: regular1, children: [
            TextSpan(
                text:
                    'Currently there is only one mode of payment is available :-',
                style: regular2),
            TextSpan(text: '\n\n   • Escrow', style: bold1),
          ]),
        ),
      ),
      const FaqDivider(),
      const FaqSpacer(2),
    ]);

    return list;
  }
}

/// Two small intro blocks from the very top of the legacy screen.
/// (Kept separate so we can render them before the first section header.)
class IntroTitleEntry extends FaqEntry {
  final TextStyle Function() styleBuilder;
  IntroTitleEntry({required this.styleBuilder}) : super(FaqEntryType.header);

  Widget build() => Text(
        "Frequently Asked Questions:",
        style: styleBuilder(),
      );
}

class IntroSubtitleEntry extends FaqEntry {
  final TextStyle Function() styleBuilder;
  IntroSubtitleEntry({required this.styleBuilder}) : super(FaqEntryType.header);

  Widget build() => Text(
        "Check out this section to get answers for all the frequently asked questions.",
        style: styleBuilder(),
      );
}