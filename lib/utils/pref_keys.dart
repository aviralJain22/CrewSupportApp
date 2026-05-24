/// All shared preferences keys used in the app.
class PrefKeys {
  static const String selectedProfileType = "selectedProfileType";
  //Following key is not complete: CurrentLoggedInUser's _UserID + ProfileType + This key.
  //This is to ensure that if user logs out and another user logs in or if the user changes profile type, the tutorial will show again for the new user.
  static const String tutorialVersion = "_tutv"; // Increment this when tutorial content changes to show it again

}