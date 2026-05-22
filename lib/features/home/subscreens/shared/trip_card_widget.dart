import 'package:crew_support/database/airport_code_model.dart';
import 'package:crew_support/model/trip_model.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

/// Shared Trip card widget styled like the legacy Current tab card.
/// - Outer container pulses for unread (ColorTween), fixed for read.
/// - Inner container is white and static.
/// - Right side arrow icon.
class TripCardWidget extends StatelessWidget {
  final TripModel trip;
  final bool isOwner;
  final AnimationController pulseController;
  final Animation<Color?> unreadColorAnimation;
  final VoidCallback onTap;

  const TripCardWidget({
    super.key,
    required this.trip,
    required this.isOwner,
    required this.pulseController,
    required this.unreadColorAnimation,
    required this.onTap,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    // IMPORTANT:
    // Start/End are DATE-ONLY fields. Do NOT convert to local time here,
    // because that can shift the calendar day for timezones behind UTC (e.g. EST).
    // We always format using the UTC calendar date so everyone sees the same day.
    final d = date.toUtc();
    return DateFormat('MM/dd/yyyy').format(DateTime.utc(d.year, d.month, d.day));
  }

  Future<String> _resolveAirportIdent(int? sourceId) async {
    if (sourceId == null || sourceId <= 0) return '-';

    try {
      final airport = await AirportCache.instance.getBySourceId(sourceId);
      if (airport == null) return '-';
      return airport.ident.isNotEmpty ? airport.ident : '-';
    } catch (_) {
      return '-';
    }
  }

  Future<({String departure, String destination})> _resolveDepDest() async {
    final dep = await _resolveAirportIdent(trip.departureSourceId);
    final dest = await _resolveAirportIdent(trip.destinationSourceId);
    return (departure: dep, destination: dest);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final Color animatedOuterColor = trip.isRead
                  ? AppColor.currentRead
                  : (unreadColorAnimation.value ?? AppColor.secondaryColor1);

              return Container(
                margin: EdgeInsets.all(3.0.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: animatedOuterColor,
                ),
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.all(0.6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.textColor2,
              ),
              padding: EdgeInsets.only(
                top: 1.0.h,
                bottom: 1.0.h,
                left: 2.0.w,
                right: 2.0.w,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TripInfoRow(label: 'Trip Name : ', value: trip.tripName),
                  const SizedBox(height: 10),
                  _TripInfoRow(label: 'Aircraft : ', value: trip.aircraft),
                  const SizedBox(height: 10),
                  FutureBuilder<({String departure, String destination})>(
                    future: _resolveDepDest(),
                    builder: (context, snap) {
                      final dep = snap.data?.departure ?? '-';
                      final dest = snap.data?.destination ?? '-';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TripInfoRow(label: 'Departure : ', value: dep),
                          const SizedBox(height: 10),
                          _TripInfoRow(label: 'Destination : ', value: dest),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _TripInfoRow(
                    label: 'Trip Start Date : ',
                    value: _formatDate(trip.startDate),
                  ),
                  const SizedBox(height: 10),
                  _TripInfoRow(
                    label: 'Trip End Date : ',
                    value: _formatDate(trip.endDate),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
          // SizedBox(width: isOwner ? 1.0.w : 10.0.w),
          SizedBox(width: 1.0.w),
          Icon(Icons.arrow_forward_ios, color: AppColor.currentRead),
        ],
      ),
    );
  }
}

class _TripInfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _TripInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 35.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.spV2,
              color: AppColor.textColor1,
            ),
          ),
        ),
        SizedBox(
          width: 30.w,
          child: Text(
            value ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.spV2,
              color: AppColor.secondaryColor1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Shared wrapper for Owner trip tabs
// -----------------------------------------------------------------------------

/// OwnerTripsTabView
/// ----------------
/// Shared wrapper for Owner trip tabs.
///
/// Handles:
/// - Owner-only gating
/// - Pull-to-refresh
/// - Loading state
/// - Empty state
/// - List building (delegated to caller)
///
/// This removes duplication across all trip tabs while keeping UI identical.
class OwnerTripsTabView extends StatelessWidget {
  final RxBool isLoading;
  final RxList items;
  final RxInt selectedProfileType;
  final Future<void> Function() onRefresh;

  /// Builds the actual list when data is present
  final Widget Function(BuildContext context) listBuilder;

  /// Empty text shown for owner
  final String ownerEmptyText;

  /// Text shown for non-owner roles
  final String nonOwnerText;

  /// Common text style (matches existing screens)
  final TextStyle textStyle;

  /// RefreshIndicator color
  final Color refreshIndicatorColor;

  const OwnerTripsTabView({
    super.key,
    required this.isLoading,
    required this.items,
    required this.selectedProfileType,
    required this.onRefresh,
    required this.listBuilder,
    required this.ownerEmptyText,
    required this.nonOwnerText,
    required this.textStyle,
    required this.refreshIndicatorColor,
  });

  bool get _isOwner =>
      selectedProfileType.value == MembershipType.ownerOperator;

  Widget _centerText(String text) {
    return Center(child: Text(text, style: textStyle));
  }

  Widget _scrollableMessage(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 25.h),
        _centerText(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Non-owner: just show message (no refresh)
      // if (!_isOwner) {
      //   return _centerText(nonOwnerText);
      // }

      // Owner: allow pull-to-refresh in all states
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: refreshIndicatorColor,
        child: isLoading.value
            ? _scrollableMessage('Loading...')
            : items.isEmpty
                ? _scrollableMessage(_isOwner ? ownerEmptyText : nonOwnerText)
                : listBuilder(context),
      );
    });
  }
}