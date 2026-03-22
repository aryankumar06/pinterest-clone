import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/photo_model.dart';

/// Local data source for caching photos using Hive.
class PhotoLocalDataSource {
  static const String _boxName = 'photos_cache';
  static const String _bookmarksBoxName = 'bookmarks';

  Box<String>? _cacheBox;
  Box<String>? _bookmarksBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(_boxName);
    _bookmarksBox = await Hive.openBox<String>(_bookmarksBoxName);
  }

  // ── Feed Cache ──────────────────────────────────────────────────────────

  /// Cache a list of photos for a given key (e.g. "curated_1").
  Future<void> cachePhotos(String key, List<PhotoModel> photos) async {
    final jsonList = photos.map((p) => jsonEncode(p.toJson())).toList();
    await _cacheBox?.put(key, jsonEncode(jsonList));
  }

  /// Retrieve cached photos for a given key.
  List<PhotoModel>? getCachedPhotos(String key) {
    final raw = _cacheBox?.get(key);
    if (raw == null) return null;

    final jsonList = (jsonDecode(raw) as List<dynamic>).cast<String>();
    return jsonList
        .map((s) => PhotoModel.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ))
        .toList();
  }

  // ── Bookmarks ───────────────────────────────────────────────────────────

  /// Save a photo to bookmarks.
  Future<void> bookmarkPhoto(PhotoModel photo) async {
    await _bookmarksBox?.put(
      photo.id.toString(),
      jsonEncode(photo.toJson()),
    );
  }

  /// Remove a photo from bookmarks.
  Future<void> unbookmarkPhoto(int photoId) async {
    await _bookmarksBox?.delete(photoId.toString());
  }

  /// Check if a photo is bookmarked.
  bool isBookmarked(int photoId) {
    return _bookmarksBox?.containsKey(photoId.toString()) ?? false;
  }

  /// Get all bookmarked photos.
  List<PhotoModel> getBookmarkedPhotos() {
    if (_bookmarksBox == null) return [];

    return _bookmarksBox!.values
        .map((raw) => PhotoModel.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList();
  }
}
