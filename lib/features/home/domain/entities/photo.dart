import 'photo_source.dart';

/// Core domain entity representing a photo/pin.
class Photo {
  const Photo({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.photographer,
    required this.photographerUrl,
    required this.photographerId,
    required this.avgColor,
    required this.src,
    this.alt = '',
    this.liked = false,
  });

  final int id;
  final int width;
  final int height;
  final String url;
  final String photographer;
  final String photographerUrl;
  final int photographerId;
  final String avgColor;
  final PhotoSource src;
  final String alt;
  final bool liked;

  /// Aspect ratio for layout calculations.
  double get aspectRatio => width / height;
}
