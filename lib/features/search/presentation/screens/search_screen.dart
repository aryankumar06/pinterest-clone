import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FocusNode _focusNode;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _isSearching = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Animated Search Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Search for ideas',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_isSearching)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _focusNode.unfocus();
                                  setState(() => _isSearching = false);
                                  _controller.reverse();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isSearching)
                    SizeTransition(
                      sizeFactor: _controller,
                      axis: Axis.horizontal,
                      child: TextButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          setState(() => _isSearching = false);
                          _controller.reverse();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content Switching ────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _isSearching ? _buildSearchResults() : _buildExploreGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreGrid() {
    final categories = [
      {
        'name': 'Nature',
        'image':
            'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400',
      },
      {
        'name': 'Interiors',
        'image':
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
      },
      {
        'name': 'Fashion',
        'image':
            'https://images.unsplash.com/photo-1539109132382-381bb3f1c2b5?w=400',
      },
      {
        'name': 'Architecture',
        'image':
            'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=400',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(cat['image']!, fit: BoxFit.cover),
              Container(color: Colors.black.withOpacity(0.3)),
              Center(
                child: Text(
                  cat['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.black12),
          SizedBox(height: 16),
          Text(
            'Search for anything',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
