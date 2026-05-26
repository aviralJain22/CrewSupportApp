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
  bool _hasText = false;

  late final List<_Message> _messages = _buildDefaultMessages();

  List<_Message> _buildDefaultMessages() {
    switch (widget.contactId) {
      case 'inv1':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Captain Mitchell here. Saw your profile on CrewSupport — impressive record.', isMe: false, time: '09:12'),
          const _Message(text: 'Thanks, James. Happy to connect. I see you\'re based out of KTEB.', isMe: true, time: '09:14'),
          const _Message(text: 'That\'s right. We have a G650 positioning to KDXB next Wednesday. Looking for a qualified SIC.', isMe: false, time: '09:16'),
          const _Message(text: 'I\'m ATP-rated with 2,400 hours on the G-series. Available from Tuesday.', isMe: true, time: '09:19'),
          const _Message(text: 'Perfect. I\'ll have our ops team send you the trip sheet.', isMe: false, time: '09:21'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Ops confirmed — you\'re on the manifest. Briefing at 0630 local.', isMe: false, time: '07:48'),
          const _Message(text: 'Copy that. Will review the NOTAM package tonight.', isMe: true, time: '07:52'),
          const _Message(text: 'Weather looks clean. Should be a smooth positioning flight.', isMe: false, time: '07:55'),
        ];
      case 'inv2':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Hey — Alexander Reid here. Saw we have a mutual connection in Marcus Webb.', isMe: false, time: '14:05'),
          const _Message(text: 'Marcus mentioned you. Heard you fly the Challenger 350 circuit.', isMe: true, time: '14:08'),
          const _Message(text: 'Yes, mostly KEWR–KMIA–KLAS routes. You looking for a SIC pickup next month?', isMe: false, time: '14:10'),
          const _Message(text: 'Actually yes — we have a 10-day international rotation coming up.', isMe: true, time: '14:13'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Got the itinerary — EGLL, LFPB, LEBL, then back via KSFO. Looks solid.', isMe: false, time: '08:30'),
          const _Message(text: 'Confirmed. I\'ll add you to the crew portal. Check your email.', isMe: true, time: '08:34'),
          const _Message(text: 'Done. See you at the aircraft Thursday, 0545.', isMe: false, time: '08:36'),
        ];
      case 'inv3':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Hi! Isabella Torres — FA based in Miami. Congrats on the G700 qualification!', isMe: false, time: '11:00'),
          const _Message(text: 'Thank you! Tough course but absolutely worth it.', isMe: true, time: '11:03'),
          const _Message(text: 'I\'ve been looking for crew connections on the UHNW charter side.', isMe: false, time: '11:05'),
          const _Message(text: 'This upcoming route has discerning passengers — 8 pax, mixed dietary needs.', isMe: true, time: '11:08'),
          const _Message(text: 'No problem. I\'ll prepare a full catering brief and passenger preference cards.', isMe: false, time: '11:10'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Galley brief complete. Sourcing from DHL Aero provisioning at KDFW.', isMe: false, time: '09:15'),
          const _Message(text: 'Excellent. Confirm with the FBO by 1400 today.', isMe: true, time: '09:18'),
          const _Message(text: 'On it. Kosher and gluten-free options confirmed.', isMe: false, time: '09:20'),
        ];
      case 'inv4':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Daniel Harper — FSDO-approved check airman. Noticed you\'re due for a PC review.', isMe: false, time: '10:22'),
          const _Message(text: 'Yes, coming up in 6 weeks. Would love your sim block availability.', isMe: true, time: '10:25'),
          const _Message(text: 'I have the CAE simulator in Phoenix — 8-hour full-motion blocks. FlightSafety also has openings.', isMe: false, time: '10:28'),
          const _Message(text: 'Let\'s do CAE. I prefer the G550 full-motion block.', isMe: true, time: '10:30'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Simulator booked: June 14th, 0700–1500 MST. Confirmation code CAE-7741.', isMe: false, time: '08:10'),
          const _Message(text: 'Perfect. I\'ll arrange travel. Any study materials to review beforehand?', isMe: true, time: '08:14'),
          const _Message(text: 'Sending the AQP scenario brief this week. Focus on RNP-AR approaches.', isMe: false, time: '08:17'),
        ];
      case 'inv5':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Sophia Lane here. Heard you handled the KEWR ground stop beautifully last month.', isMe: false, time: '15:40'),
          const _Message(text: 'Small world! That was a tricky hold situation. You were at KEWR that day?', isMe: true, time: '15:43'),
          const _Message(text: 'Yes, positioned two gates down. Very sharp airmanship on that fuel burn calc.', isMe: false, time: '15:45'),
          const _Message(text: 'Thanks, Sophia. Always good to connect with experienced crew.', isMe: true, time: '15:47'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Organizing an informal sim prep session next Friday — interested?', isMe: false, time: '10:00'),
          const _Message(text: 'Absolutely. What time and location?', isMe: true, time: '10:03'),
          const _Message(text: '1300 at FlightSafety Denver. Bringing 3 other captains. RSVP by Wednesday.', isMe: false, time: '10:05'),
        ];
      case 'inv6':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Marcus Webb. We flew together on the Dubai rotation last fall — remember?', isMe: false, time: '18:12'),
          const _Message(text: 'Marcus! Of course. That SIGMET diversion to Muscat was unforgettable.', isMe: true, time: '18:15'),
          const _Message(text: 'Ha — truly. Glad we had the extra fuel loaded. How\'s the schedule looking?', isMe: false, time: '18:17'),
          const _Message(text: 'Busy quarter. Taking a Falcon 7X endorsement in August.', isMe: true, time: '18:20'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Nice choice. 7X handles the North Atlantic beautifully. Which school?', isMe: false, time: '09:44'),
          const _Message(text: 'Dassault-approved course at FlightSafety Savannah.', isMe: true, time: '09:47'),
          const _Message(text: 'I know the lead instructor there — top-notch. I\'ll put in a good word.', isMe: false, time: '09:49'),
        ];
      case 'inv7':
        return [
          const _Message(separator: 'Yesterday'),
          const _Message(text: 'Bonsoir! Elise Fontaine — corporate FA, Paris-based, 8 years experience.', isMe: false, time: '20:05'),
          const _Message(text: 'Great to connect, Elise. Your reviews across the network are outstanding.', isMe: true, time: '20:08'),
          const _Message(text: 'Merci. I specialise in UHNW passengers — privacy protocols and formal service.', isMe: false, time: '20:10'),
          const _Message(text: 'We have a Paris–Riyadh–Dubai leg coming up. Interested?', isMe: true, time: '20:12'),
          const _Message(separator: 'Today'),
          const _Message(text: 'Oui, absolutely. I\'ll need the pax manifest and dietary restrictions 48h prior.', isMe: false, time: '08:55'),
          const _Message(text: 'Will coordinate with ops. Departure is June 3rd from LFPG.', isMe: true, time: '08:58'),
          const _Message(text: 'Parfait. I\'ll arrange Ladurée catering and review the security brief.', isMe: false, time: '09:01'),
        ];
      default:
        return [
          const _Message(separator: 'Today'),
          const _Message(text: 'Great to connect with you on CrewSupport!', isMe: false, time: '08:00'),
          const _Message(text: 'Likewise! Looking forward to working together.', isMe: true, time: '08:02'),
        ];
    }
  }

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
      _hasText = false;
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                if (msg.separator != null) return _buildDateSeparator(msg.separator!);
                return _buildBubble(msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: _cardBg,
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
            _buildAvatarWidget(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      if (widget.isOnline) ...[
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3DAA57),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      Text(
                        widget.isOnline ? 'Online now' : widget.contactRole,
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
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined,
                color: Colors.white54, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: Colors.white54, size: 22),
            onPressed: _showOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isOnline
              ? _gold.withValues(alpha: 0.5)
              : _border,
          width: 1.5,
        ),
        color: const Color(0xFF2A2520),
      ),
      child: ClipOval(
        child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
            ? Image.network(
                widget.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, err, st) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        widget.contactName.isNotEmpty
            ? widget.contactName[0].toUpperCase()
            : '?',
        style: GoogleFonts.inter(
            color: _gold, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: _border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _border),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
              ),
            ),
          ),
          Expanded(child: Divider(color: _border)),
        ],
      ),
    );
  }

  Widget _buildBubble(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            _buildSmallAvatar(),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? _gold.withValues(alpha: 0.13)
                      : _cardBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                    bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                  ),
                  border: Border.all(
                    color: msg.isMe
                        ? _gold.withValues(alpha: 0.28)
                        : _border,
                  ),
                ),
                child: Text(
                  msg.text ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.time ?? '',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.white38),
                  ),
                  if (msg.isMe) ...[
                    const SizedBox(width: 3),
                    const Icon(Icons.done_all_rounded,
                        size: 13, color: Color(0xFFD4AF37)),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    return Container(
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
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.attach_file_rounded,
                  color: Color(0xFFD4AF37), size: 17),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      onChanged: (v) =>
                          setState(() => _hasText = v.trim().isNotEmpty),
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
                  if (!_hasText)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(0, 0, 12, 12),
                      child: Icon(Icons.mic_none_rounded,
                          color: Colors.white38, size: 20),
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _hasText ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasText ? _gold : const Color(0xFF2A2520),
                shape: BoxShape.circle,
                boxShadow: _hasText
                    ? [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 18,
                color: _hasText ? const Color(0xFF0C0A08) : Colors.white24,
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
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _optionTile(Icons.person_outline_rounded, 'View Profile',
                () => Navigator.pop(context)),
            _optionTile(Icons.bookmark_border_rounded, 'Save to Favourites',
                () => Navigator.pop(context)),
            _optionTile(Icons.block_rounded, 'Block User',
                () => Navigator.pop(context),
                isDestructive: true),
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
    final color =
        isDestructive ? const Color(0xFFB33A3A) : Colors.white70;
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label,
          style: GoogleFonts.inter(fontSize: 14, color: color)),
      onTap: onTap,
    );
  }
}

class _Message {
  const _Message({
    this.text,
    this.isMe = false,
    this.time,
    this.separator,
  });

  final String? text;
  final bool isMe;
  final String? time;
  final String? separator;
}
