import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/entities/pin.dart';
import '../../../home/presentation/providers/feed_provider.dart';

final pinDetailProvider =
    FutureProvider.family<Pin, String>((ref, id) {
  final service = ref.watch(pexelsServiceProvider);
  return service.fetchPinById(id);
});

final relatedPinsProvider = 
    FutureProvider.family<List<Pin>, String>((ref, category) {
  final service = ref.watch(pexelsServiceProvider);
  return service.fetchPins(category, 1);
});
