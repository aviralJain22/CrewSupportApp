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

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: _bg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: variant == AppHeaderVariant.greeting
            ? _buildGreeting()
            : _buildTitle(context),
      ),
    );
  }

  Widget _buildGreeting() {
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
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              Text(
                name ?? 'Aviator',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _bellButton,
        const SizedBox(width: 10),
        _avatarButton,
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A2520), width: 1),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title ?? '',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget get _bellButton {
    return GestureDetector(
      onTap: onNotificationTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
              border:
                  Border.all(color: const Color(0xFF2A2520), width: 1),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
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

  Widget get _avatarButton {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 38,
        height: 38,
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
