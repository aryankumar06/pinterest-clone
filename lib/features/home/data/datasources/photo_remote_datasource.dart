import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/photo_model.dart';

/// Remote data source for fetching photos from the Pexels API.
class PhotoRemoteDataSource {
  PhotoRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Fetch curated photos.
  Future<List<PhotoModel>> getCuratedPhotos({
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.curated,
      queryParameters: {'page': page, 'per_page': perPage},
    );

    final data = response.data as Map<String, dynamic>;
    final photos = (data['photos'] as List<dynamic>?) ?? [];

    return photos
        .map((json) => PhotoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search photos by query.
  Future<List<PhotoModel>> searchPhotos({
    required String query,
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.search,
      queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final photos = (data['photos'] as List<dynamic>?) ?? [];

    return photos
        .map((json) => PhotoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single photo by ID.
  Future<PhotoModel> getPhotoById(int id) async {
    final response = await _dio.get(ApiEndpoints.photo(id));
    return PhotoModel.fromJson(response.data as Map<String, dynamic>);
  }
}
