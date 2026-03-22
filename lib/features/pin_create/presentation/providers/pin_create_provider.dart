import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/pins_database_repository.dart';
import '../../../home/domain/entities/pin.dart';

final pinsDatabaseRepositoryProvider = Provider(
  (ref) => PinsDatabaseRepository(),
);

final createdPinsProvider = FutureProvider<List<Pin>>((ref) async {
  final repo = ref.watch(pinsDatabaseRepositoryProvider);
  return repo.getCreatedPins();
});
