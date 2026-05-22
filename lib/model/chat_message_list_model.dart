class MessageData {
  List<Messages>? messages;

  MessageData({this.messages});
}

class Messages {
  String? conversationId;
  String? otherUserId; // Kept for legacy compatibility with existing UI/navigation code.
  int? otherProfileType;
  String? receivername;
  String? message;
  int? isUnReadCount;
  String? photoPath;
  DateTime? lastMessageAt;
  bool? isGroup;

  Messages({
    this.conversationId,
    this.otherUserId,
    this.otherProfileType,
    this.receivername,
    this.message,
    this.isUnReadCount,
    this.photoPath,
    this.lastMessageAt,
    this.isGroup,
  });
}