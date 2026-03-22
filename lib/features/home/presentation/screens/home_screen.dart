import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/pin_card.dart';
import '../../../../shared/widgets/shimmer_grid.dart';
import '../providers/feed_provider.dart';
import '../providers/feed_state.dart';
import '../../../../core/network/appwrite_client.dart';

final categories = [
  'All',
  'Architecture',
  'Editorial',
  'Interior',
  'Minimalism',
  'Nature',
  'Typography',
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedState = ref.watch(feedControllerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildTopAppBar(context, theme),
      body: Column(
        children: [
          _buildCategoryFilterRow(theme, feedState.selectedCategory),
          Expanded(
            child: RefreshIndicator(
              color: theme.primaryColor,
              onRefresh: ref.read(feedControllerProvider.notifier).refresh,
              child: _buildGrid(feedState, theme),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          client
              .ping()
              .then((response) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ping successful!')),
                  );
                }
              })
              .catchError((e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Ping failed: $e')));
                }
              });
        },
        label: const Text('Send a ping'),
        icon: const Icon(Icons.network_ping_rounded),
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context, ThemeData theme) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: theme.colorScheme.onSurfaceVariant,
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          const Text(
            'The Curator',
            style: TextStyle(
              color: Color(0xFFC0001B),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Expanded(
            child:
                isDesktop
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        height: 40,
                        constraints: const BoxConstraints(maxWidth: 600),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3F3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              ref
                                  .read(feedControllerProvider.notifier)
                                  .selectCategory(value);
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search for inspiration...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.search),
              color: theme.colorScheme.onSurfaceVariant,
              onPressed: () {},
            ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: theme.colorScheme.onSurfaceVariant,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterRow(ThemeData theme, String selectedCategory) {
    return SizedBox(
      height: 64,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children:
              categories.map((cat) {
                final internalQuery =
                    cat == 'All' ? 'popular' : cat.toLowerCase();
                final isSelected = selectedCategory == internalQuery;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(feedControllerProvider.notifier)
                          .selectCategory(cat);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFB7001A)
                                : const Color(0xFFE9E8E7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF5E3F3C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildGrid(FeedState state, ThemeData theme) {
    if (state.isLoading && state.pins.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppConstants.screenPadding),
        child: ShimmerGrid(),
      );
    }

    if (state.error != null && state.pins.isEmpty) {
      return AppErrorWidget(
        message: 'Failed to load. Tap to retry.',
        onRetry: ref.read(feedControllerProvider.notifier).loadInitialData,
      );
    }

    if (!state.isLoading && state.pins.isEmpty) {
      return Center(
        child: Text(
          "No results found for '${state.selectedCategory}'",
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return Stack(
      children: [
        MasonryGridView.count(
          controller: _scrollController,
          crossAxisCount: AppConstants.gridColumnCount,
          mainAxisSpacing: AppConstants.gridMainAxisSpacing,
          crossAxisSpacing: AppConstants.gridCrossAxisSpacing,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPadding,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 1500, // Preload images for smoother scrolling
          itemCount: state.pins.length + (state.isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= state.pins.length) {
              return Container(
                height: 200 + (index % 3 * 50).toDouble(),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                ),
              );
            }

            final pin = state.pins[index];
            return PinCard(
              pin: pin,
              onTap: () {
                // Ignore Pin Detail for now until updated, or route if safe
                context.push('/pin/${pin.id}', extra: pin);
              },
            );
          },
        ),

        if (state.isLoading)
          const Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
