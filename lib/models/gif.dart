class GifCategory {
  final String searchTerm;
  final String image;

  GifCategory({required this.searchTerm, required this.image});

  factory GifCategory.fromJson(Map<String, dynamic> json) => GifCategory(
    searchTerm: json['searchterm'] as String,
    image: json['image'] as String,
  );
}

enum GifSource { klipy, cdn, other }

double gifRatio(int? width, int? height) =>
    (width ?? 0) > 0 && (height ?? 0) > 0 ? width! / height! : 1;

class Gif {
  final String url;
  final String gifUrl;
  final String previewUrl;
  final int? previewWidth;
  final int? previewHeight;

  Gif({
    required this.url,
    required this.gifUrl,
    required this.previewUrl,
    this.previewWidth,
    this.previewHeight,
  });

  factory Gif.fromJson(Map<String, dynamic> json) => Gif(
    url: json['url'] as String,
    gifUrl: json['gifUrl'] as String,
    previewUrl: json['previewUrl'] as String,
    previewWidth: json['previewWidth'] as int?,
    previewHeight: json['previewHeight'] as int?,
  );

  double get ratio => gifRatio(previewWidth, previewHeight);
}

class FavoriteGif {
  final String url;
  final String previewUrl;
  final int? previewWidth;
  final int? previewHeight;
  final GifSource source;
  final int savedAt;

  FavoriteGif({
    required this.url,
    required this.previewUrl,
    required this.source,
    required this.savedAt,
    this.previewWidth,
    this.previewHeight,
  });

  factory FavoriteGif.of(Gif gif, GifSource source) => FavoriteGif(
    url: gif.gifUrl,
    previewUrl: gif.previewUrl,
    previewWidth: gif.previewWidth,
    previewHeight: gif.previewHeight,
    source: source,
    savedAt: DateTime.now().millisecondsSinceEpoch,
  );

  double get ratio => gifRatio(previewWidth, previewHeight);
}

typedef GifPage = ({List<Gif> gifs, String? next});

typedef GifResults = ({List<Gif> gifs, String? next, bool loadingMore});
