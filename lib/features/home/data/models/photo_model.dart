import '../../domain/entities/photo.dart';
import 'photo_source_model.dart';

/// Data transfer object for [Photo] with JSON serialization.
class PhotoModel extends Photo {
  const PhotoModel({
    required super.id,
    required super.width,
    required super.height,
    required super.url,
    required super.photographer,
    required super.photographerUrl,
    required super.photographerId,
    required super.avgColor,
    required PhotoSourceModel src,
    super.alt,
    super.liked,
  }) : super(src: src);

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as int? ?? 0,
      width: json['width'] as int? ?? 1,
      height: json['height'] as int? ?? 1,
      url: json['url'] as String? ?? '',
      photographer: json['photographer'] as String? ?? 'Unknown',
      photographerUrl: json['photographer_url'] as String? ?? '',
      photographerId: json['photographer_id'] as int? ?? 0,
      avgColor: json['avg_color'] as String? ?? '#CCCCCC',
      src: PhotoSourceModel.fromJson(
        json['src'] as Map<String, dynamic>? ?? {},
      ),
      alt: json['alt'] as String? ?? '',
      liked: json['liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'url': url,
      'photographer': photographer,
      'photographer_url': photographerUrl,
      'photographer_id': photographerId,
      'avg_color': avgColor,
      'src': (src as PhotoSourceModel).toJson(),
      'alt': alt,
      'liked': liked,
    };
  }
}
