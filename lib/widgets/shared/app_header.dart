import 'package:crew_support/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppHeaderVariant { greeting, title }

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader.greeting({
    super.key,
    required this.name,
    this.avatarUrl,
    this.onAvatarTap,
    this.onNotificationTap,
    this.unreadCount = 0,
  })  : variant = AppHeaderVariant.greeting,
        title = null,
        onBack = null;

  const AppHeader.title({
    super.key,
    required String screenTitle,
    this.onBack,
  })  : variant = AppHeaderVariant.title,
        title = screenTitle,
        name = null,
        avatarUrl = null,
        onAvatarTap = null,
        onNotificationTap = null,
        unreadCount = 0;

  final AppHeaderVariant variant;
  final String? name;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final int unreadCount;
  final String? title;
  final VoidCallback? onBack;

  static const _gold = Color(0xFFD4AF37);
  static const _bg = Color(0xFF0C0A08);
  static const _cardBg = Color(0xFF181410);

  /// Fixed at the standard medium-tier value.
  /// The actual container height inside build() is driven by AppSpacing.headerH(context).
  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    final h = AppSpacing.headerH(context);
    final hPad = AppSpacing.screenH(context);
    final iconBtn = AppSpacing.avatarSm(context) + 2;
    final iconInner = AppSpacing.iconMd(context);
    final badgeSize = AppSpacing.iconSm(context) + 2;
    final btnGap = AppSpacing.sm(context);
    final backGap = AppSpacing.md(context);

    return Container(
      height: h,
      color: _bg,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: SafeArea(
        bottom: false,
        child: variant == AppHeaderVariant.greeting
            ? _buildGreeting(context, iconBtn, iconInner, badgeSize, btnGap)
            : _buildTitle(context, iconBtn, iconInner, backGap),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, double iconBtn, double iconInner,
      double badgeSize, double btnGap) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
              ),
              Text(
                name ?? 'Aviator',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _bellButton(iconBtn, iconInner, badgeSize),
        SizedBox(width: btnGap),
        _avatarButton(iconBtn),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, double iconBtn, double iconInner,
      double backGap) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            width: iconBtn,
            height: iconBtn,
            decoration: BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A2520), width: 1),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: iconInner - 4,
            ),
          ),
        ),
        SizedBox(width: backGap),
        Text(
          title ?? "",
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _bellButton(double size, double iconInner, double badgeSize) {
    return GestureDetector(
      onTap: onNotificationTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A2520), width: 1),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white70,
              size: iconInner,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: const BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C0A08),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarButton(double size) {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _gold, width: 1.5),
          color: const Color(0xFF2A2520),
        ),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, err, st) => _initialFallback,
                )
              : _initialFallback,
        ),
      ),
    );
  }

  Widget get _initialFallback => Center(
        child: Text(
          name != null && name!.isNotEmpty ? name![0].toUpperCase() : 'A',
          style: GoogleFonts.inter(
            color: _gold,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
}
