class Pin {
  const Pin({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.authorAvatar,
    required this.category,
    required this.aspectRatio,
    required this.isVideo,
    this.description = '',
    this.videoUrl,
  });

  final String id;
  final String imageUrl;
  final String title;
  final String author;
  final String authorAvatar;
  final String category;
  final double aspectRatio;
  final bool isVideo;
  final String description;
  final String? videoUrl;

  Pin copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? author,
    String? authorAvatar,
    String? category,
    double? aspectRatio,
    bool? isVideo,
    String? videoUrl,
  }) {
    return Pin(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      category: category ?? this.category,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isVideo: isVideo ?? this.isVideo,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
