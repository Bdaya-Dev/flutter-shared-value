import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'inherited_model.dart';
import 'manager_widget.dart';

class SharedValue<T> {
  static final random = Random();
  static final stateManager = StateManagerWidgetState();

  //Maps a sharedvalue hashcode to its nonce
  //This way SharedValue instances can be garbage collected safely
  static final stateNonceMap = <int, double>{};

  static bool didWrap = false;

  /// Initalize Shared value.
  ///
  /// Internally, this inserts an [InheritedModel] widget into the widget tree.
  ///
  /// This must be done exactly once for the whole application.
  static Widget wrapApp(Widget app) {
    didWrap = true;
    return StateManagerWidget(app, stateManager, stateNonceMap);
  }

  T _value;

  double? nonce;
  StreamController<T>? _controller;

  /// The key to use for storing this value in shared preferences.
  final String? key;

  /// automatically save to shared preferences when the value changes
  final bool autosave;

  /// customize encode function, returning null indicates removing the key from storage
  final String? Function(T val)? customEncode;

  /// customize decode function, null idicates the key not existing in storage
  final T Function(String? val)? customDecode;

  /// customize save function
  final Future<void> Function(T val)? customSave;

  /// customize load function
  final Future<T> Function()? customLoad;

  SharedValue({
    this.key,
    required T value,
    this.autosave = false,
    this.customEncode,
    this.customDecode,
    this.customLoad,
    this.customSave,
  }) : _value = value {
    _update(init: true);
  }

  /// The value held by this state.
  T get $ => _value;

  /// Update the value and rebuild the dependent widgets if it changed.
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
  /// and also rebuild the widget in [context] whenever [mutate] is called.
  T of(BuildContext? context) {
    if (context != null) {
      InheritedModel.inheritFrom<SharedValueInheritedModel>(
        context,
        aspect: identityHashCode(this),
      );
    }
    return _value;
  }

  /// A stream of [$]s that gets updated everytime the internal value is changed.
  Stream<T> get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  Stream<T> get streamWithInitial async* {
    yield $;
    yield* stream;
  }

  /// Set [$] to [value], but only if they're different
  void setIfChanged(T value) {
    if (value == $) return;
    $ = value;
  }

  /// Set [$] to the return value of [fn],
  /// and rebuild the dependent widgets if it changed.
  void update(T Function(T) fn) {
    $ = fn(_value);
  }

  void _update({bool init = false}) {
    // update the nonce
    nonce = random.nextDouble();
    stateNonceMap[identityHashCode(this)] = nonce!;

    if (!init) {
      // rebuild state manger widget
      stateManager.rebuild();
    }

    // add value to stream
    _controller?.add($);

    if (!init && autosave) {
      save();
    }
  }

  Future<T> waitUntil(bool Function(T) predicate) async {
    // short-circuit if predicate already satisfied
    if (predicate($)) return $;
    // otherwise, run predicate on every change
    await for (final T value in stream) {
      if (predicate(value)) break;
    }
    return $;
  }

  /// Load a persisted value and update [$].
  ///
  /// Requires [customLoad] to be set. Use a persistence package
  /// (e.g. `bdaya_shared_value_prefs`) or provide your own callback.
  Future<void> load() async {
    assert(
      customLoad != null,
      'customLoad is required. Provide a customLoad callback or use a '
      'persistence package like bdaya_shared_value_prefs.',
    );
    $ = await customLoad!();
  }

  /// Persist the current [$].
  ///
  /// Requires [customSave] to be set. Use a persistence package
  /// (e.g. `bdaya_shared_value_prefs`) or provide your own callback.
  Future<void> save() async {
    assert(
      customSave != null,
      'customSave is required. Provide a customSave callback or use a '
      'persistence package like bdaya_shared_value_prefs.',
    );
    await customSave!(_value);
  }

  /// serialize [obj] of type [T] for shared preferences.
  String? serialize(T obj) {
    if (customEncode == null) {
      return jsonEncode(obj);
    } else {
      return customEncode!(obj);
    }
  }

  /// desrialize [str] to an obj of type [T] for shared preferences.
  T deserialize(String? str) {
    if (customDecode == null) {
      return jsonDecode(str!) as T;
    } else {
      return customDecode!(str);
    }
  }
}
