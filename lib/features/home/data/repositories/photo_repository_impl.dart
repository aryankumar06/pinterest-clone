import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/photo_local_datasource.dart';
import '../datasources/photo_remote_datasource.dart';

/// Concrete implementation of [PhotoRepository].
/// Fetches from remote and falls back to cache on failure.
class PhotoRepositoryImpl implements PhotoRepository {
  const PhotoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final PhotoRemoteDataSource remoteDataSource;
  final PhotoLocalDataSource localDataSource;

  @override
  Future<List<Photo>> getCuratedPhotos({
    required int page,
    required int perPage,
  }) async {
    try {
      final photos = await remoteDataSource.getCuratedPhotos(
        page: page,
        perPage: perPage,
      );

      // Cache the results
      localDataSource.cachePhotos('curated_$page', photos);

      return photos;
    } on DioException catch (e) {
      // Try cache fallback for first page
      if (page == 1) {
        final cached = localDataSource.getCachedPhotos('curated_1');
        if (cached != null && cached.isNotEmpty) return cached;
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkFailure();
      }
      throw ServerFailure(e.message ?? 'Failed to fetch curated photos');
    }
  }

  @override
  Future<List<Photo>> searchPhotos({
    required String query,
    required int page,
    required int perPage,
  }) async {
    try {
      final photos = await remoteDataSource.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
      );
      return photos;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkFailure();
      }
      throw ServerFailure(e.message ?? 'Failed to search photos');
    }
  }

  @override
  Future<Photo> getPhotoById(int id) async {
    try {
      return await remoteDataSource.getPhotoById(id);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkFailure();
      }
      throw ServerFailure(e.message ?? 'Failed to fetch photo');
    }
  }
}
