import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

/// Use case: Fetch curated photos for the home feed.
class GetCuratedPhotos {
  const GetCuratedPhotos(this._repository);

  final PhotoRepository _repository;

  Future<List<Photo>> call({
    required int page,
    required int perPage,
  }) {
    return _repository.getCuratedPhotos(page: page, perPage: perPage);
  }
}
