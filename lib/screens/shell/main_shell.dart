import 'package:flutter/material.dart';
import '../../features/dashboard/premium_dashboard_screen.dart';
import '../../screens/social/connections_screen.dart';
import '../../screens/notifications/notification_screen.dart';
import '../../screens/chat/message_list_screen.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../services/crew_connection_state.dart';
import '_profile_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PremiumDashboardScreen(),
    ConnectionsScreen(),
    ProfileTab(),
    NotificationScreen(),
    MessageListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CrewConnectionState.instance.conversations,
      builder: (_, convos, child) {
        final unreadMessages = convos.fold(0, (sum, c) => sum + c.unread);
        return Scaffold(
          backgroundColor: const Color(0xFF0C0A08),
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            messageBadge: unreadMessages,
          ),
        );
      },
    );
  }
}
