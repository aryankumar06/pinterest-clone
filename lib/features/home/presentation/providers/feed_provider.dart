import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/pexels_service.dart';
import 'feed_state.dart';

final pexelsServiceProvider = Provider((ref) => const PexelsService());

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  final service = ref.watch(pexelsServiceProvider);
  return FeedController(service)..loadInitialData();
});

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._service) : super(const FeedState());

  final PexelsService _service;

  static const List<String> videoCategories = ['nature', 'fitness', 'travel']; // Example categories that might be better as video

  bool get _shouldFetchVideo => videoCategories.contains(state.selectedCategory);

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final isVideo = _shouldFetchVideo;
      final pins = await _service.fetchPins(state.selectedCategory, 1, isVideo: isVideo);
      
      state = state.copyWith(
        pins: pins,
        page: 2,
        isLoading: false,
        hasMore: pins.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(page: 1, hasMore: true);
    await loadInitialData();
  }

  Future<void> selectCategory(String category) async {
    if (state.selectedCategory == category) return;
    
    // Convert "All" to "popular" to fetch broader results from Pexels
    final query = category == 'All' ? 'popular' : category.toLowerCase();
    
    state = state.copyWith(
      selectedCategory: query,
      pins: [], // clear immediately
      page: 1,
      hasMore: true,
    );
    await loadInitialData();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final isVideo = _shouldFetchVideo;
      final newPins = await _service.fetchPins(state.selectedCategory, state.page, isVideo: isVideo);

      if (newPins.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
      } else {
        // Prevent duplicates
        final existingIds = state.pins.map((p) => p.id).toSet();
        final uniqueNewPins = newPins.where((p) => !existingIds.contains(p.id)).toList();

        state = state.copyWith(
          pins: [...state.pins, ...uniqueNewPins],
          page: state.page + 1,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
      // maybe add error handling for pagination
    }
  }
}
