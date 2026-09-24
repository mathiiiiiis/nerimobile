class CustomEmoji {
  final String id;
  final String name;
  final String serverId;
  final bool gif;
  final bool webp;

  CustomEmoji({
    required this.id,
    required this.name,
    required this.serverId,
    this.gif = false,
    this.webp = false,
  });

  factory CustomEmoji.fromJson(Map<String, dynamic> json, String serverId) =>
      CustomEmoji(
        id: json['id'],
        name: json['name'],
        serverId: serverId,
        gif: json['gif'] ?? false,
        webp: json['webp'] ?? false,
      );

  //maps formats to markup types
  String get type => gif ? (webp ? 'wace' : 'ace') : 'ce';

  CustomEmoji renamed(String name) =>
      CustomEmoji(id: id, name: name, serverId: serverId, gif: gif, webp: webp);
}
