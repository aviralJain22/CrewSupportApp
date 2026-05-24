import 'package:crew_support/Api/Api_service.dart';
import 'package:crew_support/model/get_favorite_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// Controller for FavoriteScreen.
///
/// Handles:
/// - Loading favorite profiles
/// - Removing favorites
/// - Loading state
class FavoriteController extends GetxController {
  /// Favorite list
  final RxList<Favourite> favorites = <Favourite>[].obs;

  /// Loading state
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  @override
  void onClose() {
    EasyLoading.dismiss();
    super.onClose();
  }

  /// Load favorites from API
  Future<void> getData() async {
    try {
      isLoading.value = true;

      // final value = await getFavoriteList();

      // if (value?.datas == null) {
      //   debugPrint("Favorite list is empty");
      //   favorites.clear();
      // } else {
      //   favorites.assignAll(value!.datas.favourites);
      // }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
      favorites.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove favorite profile
  Future<void> removeFavorite(Favourite favorite) async {
    try {
      favorites.remove(favorite);

      await insertUpdateFavourite(
        userId: favorite.fkPilotid.toString(),
        pilotID: favorite.fkUserId.toString(),
        isFavourite: false,
      );
    } catch (e) {
      debugPrint("Error removing favorite: $e");
    }
  }

  /// Parse rating safely
  double parseRating(String? rating) {
    return double.tryParse(rating ?? '0') ?? 0;
  }
}