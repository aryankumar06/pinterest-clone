import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/bookmark_provider.dart';
import '../../../../shared/widgets/board_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/pin_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pin_create/presentation/providers/pin_create_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedPins = ref.watch(bookmarkProvider);
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.share, color: Colors.black, size: 20),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.black),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFFE9E9E9),
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Guest User',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.black,
                      indicatorWeight: 3,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [Tab(text: 'Created'), Tab(text: 'Saved')],
                    ),
                  ],
                ),
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Created Tab
            ref
                .watch(createdPinsProvider)
                .when(
                  data:
                      (pins) =>
                          pins.isEmpty
                              ? const Center(
                                child: Text(
                                  'Ideas you create will appear here',
                                ),
                              )
                              : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 0.6,
                                    ),
                                itemCount: pins.length,
                                itemBuilder:
                                    (context, index) => PinCard(
                                      pin: pins[index],
                                      onTap:
                                          () => context.push(
                                            '/pin/${pins[index].id}',
                                            extra: pins[index],
                                          ),
                                    ),
                              ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),

            // Saved Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Quick Saves Board
                BoardCard(
                  name: 'Quick Saves',
                  pins: savedPins,
                  onTap: () => context.push('/board/Quick Saves'),
                ),
                const SizedBox(height: 24),

                // All Pins Grid (Masonry)
                const Text(
                  'All Pins',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                savedPins.isEmpty
                    ? const EmptyStateWidget(
                      message: 'No saved pins yet.',
                      icon: Icons.push_pin_outlined,
                    )
                    : StaggeredGrid.count(
                      crossAxisCount: AppConstants.gridColumnCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children:
                          savedPins
                              .map(
                                (pin) => StaggeredGridTile.fit(
                                  crossAxisCellCount: 1,
                                  child: PinCard(
                                    pin: pin,
                                    onTap:
                                        () => context.push(
                                          '/pin/${pin.id}',
                                          extra: pin,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
