import 'package:crew_support/features/connection/connection_profile_model.dart';
import 'package:crew_support/helper/user_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'connection_controller.dart';

class ConnectionScreen extends GetView<ConnectionController> {
  const ConnectionScreen({super.key});

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF0D0B0E);
  static const Color _cardBg = Color(0xFF18140F);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _goldDim = Color(0xFF8A6E20);
  static const Color _surface = Color(0xFF1E1812);

  // ── Demo / presentation data ───────────────────────────────────────────────
  // Set to false before shipping to production.
  static const bool _showDemoData = true;

  static final List<ConnectionProfile> _demoInvitations = [
    ConnectionProfile(
      connectionId: 'demo_inv_1', status: 'pending', direction: 'received',
      otherUserId: 'u1', otherProfileId: 'p1', otherProfileType: 3,
      fullName: 'James Mitchell', firstName: 'James', lastName: 'Mitchell',
      photoPath: 'https://i.pravatar.cc/150?img=11', isAccepted: false,
    ),
    ConnectionProfile(
      connectionId: 'demo_inv_2', status: 'pending', direction: 'received',
      otherUserId: 'u2', otherProfileId: 'p2', otherProfileType: 4,
      fullName: 'Sophie Laurent', firstName: 'Sophie', lastName: 'Laurent',
      photoPath: 'https://i.pravatar.cc/150?img=47', isAccepted: false,
    ),
  ];

  static final List<ConnectionProfile> _demoConnections = [
    ConnectionProfile(
      connectionId: 'demo_c1', status: 'accepted', direction: 'sent',
      otherUserId: 'u3', otherProfileId: 'p3', otherProfileType: 3,
      fullName: 'Alexander Reid', firstName: 'Alexander', lastName: 'Reid',
      photoPath: 'https://i.pravatar.cc/150?img=15', isAccepted: true,
    ),
    ConnectionProfile(
      connectionId: 'demo_c2', status: 'accepted', direction: 'received',
      otherUserId: 'u4', otherProfileId: 'p4', otherProfileType: 4,
      fullName: 'Priya Sharma', firstName: 'Priya', lastName: 'Sharma',
      photoPath: 'https://i.pravatar.cc/150?img=44', isAccepted: true,
    ),
    ConnectionProfile(
      connectionId: 'demo_c3', status: 'accepted', direction: 'sent',
      otherUserId: 'u5', otherProfileId: 'p5', otherProfileType: 1,
      fullName: 'Charter Wings LLC', firstName: 'Charter', lastName: 'Wings',
      photoPath: 'https://i.pravatar.cc/150?img=68', isAccepted: true,
    ),
    ConnectionProfile(
      connectionId: 'demo_c4', status: 'accepted', direction: 'received',
      otherUserId: 'u6', otherProfileId: 'p6', otherProfileType: 3,
      fullName: 'Ethan Calloway', firstName: 'Ethan', lastName: 'Calloway',
      photoPath: 'https://i.pravatar.cc/150?img=12', isAccepted: true,
    ),
    ConnectionProfile(
      connectionId: 'demo_c5', status: 'accepted', direction: 'sent',
      otherUserId: 'u7', otherProfileId: 'p7', otherProfileType: 4,
      fullName: 'Isabella Torres', firstName: 'Isabella', lastName: 'Torres',
      photoPath: 'https://i.pravatar.cc/150?img=49', isAccepted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: RefreshIndicator(
        color: _gold,
        backgroundColor: _cardBg,
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value) return _buildLoading();

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 1.5.h)),
              SliverToBoxAdapter(child: _buildSearchBar(context)),
              // ── Invitations section ──────────────────────────────────────
              Builder(builder: (ctx) {
                final invitations = _showDemoData && controller.pendingReceivedRequestList.isEmpty
                    ? _demoInvitations
                    : controller.pendingReceivedRequestList.toList();

                if (invitations.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverMainAxisGroup(slivers: [
                  SliverToBoxAdapter(
                    child: _sectionHeader('Invitations', count: invitations.length, icon: Icons.mail_outline_rounded),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => _buildInvitationCard(context, invitations[i]),
                      childCount: invitations.length,
                    ),
                  ),
                ]);
              }),
              // ── Connections section ──────────────────────────────────────
              Builder(builder: (ctx) {
                final connections = _showDemoData && controller.filteredRequestList.isEmpty
                    ? _demoConnections
                    : controller.filteredRequestList.toList();

                return SliverMainAxisGroup(slivers: [
                  SliverToBoxAdapter(
                    child: _sectionHeader('My Network', count: connections.length, icon: Icons.people_alt_outlined),
                  ),
                  connections.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmpty())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (c, i) => _buildConnectionCard(context, connections[i]),
                            childCount: connections.length,
                          ),
                        ),
                ]);
              }),
              SliverToBoxAdapter(child: SizedBox(height: 3.h)),
            ],
          );
        }),
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return SizedBox(
      height: 60.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.threeRotatingDots(color: _gold, size: 48.spV2),
            SizedBox(height: 2.h),
            Text('Loading your network…',
                style: TextStyle(color: Colors.white38, fontSize: 10.spV2)),
          ],
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.22)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.filterByName,
          onTap: () => FocusScope.of(context).requestFocus(),
          style: TextStyle(color: Colors.white, fontSize: 11.spV2),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded, color: _gold.withValues(alpha: 0.7), size: 18.sp),
            hintText: 'Search connections…',
            hintStyle: TextStyle(color: Colors.white30, fontSize: 10.spV2),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 3.w),
          ),
        ),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, {required int count, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.5.h, 4.w, 1.2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: _gold, size: 13.sp),
          ),
          SizedBox(width: 2.5.w),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16.spV2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.3)),
            ),
            child: Text('$count',
                style: TextStyle(color: _gold, fontSize: 9.spV2, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Invitation card ────────────────────────────────────────────────────────

  Widget _buildInvitationCard(BuildContext context, ConnectionProfile req) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(color: _gold.withValues(alpha: 0.06), blurRadius: 14, spreadRadius: 1),
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.5.w),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(req.photoPath, size: 24.sp),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.spV2,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 0.4.h),
                      _rolePill(req.otherProfileType.toString()),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            // Divider
            Container(height: 1, color: _gold.withValues(alpha: 0.1)),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(child: _declineButton(context, req)),
                SizedBox(width: 3.w),
                Expanded(child: _acceptButton(context, req)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _acceptButton(BuildContext context, ConnectionProfile req) {
    return GestureDetector(
      onTap: () async => controller.acceptConnectionRequest(req),
      child: Container(
        height: 4.8.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFB8960C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_rounded, color: Colors.black, size: 16),
            SizedBox(width: 1.5.w),
            Text('Accept',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _declineButton(BuildContext context, ConnectionProfile req) {
    return GestureDetector(
      onTap: () async => controller.denyConnectionRequest(req),
      child: Container(
        height: 4.8.h,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _gold.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded, color: Colors.white54, size: 16),
            SizedBox(width: 1.5.w),
            Text('Decline',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.spV2,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Connection card ────────────────────────────────────────────────────────

  Widget _buildConnectionCard(BuildContext context, ConnectionProfile req) {
    return Dismissible(
      key: ValueKey('conn_${req.connectionId}_${req.otherProfileId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmUnfriend(context, req),
      onDismissed: (_) async => controller.unfriendConnection(req),
      background: Container(
        margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1010),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_remove_rounded, color: Colors.red.shade300, size: 20.sp),
            SizedBox(height: 0.4.h),
            Text('Remove', style: TextStyle(color: Colors.red.shade300, fontSize: 8.spV2)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => controller.handleRowTap(req),
        child: Container(
          margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withValues(alpha: 0.14)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: EdgeInsets.all(3.5.w),
            child: Row(
              children: [
                _buildAvatar(req.photoPath, size: 24.sp),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.spV2,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 0.5.h),
                      _rolePill(req.otherProfileType.toString()),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                // Chat button
                GestureDetector(
                  onTap: () => controller.openChat(req),
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withValues(alpha: 0.1),
                      border: Border.all(color: _gold.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: _gold, size: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────────────────────

  Widget _buildAvatar(String url, {required double size}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.15), blurRadius: 8, spreadRadius: 1)],
      ),
      child: CircleAvatar(
        radius: size,
        backgroundColor: _goldDim,
        child: ClipOval(
          child: url.isEmpty
              ? Icon(Icons.person_rounded, color: Colors.white, size: size)
              : Image.network(
                  url,
                  width: size * 2,
                  height: size * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, e) =>
                      Icon(Icons.person_rounded, color: Colors.white, size: size),
                ),
        ),
      ),
    );
  }

  // ── Role pill ──────────────────────────────────────────────────────────────

  Widget _rolePill(String typeStr) {
    final label = getMembershipTitle(typeStr);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.35.h),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.22)),
      ),
      child: Text(label,
          style: TextStyle(
              color: _gold.withValues(alpha: 0.85),
              fontSize: 8.5.spV2,
              fontWeight: FontWeight.w500)),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return SizedBox(
      height: 35.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.08),
                border: Border.all(color: _gold.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.people_outline_rounded, color: _gold.withValues(alpha: 0.5), size: 30.sp),
            ),
            SizedBox(height: 2.h),
            Text('No connections yet',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white54, fontSize: 13.spV2, fontWeight: FontWeight.w600)),
            SizedBox(height: 1.h),
            Text('Accepted connections will appear here',
                style: TextStyle(color: Colors.white24, fontSize: 9.spV2)),
          ],
        ),
      ),
    );
  }

  // ── Unfriend confirmation ──────────────────────────────────────────────────

  Future<bool?> _confirmUnfriend(BuildContext context, ConnectionProfile req) async {
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Remove Connection?'),
        content: Text('Remove ${req.fullName} from your network?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
