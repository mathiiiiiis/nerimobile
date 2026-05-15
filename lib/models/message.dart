import 'package:nerimobile/models/user.dart';

class Message {
  final String id;
  final String content;
  final String channelId;
  final User createdBy;
  final List<User> mentions;
  final List<Attachment> attachments;
  final int createdAt;
  final Embed? embed;
  final List<ReplyMessage> replyMessages;

  Message({
    required this.id,
    required this.content,
    required this.channelId,
    required this.createdBy,
    required this.attachments,
    required this.createdAt,
    this.embed,
    this.mentions = const [],
    this.replyMessages = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    content: json['content'],
    channelId: json['channelId'],
    createdAt: json['createdAt'] as int,
    createdBy: User.fromJson(json['createdBy']),
    mentions: (json['mentions'] as List).map((m) => User.fromJson(m)).toList(),
    embed: json['embed'] != null ? Embed.fromJson(json['embed']) : null,
    attachments: (json['attachments'] as List)
        .map((a) => Attachment.fromJson(a))
        .toList(),
    replyMessages: (json['replyMessages'] as List? ?? [])
        .map((r) => ReplyMessage.fromJson(r))
        .toList(),
  );

  Message copyWith(Map<String, dynamic> partial) {
    return Message(
      id: id,
      content: partial["content"] ?? content,
      channelId: channelId,
      createdBy: createdBy,
      mentions: mentions,
      attachments: attachments,
      createdAt: createdAt,
      embed: partial.containsKey("embed")
          ? (partial["embed"] != null ? Embed.fromJson(partial["embed"]) : null)
          : embed,
      replyMessages: replyMessages,
    );
  }
}

class Attachment {
  final String id;
  final String? path;

  final String? mime;
  final int? width;
  final int? height;

  Attachment({required this.id, this.path, this.mime, this.width, this.height});

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json['id'],
    path: json['path'] as String?,
    mime: json['mime'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
  );
}

enum EmbedType { image }

class Embed {
  final String? type;
  final bool? animated;
  final String? imageMime;
  final int? imageWidth;
  final int? imageHeight;
  final String? imageUrl;
  final String? domain;

  Embed({
    this.type,
    this.domain,

    this.animated,
    this.imageWidth,
    this.imageHeight,
    this.imageMime,
    this.imageUrl,
  });

  factory Embed.fromJson(Map<String, dynamic> json) => Embed(
    type: json['type'] as String?,
    animated: json['animated'] as bool?,
    imageWidth: json['imageWidth'] == null
        ? null
        : int.tryParse(json['imageWidth'].toString()),
    imageHeight: json['imageHeight'] == null
        ? null
        : int.tryParse(json['imageHeight'].toString()),
    imageMime: json['imageMime'] as String?,
    imageUrl: json['imageUrl'] as String?,
    domain: json['domain'] as String?,
  );
}

class ReplyMessage {
  final PartialMessage? replyToMessage;

  ReplyMessage({this.replyToMessage});

  factory ReplyMessage.fromJson(Map<String, dynamic> json) => ReplyMessage(
    replyToMessage: json['replyToMessage'] != null
        ? PartialMessage.fromJson(json['replyToMessage'])
        : null,
  );
}

// used for replies
class PartialMessage {
  final String id;
  final String content;
  final int createdAt;
  final User createdBy;
  final List<Attachment> attachments;

  PartialMessage({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    required this.attachments,
  });

  factory PartialMessage.fromJson(Map<String, dynamic> json) => PartialMessage(
    id: json['id'],
    content: json['content'],
    createdAt: json['createdAt'] as int,
    createdBy: User.fromJson(json['createdBy']),
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => Attachment.fromJson(a))
        .toList(),
  );
}
