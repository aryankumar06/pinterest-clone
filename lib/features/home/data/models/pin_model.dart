import '../../domain/entities/pin.dart';

class PinModel extends Pin {
  const PinModel({
    required super.id,
    required super.imageUrl,
    required super.title,
    required super.author,
    required super.authorAvatar,
    required super.category,
    required super.aspectRatio,
    required super.isVideo,
    super.videoUrl,
  });

  factory PinModel.fromPhotoJson(Map<String, dynamic> json, String category) {
    final width = (json['width'] as num?)?.toDouble() ?? 1000.0;
    final height = (json['height'] as num?)?.toDouble() ?? 1000.0;
    final aspectRatio = height > 0 ? width / height : 1.0;

    return PinModel(
      id: json['id'].toString(),
      imageUrl: json['src']?['large2x'] ?? json['src']?['large'] ?? '',
      title: json['alt'] ?? 'Untitled Pin',
      author: json['photographer'] ?? 'Unknown Author',
      authorAvatar: json['photographer_url'] ?? '',
      category: category,
      aspectRatio: aspectRatio,
      isVideo: false,
    );
  }

  factory PinModel.fromVideoJson(Map<String, dynamic> json, String category) {
    final width = (json['width'] as num?)?.toDouble() ?? 1000.0;
    final height = (json['height'] as num?)?.toDouble() ?? 1000.0;
    final aspectRatio = height > 0 ? (width / height) : 1.0;
    
    // Find the best video link (preferably HD or SD)
    final List<dynamic> videoFiles = json['video_files'] ?? [];
    String? bestVideoUrl;
    if (videoFiles.isNotEmpty) {
      bestVideoUrl = videoFiles.first['link'];
    }

    return PinModel(
      id: json['id'].toString(),
      imageUrl: json['image'] ?? '',
      title: json['url'] ?? 'Video Pin',
      author: json['user']?['name'] ?? 'Unknown Author',
      authorAvatar: json['user']?['url'] ?? '',
      category: category,
      aspectRatio: aspectRatio,
      isVideo: true,
      videoUrl: bestVideoUrl,
    );
  }

  factory PinModel.fromJson(Map<String, dynamic> json) {
    // For local hive caching support
    return PinModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      authorAvatar: json['author_avatar'] as String,
      category: json['category'] as String,
      aspectRatio: (json['aspect_ratio'] as num).toDouble(),
      isVideo: json['is_video'] as bool,
      videoUrl: json['video_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'author': author,
      'author_avatar': authorAvatar,
      'category': category,
      'aspect_ratio': aspectRatio,
      'is_video': isVideo,
      'video_url': videoUrl,
    };
  }
}
