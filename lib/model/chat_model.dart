class ChatModel {
  final String objectId;
  final String myMsgId;
  final String Message;
  final String SenderId;
  final bool IsRead;
  final bool IsReceive;
  final DateTime? EntryDate;
  final bool IsSend;
  final bool MessageType;
  final String TextWithImg;
  final String OppositeId;
  final bool IsDelete;

  /// URL of the uploaded attachment, when this message contains any attachment.
  final String AttachmentUrl;

  /// Original file name of the attachment, when available.
  final String AttachmentName;

  /// True only for image attachments that should render as image preview bubbles.
  final bool IsImageAttachment;

  ChatModel({
    required this.objectId,
    required this.myMsgId,
    required this.Message,
    required this.SenderId,
    required this.IsRead,
    required this.IsReceive,
    required this.EntryDate,
    required this.IsSend,
    required this.MessageType,
    required this.TextWithImg,
    required this.OppositeId,
    required this.IsDelete,
    this.AttachmentUrl = '',
    this.AttachmentName = '',
    this.IsImageAttachment = false,
  });

  ChatModel copyWith({
    String? objectId,
    String? myMsgId,
    String? Message,
    String? SenderId,
    bool? IsRead,
    bool? IsReceive,
    DateTime? EntryDate,
    bool? IsSend,
    bool? MessageType,
    String? TextWithImg,
    String? OppositeId,
    bool? IsDelete,
    String? AttachmentUrl,
    String? AttachmentName,
    bool? IsImageAttachment,
  }) {
    return ChatModel(
      objectId: objectId ?? this.objectId,
      myMsgId: myMsgId ?? this.myMsgId,
      Message: Message ?? this.Message,
      SenderId: SenderId ?? this.SenderId,
      IsRead: IsRead ?? this.IsRead,
      IsReceive: IsReceive ?? this.IsReceive,
      EntryDate: EntryDate ?? this.EntryDate,
      IsSend: IsSend ?? this.IsSend,
      MessageType: MessageType ?? this.MessageType,
      TextWithImg: TextWithImg ?? this.TextWithImg,
      OppositeId: OppositeId ?? this.OppositeId,
      IsDelete: IsDelete ?? this.IsDelete,
      AttachmentUrl: AttachmentUrl ?? this.AttachmentUrl,
      AttachmentName: AttachmentName ?? this.AttachmentName,
      IsImageAttachment: IsImageAttachment ?? this.IsImageAttachment,
    );
  }
}