import 'dart:async';

import 'package:flutter/widgets.dart';

import 'inherited_model.dart';
import 'manager_widget.dart';

class SharedValue<T> {
  static bool didWrap = false;

  /// Wraps [app] with the state management widget tree.
  ///
  /// This must be called exactly once, alongside [runApp]:
  /// ```dart
  /// runApp(SharedValue.wrapApp(MyApp()));
  /// ```
  static Widget wrapApp(Widget app) {
    didWrap = true;
    return StateManagerWidget(child: app);
  }

  T _value;

  StreamController<T>? _controller;

  SharedValue({required T value}) : _value = value;

  /// The value held by this state.
  T get $ => _value;

  /// Update the value and rebuild the dependent widgets.
  set $(T newValue) {
    setState(() {
      _value = newValue;
    });
  }

  /// Rebuild all dependent widgets.
  R? setState<R>([R? Function()? fn]) {
    if (!didWrap) {
      throw FlutterError.fromParts([
        ErrorSummary("SharedValue was not initalized."),
        ErrorHint(
          "Did you forget to call SharedValue.wrapApp()?\n"
          "If so, please do it once,"
          "alongside runApp() so that SharedValue can be initalized for you application.\n"
          "Example:\n"
          "\trunApp(SharedValue.wrapApp(MyApp()))",
        ),
      ]);
    }

    R? ret = fn?.call();

    if (ret is Future) {
      ret.then((_) {
        _update();
      });
    } else {
      _update();
    }

    return ret;
  }

  /// Get the value held by this state,
  /// and also rebuild the widget in [context] whenever the value changes.
  T of(BuildContext? context) {
    if (context != null) {
      InheritedModel.inheritFrom<SharedValueInheritedModel>(
        context,
        aspect: identityHashCode(this),
      );
    }
    return _value;
  }

  /// A stream that emits whenever the value changes.
  Stream<T> get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  /// Like [stream], but emits the current value immediately on listen.
  Stream<T> get streamWithInitial async* {
    yield $;
    yield* stream;
  }

  /// Set [$] to [value], but only if they're different.
  void setIfChanged(T value) {
    if (value == $) return;
    $ = value;
  }

  /// Apply [fn] to the current value and set the result.
  void update(T Function(T) fn) {
    $ = fn(_value);
  }

  void _update() {
    StateManagerWidget.markChanged(identityHashCode(this));
    StateManagerWidget.triggerRebuild();
    _controller?.add($);
  }

  /// Wait for [$] to satisfy [predicate], then return the value.
  Future<T> waitUntil(bool Function(T) predicate) async {
    if (predicate($)) return $;
    await for (final T value in stream) {
      if (predicate(value)) break;
    }
    return $;
  }
}
