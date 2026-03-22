import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/long_press_menu.dart';
import '../../features/home/domain/entities/pin.dart';

class PinCard extends ConsumerStatefulWidget {
  const PinCard({super.key, required this.pin, required this.onTap});

  final Pin pin;
  final VoidCallback onTap;

  @override
  ConsumerState<PinCard> createState() => _PinCardState();
}

class _PinCardState extends ConsumerState<PinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.tapScaleDurationMs),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _showLongPressMenu(TapDownDetails details) {
    HapticFeedback.mediumImpact();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => LongPressMenu(
            position: details.globalPosition,
            onActionSelected: (action) {
              // Handle logic
            },
            onClose: () {
              entry.remove();
              _animationController.reverse(); // Release the card scale
            },
          ),
    );

    overlay.insert(entry);
    _animationController.forward(); // Scale down while menu is open
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Since we don't store average color on Pin model from this simplified json,
    // we just use a generic placeholder color.
    final bgColor = theme.colorScheme.surfaceContainerHighest;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPressStart:
            (details) => _showLongPressMenu(
              TapDownDetails(globalPosition: details.globalPosition),
            ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder:
              (context, child) =>
                  Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image Container ──────────────────────────────────────────
              Stack(
                children: [
                  Hero(
                    tag: 'pin_${widget.pin.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius,
                        ),
                        color: bgColor,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: AspectRatio(
                        aspectRatio: widget.pin.aspectRatio,
                        child: CachedNetworkImage(
                          imageUrl: widget.pin.imageUrl,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder:
                              (context, url) => Container(color: bgColor),
                          errorWidget:
                              (context, url, error) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),

                  // ── Video Overlay ───────────────────────────────────────
                  if (widget.pin.isVideo)
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 40,
                        ),
                      ),
                    ),

                  // ── Save/More Actions Overlay (Hover / Long Press) ────────
                  if (_isHovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _SaveButton(pin: widget.pin),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _CircularIconButton(
                                  icon: Icons.ios_share_rounded,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 8),
                                _CircularIconButton(
                                  icon: Icons.more_horiz_rounded,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Title & Author ──────────────────────────────────────────
              if (widget.pin.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.pin.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage:
                          widget.pin.authorAvatar.isNotEmpty
                              ? CachedNetworkImageProvider(
                                widget.pin.authorAvatar,
                              )
                              : null,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child:
                          widget.pin.authorAvatar.isEmpty
                              ? Text(
                                widget.pin.author.isNotEmpty
                                    ? widget.pin.author[0].toUpperCase()
                                    : 'A',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pin.author.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: Color(0xFF5F5E5E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  const _SaveButton({required this.pin});

  final Pin pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now returning placeholder save action
    // Real implementation would connect to bookmarkProvider
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: const Text(
        'Save',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
