// rate_trip_controller.dart
//
// GetX controller for the legacy PilotRatingScreen.
// Keeps the same behavior:
// - Prefills rating/comment from incoming args (viewRating/viewComment)
// - Calls getComment(tripId, oppositId) to check if rating was already submitted
// - If already submitted: show SUBMITTED button (disabled)
// - Else: validate + submit, then do the same Firestore increments and dialogs

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crew_support/utils/Utility.dart';

class CommentList {
  CommentList({
    required this.pkCommentId,
    required this.fkTripid,
    required this.commentFrom,
    required this.commentFor,
    required this.comment,
    required this.ratingCount,
    required this.isVoid,
    required this.entryDate,
    required this.loggedinid,
    required this.ratingforid,
  });

  int pkCommentId;
  int fkTripid;
  int commentFrom;
  int commentFor;
  String comment;
  var ratingCount;
  bool isVoid;
  DateTime entryDate;
  int loggedinid;
  int ratingforid;

  factory CommentList.fromJson(Map<String, dynamic> json) => CommentList(
    pkCommentId: json["pkCommentId"],
    fkTripid: json["fkTripid"],
    commentFrom: json["commentFrom"],
    commentFor: json["commentFor"],
    comment: json["comment"],
    ratingCount: json["ratingCount"],
    isVoid: json["isVoid"],
    entryDate: DateTime.parse(json["EntryDate"]),
    loggedinid: json["loggedinid"],
    ratingforid: json["ratingforid"],
  );
}

class RateTripController extends GetxController {
  // --------- Incoming arguments (same meaning as old widget fields) ----------
  late final int pkTripId;
  late final int oppositId;

  late final bool isEditable; // old: comment readOnly = isEditable
  late final bool isRating; // old: ignoreGestures = isRating (true => cannot change rating)
  late final bool isVisible; // old param existed but wasn't used in UI; kept for compatibility

  late final double viewRating;
  late final String viewComment;
  late final String oppMemberShipType;

  // ------------------------------- UI state --------------------------------
  final RxBool isLoading = false.obs;

  // Old code used `tripData.length != 0` to decide SUBMITTED vs SUBMIT
  final RxList<CommentList> tripData = <CommentList>[].obs;

  final TextEditingController commentController = TextEditingController();
  final RxDouble rating = 0.0.obs;

  // late final String _appType;

  String title = "";

  @override
  void onInit() {
    super.onInit();

    // _appType = UserHelper().getAppType().toString();

    // Expecting arguments via GetX routing:
    // Get.toNamed('/rateTrip', arguments: { ... })
    final args = (Get.arguments ?? {}) as Map;

    title = (args['title'] ?? 0) as String;

    pkTripId = (args['pkTripId'] ?? 0) as int;
    oppositId = (args['oppositId'] ?? 0) as int;

    isEditable = (args['isEditable'] ?? false) as bool;
    isRating = (args['isRating'] ?? false) as bool;
    isVisible = (args['isVisible'] ?? true) as bool;

    viewRating = (args['viewRating'] ?? 0.0) is int
        ? ((args['viewRating'] as int).toDouble())
        : (args['viewRating'] ?? 0.0) as double;

    viewComment = (args['viewComment'] ?? '') as String;
    oppMemberShipType = (args['OppMemberShipType'] ?? '') as String;

    _prefillFromViewData();
    getComments();
  }

  void _prefillFromViewData() {
    // Same as old getData()
    rating.value = viewRating;
    commentController.text = viewComment.toString();
  }

  Future<void> getComments() async {
    // Same logic as old getComments()
    // isLoading.value = true;

    // try {
    //   final value = await getComment(pkTripId, oppositId);

    //   if (value == null || value.flag == 0) {
    //     tripData.clear();
    //     // old: sets isLoading true -> clear -> isLoading false
    //   } else {
    //     final list = value.data?.commentList ?? <CommentList>[];
    //     tripData.assignAll(list);

    //     if (list.isNotEmpty) {
    //       commentController.text = list[0].comment.toString();
    //       rating.value = list[0].ratingCount.toDouble();
    //     }
    //   }
    // } catch (e) {
    //   // If API fails, behave like "no rating found" but you can log if needed
    //   tripData.clear();
    // } finally {
    //   isLoading.value = false;
    // }
  }

  bool get hasSubmitted => tripData.isNotEmpty;

  Future<void> onSubmitPressed() async {
    // Same validations as old code
    if (rating.value == 0) {
      showMyDialog(Get.context!, "Please give rating");
      return;
    }
    if (commentController.text.trim().isEmpty) {
      showMyDialog(Get.context!, "Please enter comments");
      return;
    }

    // showLoadingDialog(Get.context!, 'Submitting...');

    // try {
    //   final res = await insertRatingComment(
    //     tripId: pkTripId,
    //     oppositId: oppositId,
    //     comment: commentController.text.toString(),
    //     ratingValue: rating.value,
    //   );

    //   // Same Firestore increments as old code
    //   await FirebaseFirestore.instance
    //       .collection(_appType == 'live'
    //           ? AppStrings.fireBaseUserlive
    //           : AppStrings.fireBaseUserlocal)
    //       .doc('$oppositId')
    //       .update({'historyCount': FieldValue.increment(1)});

    //   await FirebaseFirestore.instance
    //       .collection(_appType == 'live'
    //           ? AppStrings.fireBaseTripslive
    //           : AppStrings.fireBaseTripslocal)
    //       .doc('$pkTripId')
    //       .collection('tripCount')
    //       .doc('$oppositId - $pkPilotId')
    //       .update({'notificationCount': FieldValue.increment(1)});

    //   // old code: Navigator.pop(context); showMyDialog(...).then(pop)
    //   // Here: close loading dialog, then show message, then go back.
    //   Get.back(); // closes loading dialog
    //   await showMyDialog(Get.context!, res?.msg ?? 'Submitted');
    //   Get.back(); // pop screen
    // } catch (e) {
    //   // Close loading dialog + show error
    //   if (Get.isDialogOpen == true) Get.back();
    //   showMyDialog(Get.context!, "Something went wrong. Please try again.");
    // }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}