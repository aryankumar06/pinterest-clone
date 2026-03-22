import '../entities/photo.dart';

/// Abstract repository contract for photo operations.
/// The data layer provides the concrete implementation.
abstract class PhotoRepository {
  /// Fetch curated photos (home feed).
  Future<List<Photo>> getCuratedPhotos({
    required int page,
    required int perPage,
  });

  /// Search photos by query.
  Future<List<Photo>> searchPhotos({
    required String query,
    required int page,
    required int perPage,
  });

  /// Get a single photo by ID.
  Future<Photo> getPhotoById(int id);
}
