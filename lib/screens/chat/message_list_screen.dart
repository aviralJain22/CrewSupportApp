import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/crew_connection_state.dart';
import 'chat_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Messages',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _gold.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Color(0xFFD4AF37), size: 17),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: _border, height: 1),
        ),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<List<CrewConvo>>(
            valueListenable: CrewConnectionState.instance.conversations,
            builder: (_, convos, child) {
              final unread = convos.where((c) => c.unread > 0).length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    unread > 0
                        ? '$unread unread · ${convos.length} conversations'
                        : '${convos.length} conversations',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white38),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: ValueListenableBuilder<List<CrewConvo>>(
              valueListenable: CrewConnectionState.instance.conversations,
              builder: (context, convos, _) {
                final filtered = _query.isEmpty
                    ? convos
                    : convos
                        .where((c) =>
                            c.name
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            c.preview
                                .toLowerCase()
                                .contains(_query.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) return _buildEmptyState();
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  separatorBuilder: (_, idx) =>
                      Divider(color: _border, height: 1, indent: 86),
                  itemBuilder: (ctx, i) =>
                      _buildConvoTile(ctx, filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Colors.white38, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              cursorColor: _gold,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search messages…',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.close_rounded, color: Colors.white38, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConvoTile(BuildContext context, CrewConvo convo) {
    final hasUnread = convo.unread > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            contactId: convo.id,
            contactName: convo.name,
            contactRole: convo.role,
            avatarUrl: convo.avatarUrl.isEmpty ? null : convo.avatarUrl,
            isOnline: convo.isOnline,
          ),
        ),
      ),
      child: Container(
        color: hasUnread ? _gold.withValues(alpha: 0.025) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            _buildAvatar(convo),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        convo.time,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: hasUnread ? _gold : Colors.white38,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    convo.role,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: hasUnread ? Colors.white70 : Colors.white38,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${convo.unread}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0C0A08),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(CrewConvo convo) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: convo.isOnline
                  ? _gold.withValues(alpha: 0.45)
                  : _border,
              width: 1.5,
            ),
            color: const Color(0xFF2A2520),
          ),
          child: ClipOval(
            child: convo.avatarUrl.isNotEmpty
                ? Image.network(
                    convo.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, err, st) => _buildInitial(convo.name),
                  )
                : _buildInitial(convo.name),
          ),
        ),
        if (convo.isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA57),
                shape: BoxShape.circle,
                border: Border.all(color: _bg, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.inter(
          color: _gold,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: 0.14)),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Color(0xFFD4AF37), size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'No Messages Yet',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accept a connection to start chatting\nwith crew members.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
