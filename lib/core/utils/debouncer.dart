import 'dart:async';

/// A generic debouncer that delays action execution.
class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  /// Run [action] after the debounce period.
  /// Any previous pending action is cancelled.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending action.
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
