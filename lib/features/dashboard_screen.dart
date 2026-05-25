import 'package:crew_support/app/routes.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/message/chat_service.dart';
import 'package:crew_support/features/message/message_controller.dart';
import 'package:crew_support/features/message/message_screen.dart';
import 'package:crew_support/features/notification/notification_controller.dart';
import 'package:crew_support/features/notification/notification_screen.dart';
import 'package:crew_support/features/profile/profile_flight_attendant_screen.dart';
import 'package:crew_support/features/profile/profile_owner_screen.dart';
import 'package:crew_support/features/profile/profile_pilot_screen.dart';
import 'package:crew_support/features/profile/profile_owner_controller.dart';
import 'package:crew_support/features/profile/profile_pilot_controller.dart';
import 'package:crew_support/features/profile/profile_flight_attendant_controller.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crew_support/features/home/home_controller.dart';
import 'package:crew_support/features/dashboard/premium_dashboard_screen.dart';
import 'package:crew_support/features/crew_search/crew_search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final DashboardController controller;

  // Each instance of DashboardScreen gets its own unique keys
  final GlobalKey _profileTabKey = GlobalKey();
  final GlobalKey _manageAvailabilityKey = GlobalKey();

  late final AnimationController _warningAnimationController;
  late final Animation<double> _warningScaleAnimation;
  late final Animation<double> _warningGlowAnimation;
  late final Animation<double> _warningYOffsetAnimation;

  @override
  void initState() {
    super.initState();

    controller = Get.find<DashboardController>();

    _warningAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _warningScaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.10,
    ).animate(
      CurvedAnimation(
        parent: _warningAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _warningGlowAnimation = Tween<double>(
      begin: 0.20,
      end: 0.55,
    ).animate(
      CurvedAnimation(
        parent: _warningAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _warningYOffsetAnimation = Tween<double>(
      begin: 0,
      end: -1.8,
    ).animate(
      CurvedAnimation(
        parent: _warningAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _warningAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make sure controller sees the same keys the widgets use
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.key1 ??= _profileTabKey;
      controller.key2 ??= _manageAvailabilityKey;
    });
    // Match legacy status bar style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.bgColor1,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Ensure HomeController is available. If you prefer Bindings, move this there.
    Get.put(HomeController(), permanent: true);

    return Scaffold(
      backgroundColor: AppColor.bgColor1,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // ======= TOP HEADER =======
              Container(
                width: 100.w,
                padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.5.h, bottom: 1.h),
                color: AppColor.bgColor1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row: Avatar - Search - Favorite - Account
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar (reactive)
                        Obx(() {
                          final url = controller.photoUrl.value;
                          final disabled = controller.isCurrentProfileDisabled.value;
                          return GestureDetector(
                            onTap: controller.onAvatarTap,
                            child: Opacity(
                              opacity: disabled ? 0.4 : 1.0,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColor.bgColor1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: SizedBox(
                                    height: 60.sp,
                                    width: 60.sp,
                                    child: url.isEmpty
                                        ? CircleAvatar(
                                            backgroundColor: AppColor.secondaryColor2,
                                            child: Icon(Icons.account_circle, color: AppColor.bgColor1, size: 60),
                                          )
                                        : Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, err, st) => CircleAvatar(
                                              backgroundColor: AppColor.bgColor1,
                                              child: Icon(Icons.account_circle, color: AppColor.secondaryColor1, size: 60),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Search box
                        Container(
                          width: 45.w,
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor1.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: TextField(
                              controller: controller.searchController,
                              cursorColor: AppColor.secondaryColor1,
                              onChanged: (txt) => controller.onSearchChanged(
                                txt,
                                onPerformSearch: controller.performSearch,
                              ),
                              // Keep focus so the keyboard reliably opens on first tap
                              onTap: () => controller.selectTab(5, unfocus: false),
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor1),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search, color: AppColor.secondaryColor1),
                                hintText: 'Search',
                                hintStyle: TextStyle(color: AppColor.secondaryColor1, fontSize: 9.spV2),
                                contentPadding: const EdgeInsets.only(right: 10, top: 15),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),

                        // The heart icon normally lives here.
                        // When location setup is incomplete for the selected
                        // profile, we temporarily replace it with an animated
                        // warning icon so the user has a clear recovery path.
                        Obx(() {
                          final bool showWarning = controller.showLocationWarningButton.value;

                          if (showWarning) {
                            return GestureDetector(
                              onTap: controller.onTopBarLocationWarningTap,
                              child: SizedBox(
                                height: 24.sp,
                                width: 24.sp,
                                child: AnimatedBuilder(
                                  animation: _warningAnimationController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _warningYOffsetAnimation.value),
                                      child: Transform.scale(
                                        scale: _warningScaleAnimation.value,
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.red.withValues(alpha: _warningGlowAnimation.value),
                                                blurRadius: 10,
                                                spreadRadius: 1.5,
                                              ),
                                            ],
                                          ),
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  // Color is softened only for the
                                  // while-in-use-only case; all other warning
                                  // states use a stronger red treatment.
                                  child: Icon(
                                    Icons.report_problem,
                                    color: _getWarningIconColor(),
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            );
                          }

                          // Favorite icon
                          return GestureDetector(
                            onTap: () {
                              // Get.toNamed(AppRoutes.pilotViewProfile, arguments: {
                              //   // 'profileId': '8rvulS2cQw',
                              //   'userId': 'AM51rjst0j',
                              // });
                              //This is flight Attendant:
                              // Get.toNamed(AppRoutes.fAViewProfile, arguments: {
                              //   'profileId': 'jomesauHx2',
                              // });
                              Get.toNamed(AppRoutes.favorite);
                              //open tutorial (temp):
                              // controller.showtutorial();

                              // final ChatService chatService = ChatService();

                              // chatService.openChatForProfile(
                              //   otherUserId: "Arjst0j", //AM51rjst0j
                              //   otherProfileType: MembershipType.pilot,
                              //   receiverName: 'Test Chat',
                              // );
                              // Get.toNamed(AppRoutes.pilotViewProfile, arguments: {
                              //   'profileId': '46FhTg2NWF',
                              // });
                            },
                            child: SizedBox(
                              height: 17.sp,
                              width: 17.sp,
                              child: SvgPicture.asset(
                                'assets/Heart Outline.svg',
                                fit: BoxFit.fill,
                                colorFilter: ColorFilter.mode(AppColor.secondaryColor1, BlendMode.srcIn),
                              ),
                            ),
                          );
                        }),

                        // Account / switch profile
                        GestureDetector(
                          onTap: () => controller.showLoginDialog(),
                          child: Icon(Icons.account_circle, color: AppColor.secondaryColor1, size: 20.sp),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Right aligned links: Manage Availability (hidden for "1") + Help Center
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 10.h,
                          child: Obx(() {
                            //TODO: uncomment this line:
                            final showManageAvailability = controller.selectedProfileType.value != MembershipType.ownerOperator;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: showManageAvailability,
                                  child: GestureDetector(
                                    onTap: controller.onManageAvailabilityTap,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 2.w, bottom: 1.5.h),
                                      child: Text(
                                        'Manage Availability',
                                        key: _manageAvailabilityKey,
                                        style: TextStyle(
                                          fontSize: 10.spV2,
                                          color: AppColor.secondaryColor1,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColor.secondaryColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: controller.onHelpCenterTap,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 2.w, bottom: 1.5.h),
                                    child: Text(
                                      'Help Center',
                                      style: TextStyle(
                                        fontSize: 10.spV2,
                                        color: AppColor.secondaryColor1,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColor.secondaryColor1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ======= PAGE CONTENT =======
              Expanded(
                child: Obx(() {

                  final idx = controller.currentPage.value;

                  // Home tab — trip management dashboard
                  if (idx == 0) {
                    return const PremiumDashboardScreen();
                  }
                  // Profile tab
                  else if (idx == 1) {

                    // 👇 force this Obx to depend on selectedProfileType as well
                    final role = controller.selectedProfileType.value;

                    switch (role) {
                      case MembershipType.ownerOperator:
                        if (!Get.isRegistered<ProfileOwnerController>()) {
                          Get.put(ProfileOwnerController());
                        }
                        debugPrint("User is Owner Operator");
                        return const ProfileOwnerScreen();

                      case MembershipType.instructor:
                        debugPrint("User is Instructor");
                        break;

                      case MembershipType.pilot:
                        if (!Get.isRegistered<ProfilePilotController>()) {
                          Get.put(ProfilePilotController());
                        }
                        debugPrint("User is Pilot");
                        return const ProfilePilotScreen();

                      case MembershipType.flightAttendant:
                        if (!Get.isRegistered<ProfileFlightAttendantController>()) {
                          Get.put(ProfileFlightAttendantController());
                        }
                        debugPrint("User is Flight Attendant");
                        return const ProfileFlightAttendantScreen();

                      default:
                        debugPrint("Unknown or no role selected");
                    }
                    // return const ProfileOwnerScreen();
                    // return const ProfilePilotScreen();
                    // return const ProfileFlightAttendantScreen();
                  }
                  // Network tab — crew search
                  else if (idx == 2) {
                    return const CrewSearchScreen();
                  }
                  // Notification tab
                  else if (idx == 3) {
                    if (!Get.isRegistered<NotificationController>()) {
                      Get.put(NotificationController());
                    }
                    return const NotificationScreen();
                  }
                  // Message tab
                  else if (idx == 4) {
                    if (!Get.isRegistered<MessageController>()) {
                      Get.put(MessageController());
                    }
                    return const MessageScreen();
                  }
                  // Search tab (idx == 5 in the old app)
                  else if (idx == 5) {
                    final isSearching = controller.isSearching.value;
                    final hasValidationError = controller.searchValidationError.value;
                    final results = controller.searchResults;
                    final query = controller.searchController.text.trim();

                    return _buildSearchTabBody(
                      isSearching: isSearching,
                      hasValidationError: hasValidationError,
                      results: results,
                      query: query,
                    );
                  }

                  // Placeholder body for other tabs (Connection / Notification / Messages)
                  final labels = ['Home', 'Profile', 'Connection', 'Notification', 'Messages'];
                  final safeIndex = idx.clamp(0, labels.length - 1);

                  return Container(
                    width: 100.w,
                    color: AppColor.bgColor1,
                    alignment: Alignment.center,
                    child: Text(
                      labels[safeIndex],
                      style: TextStyle(fontSize: 12.spV2, color: AppColor.secondaryColor2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chooses the warning icon color based on severity.
  ///
  /// We intentionally show a softer color when the only issue is that the app
  /// has `whileInUse` permission instead of `always`. More disruptive states
  /// such as device Location Services being off still use the stronger warning
  /// color.
  Color _getWarningIconColor() {
    final reason = controller.locationWarningReason.value;
    final isWhileInUse = controller.isWhileInUseOnly.value;

    // Only case: WhileUsingApp + everything else OK
    if (reason == 'permission_not_always' && isWhileInUse) {
      return AppColor.secondaryColor1; // softer warning
    }

    // All other cases = stronger warning
    return AppColor.red;
  }

  // ── Bottom nav helpers ──────────────────────────────────────────────────

  static const Color _navSelected = Color(0xFF1A2B4A);
  static const Color _navUnselected = Color(0xFF9EA8C0);

  /// Maps a controller page index to the active bottom-nav tab index.
  int _bottomNavIndex(int page) {
    switch (page) {
      case 0: return 0; // Home
      case 2: return 1; // Connection
      case 1: return 2; // Profile
      case 3: return 3; // Notifications
      case 4: return 4; // Messages
      default: return 0;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      final activeTab = _bottomNavIndex(controller.currentPage.value);
      final photoUrl = controller.photoUrl.value;

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
        ),
        padding: EdgeInsets.only(top: 10, bottom: bottomPadding + 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(label: 'Home', index: 0, activeTab: activeTab,
              icon: _logoIcon(activeTab == 0),
              onTap: () => controller.selectTab(0)),
            _navItem(label: 'Network', index: 1, activeTab: activeTab,
              icon: Icon(activeTab == 1 ? Icons.people_alt : Icons.people_alt_outlined,
                  size: 22, color: activeTab == 1 ? _navSelected : _navUnselected),
              onTap: () => controller.selectTab(2)),
            _navItem(label: 'Profile', index: 2, activeTab: activeTab,
              icon: _avatarIcon(photoUrl, activeTab == 2),
              onTap: () => controller.selectTab(1)),
            _navItem(label: 'Alerts', index: 3, activeTab: activeTab,
              icon: Icon(activeTab == 3 ? Icons.notifications_rounded : Icons.notifications_outlined,
                  size: 22, color: activeTab == 3 ? _navSelected : _navUnselected),
              onTap: () => controller.selectTab(3)),
            _navItem(label: 'Messages', index: 4, activeTab: activeTab,
              icon: Icon(activeTab == 4 ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                  size: 21, color: activeTab == 4 ? _navSelected : _navUnselected),
              onTap: () => controller.selectTab(4)),
          ],
        ),
      );
    });
  }

  Widget _navItem({
    required String label,
    required int index,
    required int activeTab,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    final bool selected = index == activeTab;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(
                color: selected ? _navSelected : _navUnselected,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoIcon(bool selected) {
    return Image.asset(
      'assets/logoNewGolden.png',
      width: 22,
      height: 22,
      color: selected ? null : _navUnselected,
      colorBlendMode: selected ? null : BlendMode.srcIn,
    );
  }

  Widget _avatarIcon(String photoUrl, bool selected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _navSelected : _navUnselected,
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: photoUrl.isEmpty
            ? Icon(Icons.person, size: 16, color: selected ? _navSelected : _navUnselected)
            : Image.network(photoUrl, fit: BoxFit.cover,
                errorBuilder: (_, err, e) =>
                    Icon(Icons.person, size: 16, color: selected ? _navSelected : _navUnselected)),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────

  /// Builds the Search tab body to closely mirror the legacy dashboard search UI.
  Widget _buildSearchTabBody({
    required bool isSearching,
    required bool hasValidationError,
    required List<Map<String, dynamic>> results,
    required String query,
  }) {
    // Background container matches the rest of the dashboard
    Widget wrap(Widget child) {
      return Container(
        width: 100.w,
        color: AppColor.bgColor1,
        alignment: Alignment.center,
        child: child,
      );
    }

    // No text yet – show a gentle hint
    if (query.isEmpty) {
      return wrap(
        Text(
          'Type at least ${controller.minSearchChars} characters to search',
          style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor2),
        ),
      );
    }

    // Less than minSearchChars characters – match legacy `_searchValidation` behaviour
    if (hasValidationError) {
      return wrap(
        Text(
          'Please enter at least ${controller.minSearchChars} characters',
          style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor2),
        ),
      );
    }

    // While waiting for API
    if (isSearching) {
      return wrap(

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingAnimationWidget.threeRotatingDots(
              color: AppColor.secondaryColor1,
              size: 50.spV2,
            ),
            SizedBox(height: 2.h),
            Text('Loading...', style: TextStyle(color: AppColor.textColor1)),
          ],
        ),

        // const CircularProgressIndicator(),
      );
    }

    // No results from API
    if (results.isEmpty) {
      return wrap(
        Text(
          'No result found',
          style: TextStyle(fontSize: 10.spV2, color: AppColor.secondaryColor2),
        ),
      );
    }

    // We have results – show them in a list, similar spacing to legacy
    return Container(
      width: 100.w,
      color: AppColor.bgColor1,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        itemCount: results.length,
        separatorBuilder: (_, idx) => SizedBox(height: 0.h),
        itemBuilder: (context, index) {
          final row = results[index];

          final firstName = (row['firstName'] ?? '') as String;
          final middleName = (row['middleName'] ?? '') as String;
          final lastName = (row['lastName'] ?? '') as String;
          final companyName = (row['companyName'] ?? '') as String;
          final membershipType = row['membershipType'];
          final availTime = (row['AvailTime'] ?? row['availTime'] ?? row['currentLocation'] ?? '') as String;
          final photoPath = (row['photoPath'] ?? '') as String;

          final userId = row['userId']?.toString();
          final membershipTypeInt = (row['membershipType'] as num?)?.toInt() ?? 0;

          // Logged-in user's membership id (matches legacy fkMemberShipId)
          final loggedInMembershipId = controller.selectedProfileType.value;

          // Map membershipType int → label (same mapping we use elsewhere)
          String membershipLabel;
          final mtString = membershipType?.toString() ?? '';
          switch (mtString) {
            case '1':
              membershipLabel = 'Owner/Operator';
              break;
            case '2':
              membershipLabel = 'Instructor';
              break;
            case '3':
              membershipLabel = 'Pilot';
              break;
            case '4':
              membershipLabel = 'Flight Attendant';
              break;
            default:
              membershipLabel = '';
          }

          // Title text: if owner operator, show companyName; else first + middle and last as separate Texts
          final bool isOwnerOperatorRow = mtString == '1';
          final String firstLineName = isOwnerOperatorRow
              ? companyName
              : [
                  firstName,
                  if (middleName.isNotEmpty) middleName,
                ].where((e) => e.trim().isNotEmpty).join(' ');

          return Column(
            children: [
              ListTile(
                onTap: () => controller.onSearchResultTap(row),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColor.secondaryColor1,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColor.secondaryColor1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: 60.0.sp,
                        width: 60.0.sp,
                        child: photoPath.isEmpty
                            ? CircleAvatar(
                                backgroundColor: AppColor.secondaryColor1,
                                child: Icon(Icons.person, color: AppColor.bgColor1),
                              )
                            : Image.network(
                                photoPath,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.bgColor1,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return CircleAvatar(
                                    backgroundColor: AppColor.secondaryColor1,
                                    child: Icon(Icons.person, color: AppColor.bgColor1),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      firstLineName,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: AppColor.textColor1, fontSize: 11.spV2),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isOwnerOperatorRow && lastName.isNotEmpty) ...[
                      SizedBox(width: 1.w),
                      Text(
                        lastName,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: AppColor.textColor1, fontSize: 11.spV2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membershipLabel,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: AppColor.secondaryColor2, fontSize: 10.spV2),
                    ),
                    SizedBox(height: 1.h),
                    Visibility(
                      visible: loggedInMembershipId == MembershipType.ownerOperator,
                      child: Text(
                        availTime,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: AppColor.secondaryColor2, fontSize: 9.spV2),
                      ),
                    ),
                  ],
                ),
                trailing: Visibility(
                  visible: true, // Keep always visible for now; business rules can be re-added later.
                  child: GestureDetector(
                    onTap: () {
                      //Open chat
                      String fullName = firstLineName;
                      if (!isOwnerOperatorRow && lastName.isNotEmpty) {
                        fullName += ' $lastName';
                      }
                      debugPrint("Tapped chat icon for userId: $userId, membershipType: $membershipTypeInt, receiverName: $fullName");
                      final ChatService chatService = ChatService();
                      chatService.openChatForProfile(
                        otherUserId: userId ?? '',
                        otherProfileType: membershipTypeInt,
                        receiverName: fullName,
                        photoPath: photoPath,
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/message.svg',
                      height: 3.0.h,
                      colorFilter: ColorFilter.mode(AppColor.secondaryColor2, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
              Divider(
                indent: 10,
                endIndent: 10,
                color: AppColor.secondaryColor1,
                thickness: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}