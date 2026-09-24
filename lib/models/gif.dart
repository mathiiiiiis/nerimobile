class GifCategory {
  final String searchTerm;
  final String image;

  GifCategory({required this.searchTerm, required this.image});

  factory GifCategory.fromJson(Map<String, dynamic> json) => GifCategory(
    searchTerm: json['searchterm'] as String,
    image: json['image'] as String,
  );
}
