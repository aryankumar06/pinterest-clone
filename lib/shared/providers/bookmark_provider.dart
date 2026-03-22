import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/data/models/pin_model.dart';
import '../../features/home/domain/entities/pin.dart';

/// Provider for bookmark management (Hive-backed).
final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, List<Pin>>((ref) {
  return BookmarkNotifier();
});

class BookmarkNotifier extends StateNotifier<List<Pin>> {
  BookmarkNotifier() : super([]) {
    _init();
  }

  Box<String>? _box;

  Future<void> _init() async {
    _box = await Hive.openBox<String>('bookmarks');
    _loadBookmarks();
  }

  void _loadBookmarks() {
    if (_box == null) return;
    state = _box!.values
        .map((raw) => PinModel.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList();
  }

  bool isBookmarked(String pinId) {
    return state.any((p) => p.id == pinId);
  }

  Future<void> toggleBookmark(Pin pin) async {
    if (isBookmarked(pin.id)) {
      await _box?.delete(pin.id);
      state = state.where((p) => p.id != pin.id).toList();
    } else {
      final model = PinModel(
        id: pin.id,
        imageUrl: pin.imageUrl,
        title: pin.title,
        author: pin.author,
        authorAvatar: pin.authorAvatar,
        category: pin.category,
        aspectRatio: pin.aspectRatio,
        isVideo: pin.isVideo,
        videoUrl: pin.videoUrl,
      );
      await _box?.put(pin.id, jsonEncode(model.toJson()));
      state = [...state, pin];
    }
  }
}
