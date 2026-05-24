class RatingCertification {
  final String objectId;
  final String ratingName;
  final int? categoryId;
  final int? classId;
  final String? aircraftType;

  // NEW: numeric fields
  final double? totalHours;
  final double? pic;

  final double? minimumRate;
  final String? currentInType;
  final bool? isReqPrev12MonthTraining;
  final bool? isVoid;
  final DateTime? entryDate;
  final int? certiIndex;

  RatingCertification({
    required this.objectId,
    required this.ratingName,
    this.categoryId,
    this.classId,
    this.aircraftType,
    this.totalHours,
    this.pic,
    this.minimumRate,
    this.currentInType,
    this.isReqPrev12MonthTraining,
    this.isVoid,
    this.entryDate,
    this.certiIndex,
  });

  /// Helper: convert dynamic -> double?
  /// - null/undefined -> null
  /// - num -> toDouble()
  /// - string -> tryParse (kept for safety in case any old API response still returns strings)
  static double? _toDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  factory RatingCertification.fromJson(Map<String, dynamic> json) {
    // Prefer new keys, fall back to old ones if ever present
    final double? parsedTotalHours =
        _toDoubleOrNull(json["totalHours"] ?? json["hours"]);
    final double? parsedPic =
        _toDoubleOrNull(json["pic"] ?? json["PIC"]);

    return RatingCertification(
      objectId: json["objectId"] ?? "",
      ratingName: json["ratingName"] ?? "",
      categoryId: json["categoryId"],
      classId: json["classId"],
      aircraftType: json["aircraftType"],

      totalHours: parsedTotalHours,
      pic: parsedPic,

      minimumRate: _toDoubleOrNull(json["minimumRate"]),
      currentInType: json["currentInType"],
      isReqPrev12MonthTraining: json["isReqPrev12MonthTraining"],
      isVoid: json["isVoid"],
      entryDate: json["entryDate"] != null
          ? DateTime.tryParse(json["entryDate"].toString())
          : null,
      certiIndex: json["certiIndex"],
    );
  }
}