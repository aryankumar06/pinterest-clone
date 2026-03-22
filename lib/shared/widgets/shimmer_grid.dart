import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_constants.dart';

/// A masonry grid of shimmer placeholder cards for loading state.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
      ),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: AppConstants.gridColumnCount,
        mainAxisSpacing: AppConstants.gridMainAxisSpacing,
        crossAxisSpacing: AppConstants.gridCrossAxisSpacing,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Varying heights for authentic masonry feel
          final heights = [200.0, 260.0, 180.0, 300.0, 220.0, 240.0, 280.0, 190.0];
          final height = heights[index % heights.length];

          return Shimmer.fromColors(
            baseColor: isDark
                ? Colors.grey.shade800
                : Color(AppConstants.shimmerBaseColor),
            highlightColor: isDark
                ? Colors.grey.shade700
                : Color(AppConstants.shimmerHighlightColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.cardBorderRadius,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 10,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
