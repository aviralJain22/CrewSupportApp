import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactName,
    required this.contactRole,
    this.avatarUrl,
    this.isOnline = false,
  });

  final String contactId;
  final String contactName;
  final String contactRole;
  final String? avatarUrl;
  final bool isOnline;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _bg = Color(0xFF0C0A08);
  static const _gold = Color(0xFFD4AF37);
  static const _cardBg = Color(0xFF181410);
  static const _border = Color(0xFF2A2520);

  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [
    _Message(text: 'Hi! I saw your profile — impressive hours.', isMe: false, time: '14:02'),
    _Message(text: 'Thank you! Happy to help if you have a trip coming up.', isMe: true, time: '14:04'),
    _Message(text: 'Yes, we have a transatlantic run on the 28th. Are you available?', isMe: false, time: '14:05'),
    _Message(text: 'Let me check my availability — one moment.', isMe: true, time: '14:06'),
    _Message(text: 'The 28th works for me. What aircraft?', isMe: true, time: '14:08'),
    _Message(text: 'Gulfstream G650. Departure KTEB, arrival EGLL.', isMe: false, time: '14:09'),
  ];

  bool get _canSend => _msgCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMe: true, time: _nowTime));
      _msgCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _nowTime {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _chatAppBar,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          _inputBar,
        ],
      ),
    );
  }

  PreferredSizeWidget get _chatAppBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: _border, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            _avatar,
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.contactName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.isOnline ? 'Online' : widget.contactRole,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: widget.isOnline
                        ? const Color(0xFF3DAA57)
                        : Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: Colors.white54, size: 22),
            onPressed: _showOptions,
          ),
        ],
      ),
    );
  }

  Widget get _avatar {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _border),
        color: const Color(0xFF2A2520),
      ),
      child: ClipOval(
        child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
            ? Image.network(
                widget.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, err, st) => _initials,
              )
            : _initials,
      ),
    );
  }

  Widget get _initials => Center(
        child: Text(
          widget.contactName.isNotEmpty
              ? widget.contactName[0].toUpperCase()
              : '?',
          style: GoogleFonts.inter(
            color: _gold,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );

  Widget _buildBubble(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            _smallAvatar,
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: msg.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? _gold.withValues(alpha: 0.14)
                      : _cardBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                    bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                  ),
                  border: Border.all(
                    color: msg.isMe
                        ? _gold.withValues(alpha: 0.25)
                        : _border,
                  ),
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                msg.time,
                style: GoogleFonts.inter(
                    fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _smallAvatar => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2520),
          border: Border.all(color: _border),
        ),
        child: ClipOval(
          child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
              ? Image.network(
                  widget.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, err, st) => Center(
                    child: Text(
                      widget.contactName.isNotEmpty
                          ? widget.contactName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.inter(
                          color: _gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 11),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    widget.contactName.isNotEmpty
                        ? widget.contactName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                        color: _gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                  ),
                ),
        ),
      );

  Widget get _inputBar {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.white),
                      cursorColor: _gold,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message…',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14, color: Colors.white38),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _canSend ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _canSend ? _gold : const Color(0xFF2A2520),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 18,
                color: _canSend
                    ? const Color(0xFF0C0A08)
                    : Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181410),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _optionTile(Icons.person_outline_rounded, 'View Profile', () {
              Navigator.pop(context);
            }),
            _optionTile(Icons.bookmark_border_rounded, 'Save to Favourites', () {
              Navigator.pop(context);
            }),
            _optionTile(Icons.block_rounded, 'Block User', () {
              Navigator.pop(context);
            }, isDestructive: true),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFB33A3A) : Colors.white70;
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 14, color: color),
      ),
      onTap: onTap,
    );
  }
}

class _Message {
  const _Message({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;
}
