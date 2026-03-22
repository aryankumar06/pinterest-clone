import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/pin_card.dart';
import '../../../../shared/providers/bookmark_provider.dart';
import '../../../home/domain/entities/pin.dart';
import '../providers/pin_detail_provider.dart';

class PinDetailScreen extends ConsumerWidget {
  const PinDetailScreen({super.key, required this.pinId, this.pin});

  final String pinId;
  final Pin? pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinData = pin ?? ref.watch(pinDetailProvider(pinId)).valueOrNull;
    final isLoading =
        pin == null && ref.watch(pinDetailProvider(pinId)).isLoading;
    final hasError =
        pin == null && ref.watch(pinDetailProvider(pinId)).hasError;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  ),
                  child: const Icon(Icons.more_horiz_rounded, size: 20),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (hasError)
            const SliverFillRemaining(
              child: Center(child: Text('Failed to load pin details')),
            )
          else if (pinData != null) ...[
            SliverToBoxAdapter(
              child: _PinDetailContent(pin: pinData, screenWidth: size.width),
            ),
            _RelatedPinsGrid(
              category: pinData.category,
              currentPinId: pinData.id,
            ),
          ],
        ],
      ),
    );
  }
}

class _PinDetailContent extends ConsumerStatefulWidget {
  const _PinDetailContent({required this.pin, required this.screenWidth});

  final Pin pin;
  final double screenWidth;

  @override
  ConsumerState<_PinDetailContent> createState() => _PinDetailContentState();
}

class _PinDetailContentState extends ConsumerState<_PinDetailContent> {
  bool _isCommentsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final imageHeight = widget.screenWidth / widget.pin.aspectRatio;
    final isBookmarked = ref
        .watch(bookmarkProvider)
        .any((p) => p.id == widget.pin.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. PIN IMAGE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Hero(
            tag: 'pin_${widget.pin.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: CachedNetworkImage(
                imageUrl: widget.pin.imageUrl,
                width: widget.screenWidth - 32,
                height: imageHeight.clamp(200.0, 800.0),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. AUTHOR ROW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  widget.pin.authorAvatar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pin.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      '12k followers',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9E9E9),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. TITLE & DESCRIPTION
        if (widget.pin.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.pin.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

        const SizedBox(height: 20),

        // 4. VISIT & SAVE BUTTONS (The core requirement from image)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9E9E9),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Visit',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSaveToBoardBottomSheet(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isBookmarked ? Colors.black : const Color(0xFFE60023),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    isBookmarked ? 'Saved' : 'Save',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 5. ACTION BUTTONS (Share, Link)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DetailIconAction(
                icon: Icons.share_rounded,
                onTap: () {
                  Share.share('Check out this pin: ${widget.pin.imageUrl}');
                },
              ),
              _DetailIconAction(icon: Icons.link_rounded, onTap: () {}),
              _DetailIconAction(icon: Icons.download_rounded, onTap: () {}),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 0.1, color: Colors.black26),

        // 6. COMMENTS SECTION
        _buildCommentsToggle(),

        const Divider(height: 1, thickness: 0.1, color: Colors.black26),
        const SizedBox(height: 24),

        // RELATED PINS HEADER
        const Center(
          child: Text(
            'More like this',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSaveToBoardBottomSheet(BuildContext context, WidgetRef ref) {
    final boards = [
      'Quick Saves',
      'Inspirations',
      'Project Ideas',
      'Shopping List',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Save to board',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              ...boards.map(
                (board) => ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.push_pin_rounded,
                      color: Colors.black26,
                    ),
                  ),
                  title: Text(
                    board,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    ref
                        .read(bookmarkProvider.notifier)
                        .toggleBookmark(widget.pin);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  'Create board',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsToggle() {
    return InkWell(
      onTap: () => setState(() => _isCommentsExpanded = !_isCommentsExpanded),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Text('83', style: TextStyle(color: Colors.black54)),
                Icon(
                  _isCommentsExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
              ],
            ),
            if (_isCommentsExpanded) ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Amazing! This looks incredible, would love to see more from this creator.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a comment',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailIconAction extends StatelessWidget {
  const _DetailIconAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.black, size: 28),
      onPressed: onTap,
    );
  }
}

class _RelatedPinsGrid extends ConsumerWidget {
  const _RelatedPinsGrid({required this.category, required this.currentPinId});
  final String category;
  final String currentPinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedPins = ref.watch(relatedPinsProvider(category));

    return relatedPins.when(
      data: (pins) {
        final filteredPins = pins.where((p) => p.id != currentPinId).toList();
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemBuilder: (context, index) {
              final pin = filteredPins[index];
              return PinCard(
                pin: pin,
                onTap: () {
                  context.push('/pin/${pin.id}', extra: pin);
                },
              );
            },
            childCount: filteredPins.length,
          ),
        );
      },
      loading:
          () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
    );
  }
}
