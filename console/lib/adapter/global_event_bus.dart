import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Every state a cubit emits also goes on the [GlobalEventBus]: another
/// feature reacts to it with [onBus] in its constructor (a list that reloads
/// after a form saved), never by finding that cubit.
mixin GlobalEventBusCommunication<T> on Cubit<T> {
  final List<StreamSubscription> _subscriptions = [];

  /// Calls [listener] on every [Y] fired on the bus until this cubit closes
  StreamSubscription<Y> onBus<Y>(void Function(Y event) listener) {
    final subscription = GlobalEventBus().on<Y>().listen(listener);
    _subscriptions.add(subscription);
    return subscription;
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }

  @override
  void emit(T state, {bool fireBus = true}) {
    super.emit(state);
    if (fireBus) GlobalEventBus().fire(state);
  }
}

/// The facts (states) of every cubit, for the others to react to: never
/// commands.
class GlobalEventBus {
  static final GlobalEventBus _instance = GlobalEventBus._internal();

  factory GlobalEventBus() => _instance;

  GlobalEventBus._internal();

  final StreamController<dynamic> _controller = StreamController.broadcast();

  void fire(Object? event) => _controller.add(event);

  Stream<T> on<T>() =>
      _controller.stream.where((event) => event is T).cast<T>();
}
