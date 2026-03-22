import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../features/home/domain/entities/pin.dart';

class BoardCard extends StatelessWidget {
  const BoardCard({
    super.key,
    required this.name,
    required this.pins,
    required this.onTap,
  });

  final String name;
  final List<Pin> pins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E9E9),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // Big preview
                Expanded(
                  flex: 2,
                  child:
                      pins.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: pins[0].imageUrl,
                            fit: BoxFit.cover,
                            height: double.infinity,
                          )
                          : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 2),
                // Smaller previews
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            pins.length > 1
                                ? CachedNetworkImage(
                                  imageUrl: pins[1].imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                                : Container(color: Colors.grey[200]),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child:
                            pins.length > 2
                                ? CachedNetworkImage(
                                  imageUrl: pins[2].imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                                : Container(color: Colors.grey[200]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            '${pins.length} Pins',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
