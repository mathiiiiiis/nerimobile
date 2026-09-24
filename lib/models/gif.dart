class GifCategory {
  final String searchTerm;
  final String image;

  GifCategory({required this.searchTerm, required this.image});

  factory GifCategory.fromJson(Map<String, dynamic> json) => GifCategory(
    searchTerm: json['searchterm'] as String,
    image: json['image'] as String,
  );
}

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

  double get ratio {
    final width = previewWidth ?? 0;
    final height = previewHeight ?? 0;
    return width > 0 && height > 0 ? width / height : 1;
  }
}

typedef GifPage = ({List<Gif> gifs, String? next});

typedef GifResults = ({List<Gif> gifs, String? next, bool loadingMore});
