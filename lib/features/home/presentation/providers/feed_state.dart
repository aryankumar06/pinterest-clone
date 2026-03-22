import '../../domain/entities/pin.dart';

class FeedState {
  const FeedState({
    this.pins = const [],
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.selectedCategory = 'popular',
  });

  final List<Pin> pins;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String selectedCategory;

  FeedState copyWith({
    List<Pin>? pins,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? Function()? error,
    String? selectedCategory,
  }) {
    return FeedState(
      pins: pins ?? this.pins,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error != null ? error() : this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
