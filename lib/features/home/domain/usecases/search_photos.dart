import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

/// Use case: Search photos by query string.
class SearchPhotos {
  const SearchPhotos(this._repository);

  final PhotoRepository _repository;

  Future<List<Photo>> call({
    required String query,
    required int page,
    required int perPage,
  }) {
    return _repository.searchPhotos(
      query: query,
      page: page,
      perPage: perPage,
    );
  }
}
