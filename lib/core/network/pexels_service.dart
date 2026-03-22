import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/home/data/models/pin_model.dart';
import '../constants/app_constants.dart';
import '../error/failures.dart';

class PexelsService {
  const PexelsService();

  Future<List<PinModel>> fetchPins(String query, int page, {bool isVideo = false}) async {
    final endpoint = isVideo ? '/videos/search' : '/search';
    final url = Uri.parse(
      '${AppConstants.pexelsBaseUrl}$endpoint?query=$query&page=$page&per_page=${AppConstants.itemsPerPage}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': AppConstants.pexelsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data[isVideo ? 'videos' : 'photos'] ?? [];

        return items.map((json) {
          if (isVideo) {
            return PinModel.fromVideoJson(json, query);
          } else {
            return PinModel.fromPhotoJson(json, query);
          }
        }).toList();
      } else {
        throw ServerFailure('Pexels API error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch from Pexels: $e');
    }
  }

  Future<PinModel> fetchPinById(String id, {bool isVideo = false}) async {
    final endpoint = isVideo ? '/videos/videos' : '/photos';
    final url = Uri.parse('${AppConstants.pexelsBaseUrl}$endpoint/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': AppConstants.pexelsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (isVideo) {
          return PinModel.fromVideoJson(data, 'Unknown');
        } else {
          return PinModel.fromPhotoJson(data, 'Unknown');
        }
      } else {
        throw ServerFailure('Pexels API error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Failed to fetch from Pexels: $e');
    }
  }
}
