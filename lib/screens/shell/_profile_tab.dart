import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../services/user_session.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildMenuSection('ACCOUNT', [
                _MenuItem(Icons.person_outline_rounded, 'My Profile',
                    () => Get.toNamed(AppRoutes.pilotProfileNew)),
                _MenuItem(Icons.edit_calendar_outlined, 'Availability',
                    () => Get.toNamed(AppRoutes.manageAvailability)),
                _MenuItem(Icons.bookmark_border_rounded, 'Favourites',
                    () => Get.toNamed(AppRoutes.favourites)),
                _MenuItem(Icons.star_border_rounded, 'My Ratings', () {}),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection('SETTINGS', [
                _MenuItem(Icons.notifications_none_rounded, 'Notifications', () {}),
                _MenuItem(Icons.security_outlined, 'Privacy & Security', () {}),
                _MenuItem(Icons.help_outline_rounded, 'Help & Support',
                    () => Get.toNamed(AppRoutes.help)),
                _MenuItem(Icons.logout_rounded, 'Sign Out', _signOut,
                    isDestructive: true),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: 0.5), width: 2),
              color: const Color(0xFF2A2520),
            ),
            child: Center(
              child: Text(
                UserSession.instance.initials,
                style: GoogleFonts.inter(
                  color: _gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserSession.instance.displayName,
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: _gold.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        UserSession.instance.role,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.pilotProfileNew),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: Color(0xFFD4AF37), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard('12', 'Trips'),
          const SizedBox(width: 10),
          _buildStatCard('48', 'Connections'),
          const SizedBox(width: 10),
          _buildStatCard('4.9', 'Rating'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _gold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: _gold.withValues(alpha: 0.6),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    _buildMenuTile(item),
                    if (!isLast) Divider(color: _border, height: 1, indent: 52),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    final color = item.isDestructive
        ? const Color(0xFFB33A3A)
        : Colors.white70;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? const Color(0xFFB33A3A).withValues(alpha: 0.1)
                    : _gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 16, color: item.isDestructive ? const Color(0xFFB33A3A) : _gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: item.isDestructive
                    ? const Color(0xFFB33A3A).withValues(alpha: 0.5)
                    : Colors.white24,
                size: 18),
          ],
        ),
      ),
    );
  }

  void _signOut() {
    Get.offAllNamed(AppRoutes.loginNew);
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.onTap,
      {this.isDestructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}
