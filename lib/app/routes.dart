import 'package:crew_support/features/auth/forgot_controller.dart';
import 'package:crew_support/features/auth/login_controller.dart';
import 'package:crew_support/features/auth/otp_controller.dart';
import 'package:crew_support/features/auth/otp_screen.dart';
import 'package:crew_support/features/auth/register_controller.dart';
import 'package:crew_support/features/availability/add_availability_controller.dart';
import 'package:crew_support/features/availability/add_availability_screen.dart';
import 'package:crew_support/features/availability/edit_availability_controller.dart';
import 'package:crew_support/features/availability/edit_availability_screen.dart';
import 'package:crew_support/features/availability/manage_availability_controller.dart';
import 'package:crew_support/features/availability/manage_availability_screen.dart';
import 'package:crew_support/features/connection/connection_controller.dart';
import 'package:crew_support/features/connection/connection_screen.dart';
import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/features/dashboard_screen.dart';
import 'package:crew_support/features/docs/faq_screen.dart';
import 'package:crew_support/features/favorite/favorite_screen.dart';
import 'package:crew_support/features/favorite/favorite_controller.dart';
import 'package:crew_support/features/home/subscreens/add_bank_detail_controller.dart';
import 'package:crew_support/features/home/subscreens/add_bank_detail_screen.dart';
import 'package:crew_support/features/home/subscreens/rate_trip_controller.dart';
import 'package:crew_support/features/home/subscreens/rate_trip_screen.dart';
import 'package:crew_support/features/home/subscreens/trip_crew_overview_controller.dart';
import 'package:crew_support/features/home/subscreens/trip_crew_overview_screen.dart';
import 'package:crew_support/features/home/subscreens/trip_notification_timeline_controller.dart';
import 'package:crew_support/features/home/subscreens/trip_notification_timeline_screen.dart';
import 'package:crew_support/features/home/subscreens/trip_summary_controller.dart';
import 'package:crew_support/features/home/subscreens/trip_summary_screen.dart';
import 'package:crew_support/features/message/chat_controller.dart';
import 'package:crew_support/features/message/chat_screen.dart';
import 'package:crew_support/features/message/message_controller.dart';
import 'package:crew_support/features/message/message_screen.dart';
import 'package:crew_support/features/notification/notification_controller.dart';
import 'package:crew_support/features/notification/notification_screen.dart';
import 'package:crew_support/features/profile/view_profile_detail_screen/flight_attendant_view_profile_controller.dart';
import 'package:crew_support/features/profile/view_profile_detail_screen/flight_attendant_view_profile_screen.dart';
import 'package:crew_support/features/profile/view_profile_detail_screen/owner_view_profile_controller.dart';
import 'package:crew_support/features/profile/view_profile_detail_screen/owner_view_profile_screen.dart';
import 'package:crew_support/features/profile/view_profile_detail_screen/pilot_view_profile_controller.dart';
import 'package:crew_support/features/profile/view_profile_detail_screen/pilot_view_profile_screen.dart';
import 'package:crew_support/features/profile/pilot/add_rating_type_controller.dart';
import 'package:crew_support/features/profile/pilot/add_rating_type_screen.dart';
import 'package:crew_support/features/profile/pilot/type_rating_controller.dart';
import 'package:crew_support/features/profile/pilot/type_rating_screen.dart';
import 'package:crew_support/features/profile/pilot/update_rating_type_controller.dart';
import 'package:crew_support/features/profile/pilot/update_rating_type_screen.dart';
import 'package:crew_support/features/profile/profile_flight_attendant_controller.dart';
import 'package:crew_support/features/profile/profile_flight_attendant_screen.dart';
import 'package:crew_support/features/profile/profile_owner_controller.dart';
import 'package:crew_support/features/profile/profile_owner_screen.dart';
import 'package:crew_support/features/profile/profile_pilot_controller.dart';
import 'package:crew_support/features/profile/profile_pilot_screen.dart';
import 'package:crew_support/features/trip/captain/day_rate_captain_controller.dart';
import 'package:crew_support/features/trip/captain/day_rate_captain_screen.dart';
import 'package:crew_support/features/trip/captain/required_experience_captain_controller.dart';
import 'package:crew_support/features/trip/captain/required_experience_captain_screen.dart';
import 'package:crew_support/features/trip/captain/result_captain_controller.dart';
import 'package:crew_support/features/trip/captain/result_captain_screen.dart';
import 'package:crew_support/features/trip/create_direct_trip_controller.dart';
import 'package:crew_support/features/trip/create_direct_trip_screen.dart';
import 'package:crew_support/features/trip/create_trip_controller.dart';
import 'package:crew_support/features/trip/create_trip_screen.dart';
import 'package:crew_support/features/trip/flight_attendent/day_rate_fa_controller.dart';
import 'package:crew_support/features/trip/flight_attendent/day_rate_fa_screen.dart';
import 'package:crew_support/features/trip/flight_attendent/required_experience_fa_controller.dart';
import 'package:crew_support/features/trip/flight_attendent/required_experience_fa_screen.dart';
import 'package:crew_support/features/trip/flight_attendent/result_fa_controller.dart';
import 'package:crew_support/features/trip/flight_attendent/result_fa_screen.dart';
import 'package:crew_support/features/trip/flight_instructor/day_rate_fi_controller.dart';
import 'package:crew_support/features/trip/flight_instructor/day_rate_fi_screen.dart';
import 'package:crew_support/features/trip/flight_instructor/required_experience_fi_controller.dart';
import 'package:crew_support/features/trip/flight_instructor/required_experience_fi_screen.dart';
import 'package:crew_support/features/trip/flight_instructor/result_fi_controller.dart';
import 'package:crew_support/features/trip/flight_instructor/result_fi_screen.dart';
import 'package:crew_support/features/trip/second_in_command/day_rate_sic_controller.dart';
import 'package:crew_support/features/trip/second_in_command/day_rate_sic_screen.dart';
import 'package:crew_support/features/trip/second_in_command/required_experience_sic_controller.dart';
import 'package:crew_support/features/trip/second_in_command/required_experience_sic_screen.dart';
import 'package:crew_support/features/trip/second_in_command/result_sic_controller.dart';
import 'package:crew_support/features/trip/second_in_command/result_sic_screen.dart';
import 'package:crew_support/features/trip/select_profile_controller.dart';
import 'package:crew_support/features/trip/select_profile_screen.dart';
import 'package:crew_support/features/webview_stack_controller.dart';
import 'package:crew_support/features/webview_stack_screen.dart';
import 'package:get/get.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/docs/help_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';
  static const help = '/help';
  static const faq = '/faq';
  static const dashboard = '/dashboard';
  static const otp = '/otp';
  static const selectProfile = '/selectProfile';
  static const createTrip = '/createTrip';
  static const createDirectTrip = '/createDirectTrip';
  static const ownerViewProfile = '/ownerViewProfile';
  static const pilotViewProfile = '/pendingPilotProfile';
  static const fAViewProfile = '/pending_fa_profile';
  static const webviewStack = '/webviewStack';
  static const requiredExperienceCaptain = '/requiredExperienceCaptain';
  static const requiredExperienceSIC = '/requiredExperienceSIC';
  static const requiredExperienceFA = '/requiredExperienceFA';
  static const requiredExperienceFI = '/requiredExperienceFI';
  static const dayRateCaptain = '/day-rate-captain';
  static const dayRateSIC = '/day-rate-SIC';
  static const dayRateFA = '/day-rate-FA';
  static const dayRateFI = '/day-rate-FI';
  static const resultCaptain = '/resultCaptain';
  static const resultSIC = '/resultSIC';
  static const resultFA = '/resultFA';
  static const resultFI = '/resultFI';
  static const profileOwner = '/profile-owner';
  static const profilePilot = '/profile-pilot';
  static const profileFlightAttendant = '/profile-flight-attendant';
  static const manageAvailability = '/manage-availability';
  static const addAvailability = '/add-availability';
  static const editAvailability = '/edit-availability';
  static const connection = '/connection';
  static const notification = '/notification';
  static const message = '/message';
  static const chat = '/chat';
  static const addRatingType = '/addRatingType';
  static const typeRating = '/typeRating';
  static const updateRatingType = '/updateRatingType';
  static const tripCrewOverview = '/tripCrewOverview';
  static const tripPilotDetail = '/tripPilotDetail';
  static const tripNotificationTimeline = '/tripNotificationTimeline';
  static const tripSummary = '/tripSummary';
  static const addBankDetail = '/addBankDetail';
  static const rateTrip = '/rateTrip';
  static const favorite = '/favorite';

  static final pages = <GetPage>[
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(() => RegisterController());
      }),
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotController>(() => ForgotController());
      }),
    ),
    GetPage(name: help, page: () => const HelpScreen()),
    GetPage(name: faq, page: () => const FaqScreen()),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OtpController>(() => OtpController());
      }),
    ),
    GetPage(
      name: AppRoutes.selectProfile,
      page: () => const SelectProfileScreen(),
      binding: BindingsBuilder(() {
        Get.create<SelectProfileController>(() => SelectProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.createTrip,
      page: () => const CreateTripScreen(),
      binding: BindingsBuilder(() {
        Get.create<CreateTripController>(() => CreateTripController());
      }),
    ),
    GetPage(
      name: AppRoutes.createDirectTrip,
      page: () => const CreateDirectTripScreen(),
      binding: BindingsBuilder(() {
        Get.create<CreateDirectTripController>(() => CreateDirectTripController());
      }),
    ),
    GetPage(
      name: AppRoutes.ownerViewProfile,
      page: () => const OwnerViewProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OwnerViewProfileController>(
          () => OwnerViewProfileController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.pilotViewProfile,
      page: () => const PilotViewProfileScreen(),
      binding: PilotViewProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.fAViewProfile,
      page: () => const FlightAttendantViewProfileScreen(),
      binding: FlightAttendantViewProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.webviewStack,
      page: () => const WebviewStackScreen(),
      binding: BindingsBuilder(() {
        Get.create<WebviewStackController>(() => WebviewStackController());
      }),
    ),
    GetPage(
      name: AppRoutes.requiredExperienceSIC,
      page: () => const RequiredExperienceSICScreen(),
      binding: RequiredExperienceSICBinding(),
    ),
    GetPage(
      name: AppRoutes.requiredExperienceFA,
      page: () => const RequiredExperienceFAScreen(),
      binding: RequiredExperienceFABinding(),
    ),
    GetPage(
      name: AppRoutes.requiredExperienceCaptain,
      page: () => const RequiredExperienceCaptainScreen(),
      binding: RequiredExperienceCaptainBinding(),
    ),
    GetPage(
      name: AppRoutes.requiredExperienceFI,
      page: () => const RequiredExperienceFIScreen(),
      binding: BindingsBuilder(() {
        Get.create<RequiredExperienceFIController>(
          () => RequiredExperienceFIController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.dayRateCaptain,
      page: () => const DayRateCaptainScreen(),
      binding: DayRateCaptainBinding(),
    ),
    GetPage(
      name: AppRoutes.dayRateSIC,
      page: () => const DayRateSICScreen(),
      binding: DayRateSicBinding(),
    ),
    GetPage(
      name: AppRoutes.dayRateFA,
      page: () => const DayRateFAScreen(),
      binding: DayRateFABinding(),
    ),
    GetPage(
      name: AppRoutes.dayRateFI,
      page: () => const DayRateFIScreen(),
      binding: BindingsBuilder(() {
        Get.create<DayRateFIController>(() => DayRateFIController());
      }),
    ),
    GetPage(
      name: AppRoutes.resultCaptain,
      page: () => ResultCaptainScreen(),
      binding: ResultCaptainBinding(),
    ),
    GetPage(
      name: AppRoutes.resultSIC,
      page: () => const ResultSICScreen(),
      binding: ResultSICBinding(),
    ),
    GetPage(
      name: AppRoutes.resultFA,
      page: () => const ResultFAScreen(),
      binding: ResultFABinding(),
    ),
    GetPage(
      name: AppRoutes.resultFI,
      page: () => const ResultFiScreen(),
      binding: ResultFiBinding(),
    ),
    GetPage(
      name: AppRoutes.profileOwner,
      page: () => const ProfileOwnerScreen(),
    ),
    GetPage(
      name: AppRoutes.profilePilot,
      page: () => const ProfilePilotScreen(),
    ),
    GetPage(
      name: AppRoutes.profileFlightAttendant,
      page: () => const ProfileFlightAttendantScreen(),
    ),
    GetPage(
      name: manageAvailability,
      page: () => const ManageAvailabilityScreen(),
      binding: ManageAvailabilityBinding(),
    ),
    GetPage(
      name: addAvailability,
      page: () => const AddAvailabilityScreen(), // expect arguments: maxDate, minDate
      binding: AddAvailabilityBinding(),
    ),
    GetPage(
      name: editAvailability,
      page: () => const EditAvailabilityScreen(), // expect arguments: maxDate, minDate, item
      binding: EditAvailabilityBinding(),
    ),
    GetPage(
      name: AppRoutes.connection,
      page: () => const ConnectionScreen(),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppRoutes.message,
      page: () => const MessageScreen(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>;

        Get.lazyPut<ChatController>(
          () => ChatController(
            messageData: args['messageData'],
            fromNotification: args['fromNotification'] ?? false,
            unreadMessage: args['unreadMessage'],
            conversationId: args['conversationId'],
            otherUserId: args['otherUserId'],
            otherProfileType: args['otherProfileType'],
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.addRatingType,
      page: () => const AddRatingTypeScreen(),
      binding: BindingsBuilder(() {
        Get.create<AddRatingTypeController>(() => AddRatingTypeController());
      }),
    ),
    GetPage(
      name: AppRoutes.typeRating,
      page: () => const TypeRatingScreen(),
      binding: BindingsBuilder(() {
        Get.create<TypeRatingController>(() => TypeRatingController());
      }),
    ),
    GetPage(
      name: AppRoutes.updateRatingType,
      page: () => const UpdateRatingTypeScreen(),
      binding: UpdateRatingTypeBinding(),
    ),
    // routes
    GetPage(
      name: AppRoutes.tripCrewOverview,
      page: () => const TripCrewOverviewScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TripCrewOverviewController>(() => TripCrewOverviewController());
      }),
    ),
    GetPage(
      name: AppRoutes.tripNotificationTimeline,
      page: () => const TripNotificationTimelineScreen(),
      binding: BindingsBuilder(() {
        Get.create<TripNotificationTimelineController>(() => TripNotificationTimelineController());
      }),
    ),
    GetPage(
      name: AppRoutes.tripSummary,
      page: () => const TripSummaryScreen(),
      binding: BindingsBuilder(() {
        Get.create<TripSummaryController>(() => TripSummaryController());
      }),
    ),
    GetPage(
      name: AppRoutes.addBankDetail,
      page: () => const AddBankDetailScreen(),
      binding: BindingsBuilder(() {
        Get.create<AddBankDetailController>(() => AddBankDetailController());
      }),
    ),
    GetPage(
      name: AppRoutes.rateTrip,
      page: () => const RateTripScreen(),
      binding: BindingsBuilder(() {
        Get.create<RateTripController>(() => RateTripController());
      }),
    ),
    GetPage(
      name: AppRoutes.favorite,
      page: () => const FavoriteScreen(),
      binding: BindingsBuilder(() {
        Get.create<FavoriteController>(() => FavoriteController());
      }),
    ),
  ];
}

/// Central place to register controllers used across the app
class AppBindings extends Bindings {
  @override
  void dependencies() {
        // Reserved for global controllers. Leave empty or add only global controllers here.
        Get.lazyPut<ProfileOwnerController>(() => ProfileOwnerController());
        Get.lazyPut<ProfilePilotController>(() => ProfilePilotController());
        Get.lazyPut<ProfileFlightAttendantController>(() => ProfileFlightAttendantController());
        Get.lazyPut<ConnectionController>(() => ConnectionController());
        Get.lazyPut<NotificationController>(() => NotificationController());

        // ✅ Let GetX recreate MessageController if it was deleted
        Get.lazyPut<MessageController>(() => MessageController(), fenix: true);
        // What this does:
        // When the Messages tab is disposed and MessageController is auto-removed, the factory remains registered.
        // Next time MessageScreen is built and Get.find<MessageController>() is called, GetX will new up a fresh MessageController instead of returning null.
  }
}
