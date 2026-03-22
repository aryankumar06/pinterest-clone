import '../../domain/entities/photo_source.dart';

/// Data transfer object for [PhotoSource] with JSON serialization.
class PhotoSourceModel extends PhotoSource {
  const PhotoSourceModel({
    required super.original,
    required super.large2x,
    required super.large,
    required super.medium,
    required super.small,
    required super.portrait,
    required super.landscape,
    required super.tiny,
  });

  factory PhotoSourceModel.fromJson(Map<String, dynamic> json) {
    return PhotoSourceModel(
      original: json['original'] as String? ?? '',
      large2x: json['large2x'] as String? ?? '',
      large: json['large'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      small: json['small'] as String? ?? '',
      portrait: json['portrait'] as String? ?? '',
      landscape: json['landscape'] as String? ?? '',
      tiny: json['tiny'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'large2x': large2x,
      'large': large,
      'medium': medium,
      'small': small,
      'portrait': portrait,
      'landscape': landscape,
      'tiny': tiny,
    };
  }
}
