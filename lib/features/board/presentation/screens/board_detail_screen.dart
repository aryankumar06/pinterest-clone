import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../shared/widgets/pin_card.dart';
import '../../../../shared/providers/bookmark_provider.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  const BoardDetailScreen({super.key, required this.boardName});
  final String boardName;

  @override
  ConsumerState<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen> {
  bool _isOrganizing = false;
  final List<String> _selectedPinIds = [];

  void _toggleSelection(String pinId) {
    setState(() {
      if (_selectedPinIds.contains(pinId)) {
        _selectedPinIds.remove(pinId);
      } else {
        _selectedPinIds.add(pinId);
      }
    });
  }

  void _showAddSectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _AddSectionSheet(
            onDone: (name) {
              Navigator.pop(context);
              _showSectionAddedBanner();
            },
          ),
    );
  }

  void _showSectionAddedBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Center(
          child: Text(
            'Section added!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSectionOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Section options',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Edit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Merge',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9E9E9),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedPins = ref.watch(bookmarkProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
            onPressed: _showSectionOptions,
          ),
        ],
        centerTitle: true,
        title:
            _isOrganizing
                ? Text(
                  '${_selectedPinIds.length} selected',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : null,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header ...
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        widget.boardName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9E9E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            icon: Icons.lightbulb_outline_rounded,
                            label: 'More ideas',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: Icons.dashboard_outlined,
                            label: 'Organize',
                            isActive: _isOrganizing,
                            onTap:
                                () => setState(() {
                                  _isOrganizing = !_isOrganizing;
                                  _selectedPinIds.clear();
                                }),
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: Icons.notes_rounded,
                            label: 'Notes',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${savedPins.length} Pins',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.sync_alt_rounded, size: 20),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Pins Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemBuilder: (context, index) {
                    // Inject a "+" placeholder at the end for "Add Section" style as seen in Image 1
                    if (index == savedPins.length) {
                      if (_isOrganizing) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: _showAddSectionSheet,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Icon(Icons.add, size: 40)),
                        ),
                      );
                    }

                    final pin = savedPins[index];
                    final isSelected = _selectedPinIds.contains(pin.id);

                    return GestureDetector(
                      onTap:
                          _isOrganizing ? () => _toggleSelection(pin.id) : null,
                      child: Stack(
                        children: [
                          PinCard(
                            pin: pin,
                            onTap: () {
                              if (!_isOrganizing) {
                                context.push('/pin/${pin.id}', extra: pin);
                              } else {
                                _toggleSelection(pin.id);
                              }
                            },
                          ),
                          if (_isOrganizing)
                            Positioned(
                              bottom: 24,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.black
                                          : Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: savedPins.length + 1,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Selection Bar ...
          if (_isOrganizing)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_to_photos_outlined),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.drive_file_move_outlined),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.ios_share_rounded),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

          if (!_isOrganizing)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: _showAddSectionSheet,
                child: const Icon(Icons.add, size: 32),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.black : const Color(0xFFE9E9E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AddSectionSheet extends StatefulWidget {
  const _AddSectionSheet({required this.onDone});
  final Function(String) onDone;

  @override
  State<_AddSectionSheet> createState() => _AddSectionSheetState();
}

class _AddSectionSheetState extends State<_AddSectionSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Add section',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => widget.onDone(_controller.text),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFFE60023),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE9E9E9),
              child: Icon(Icons.image_outlined, color: Colors.grey, size: 32),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Name',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Add',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Or pick one of these:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SuggestionChip(
                label: 'Galaxy wallpaper iphone',
                onTap: () => widget.onDone('Galaxy wallpaper iphone'),
              ),
              _SuggestionChip(
                label: 'Clouds wallpaper iphone',
                onTap: () => widget.onDone('Clouds wallpaper iphone'),
              ),
              _SuggestionChip(
                label: 'Witchy wallpaper',
                onTap: () => widget.onDone('Witchy wallpaper'),
              ),
              _SuggestionChip(
                label: 'Dark phone wallpapers',
                onTap: () => widget.onDone('Dark phone wallpapers'),
              ),
              _SuggestionChip(
                label: 'Dark wallpaper iphone',
                onTap: () => widget.onDone('Dark wallpaper iphone'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
