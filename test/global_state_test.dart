import 'package:bdaya_shared_value/bdaya_shared_value.dart';
import 'package:bdaya_shared_value/inherited_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedValue.didWrap = true;
    SharedValue.stateNonceMap.clear();
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedValue - initial value', () {
    test('returns initial value via \$ getter', () {
      final sv = SharedValue(value: 42);
      expect(sv.$, 42);
    });

    test('of(null) returns value without context', () {
      final sv = SharedValue(value: 'hello');
      expect(sv.of(null), 'hello');
    });
  });

  group('SharedValue - set/get/update', () {
    test('set and get value', () {
      final sv = SharedValue(value: 0);
      sv.$ = 10;
      expect(sv.$, 10);
    });

    test('update applies function to current value', () {
      final sv = SharedValue(value: 5);
      sv.update((v) => v * 2);
      expect(sv.$, 10);
    });

    test('setIfChanged skips when value is equal', () {
      final sv = SharedValue(value: 5);
      final nonceBefore = sv.nonce;
      sv.setIfChanged(5);
      expect(sv.nonce, nonceBefore);
    });

    test('setIfChanged updates when value differs', () {
      final sv = SharedValue(value: 5);
      final nonceBefore = sv.nonce;
      sv.setIfChanged(10);
      expect(sv.$, 10);
      expect(sv.nonce, isNot(nonceBefore));
    });

    test('setState throws when wrapApp was not called', () {
      SharedValue.didWrap = false;
      final sv = SharedValue(value: 0);
      expect(() => sv.$ = 1, throwsA(isA<FlutterError>()));
    });
  });

  group('SharedValue - streams', () {
    test('stream emits on value changes', () async {
      final sv = SharedValue(value: 0);
      final values = <int>[];
      final sub = sv.stream.listen(values.add);

      sv.$ = 1;
      sv.$ = 2;
      sv.$ = 3;

      await Future<void>.delayed(Duration.zero);
      expect(values, [1, 2, 3]);
      await sub.cancel();
    });

    test('stream does not emit initial value', () async {
      final sv = SharedValue(value: 42);
      final values = <int>[];
      final sub = sv.stream.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      expect(values, isEmpty);
      await sub.cancel();
    });

    test('streamWithInitial emits current value first', () async {
      final sv = SharedValue(value: 42);
      final values = <int>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      expect(values.first, 42);

      sv.$ = 100;
      await Future<void>.delayed(Duration.zero);
      expect(values, [42, 100]);
      await sub.cancel();
    });

    test(
      'streamWithInitial emits initial value before changes (regression)',
      () async {
        final sv = SharedValue(value: 99);
        final values = <int>[];
        final sub = sv.streamWithInitial.listen(values.add);

        await Future<void>.delayed(Duration.zero);
        expect(values, [99]);

        sv.$ = 50;
        await Future<void>.delayed(Duration.zero);
        expect(values, [99, 50]);
        await sub.cancel();
      },
    );
  });

  group('SharedValue - persistence', () {
    test('save and load round-trip with JSON', () async {
      final sv1 = SharedValue<int>(value: 42, key: 'test_int');
      await sv1.save();

      final sv2 = SharedValue<int>(value: 0, key: 'test_int');
      await sv2.load();
      expect(sv2.$, 42);
    });

    test('load with no stored value keeps default', () async {
      final sv = SharedValue<int>(value: 99, key: 'nonexistent');
      await sv.load();
      expect(sv.$, 99);
    });

    test('save null via customEncode removes key', () async {
      final sv = SharedValue<String?>(
        value: 'hello',
        key: 'nullable_key',
        customEncode: (v) => v,
        customDecode: (s) => s,
      );
      await sv.save();

      sv.$ = null;
      await sv.save();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('nullable_key'), isNull);
    });

    test('autosave persists on change', () async {
      final sv = SharedValue<int>(
        value: 0,
        key: 'autosave_key',
        autosave: true,
      );

      sv.$ = 42;
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('autosave_key'), '42');
    });
  });

  group('SharedValue - customEncode/customDecode', () {
    test('custom encoder and decoder round-trip', () async {
      final sv1 = SharedValue<List<int>>(
        value: [1, 2, 3],
        key: 'list_key',
        customEncode: (v) => v.join(','),
        customDecode: (s) =>
            s == null ? <int>[] : s.split(',').map(int.parse).toList(),
      );
      await sv1.save();

      final sv2 = SharedValue<List<int>>(
        value: <int>[],
        key: 'list_key',
        customEncode: (v) => v.join(','),
        customDecode: (s) =>
            s == null ? <int>[] : s.split(',').map(int.parse).toList(),
      );
      await sv2.load();
      expect(sv2.$, [1, 2, 3]);
    });

    test('customDecode receives null for missing key (v3.1.3 fix)', () async {
      String? received = 'sentinel';
      final sv = SharedValue<String>(
        value: 'default',
        key: 'missing_key',
        customDecode: (s) {
          received = s;
          return s ?? 'fallback';
        },
      );
      await sv.load();
      expect(received, isNull);
      expect(sv.$, 'fallback');
    });
  });

  group('SharedValue - customSave/customLoad', () {
    test('custom save and load round-trip', () async {
      String? storage;
      final sv = SharedValue<int>(
        value: 0,
        customSave: (v) async => storage = v.toString(),
        customLoad: () async => int.parse(storage ?? '0'),
      );

      sv.$ = 42;
      await sv.save();
      expect(storage, '42');

      sv.$ = 0;
      await sv.load();
      expect(sv.$, 42);
    });
  });

  group('SharedValue - waitUntil', () {
    test('resolves immediately if predicate is satisfied', () async {
      final sv = SharedValue(value: 10);
      final result = await sv.waitUntil((v) => v > 5);
      expect(result, 10);
    });

    test('waits until predicate is satisfied', () async {
      final sv = SharedValue(value: 0);
      final future = sv.waitUntil((v) => v >= 3);

      for (var i = 1; i <= 3; i++) {
        await Future<void>.delayed(Duration.zero);
        sv.$ = i;
      }

      final result = await future;
      expect(result, 3);
    });
  });

  group('SharedValueInheritedModel', () {
    test('updateShouldNotify detects map changes', () {
      final old = SharedValueInheritedModel(
        stateNonceMap: {1: 0.5, 2: 0.3},
        child: const SizedBox(),
      );
      final current = SharedValueInheritedModel(
        stateNonceMap: {1: 0.5, 2: 0.7},
        child: const SizedBox(),
      );
      expect(current.updateShouldNotify(old), isTrue);
    });

    test('updateShouldNotify returns false for equal maps', () {
      final old = SharedValueInheritedModel(
        stateNonceMap: {1: 0.5, 2: 0.3},
        child: const SizedBox(),
      );
      final current = SharedValueInheritedModel(
        stateNonceMap: {1: 0.5, 2: 0.3},
        child: const SizedBox(),
      );
      expect(current.updateShouldNotify(old), isFalse);
    });

    test('updateShouldNotifyDependent filters by watched key', () {
      final old = SharedValueInheritedModel(
        stateNonceMap: {1: 0.5, 2: 0.3},
        child: const SizedBox(),
      );
      final current = SharedValueInheritedModel(
        stateNonceMap: {1: 0.5, 2: 0.7},
        child: const SizedBox(),
      );

      expect(current.updateShouldNotifyDependent(old, {1}), isFalse);
      expect(current.updateShouldNotifyDependent(old, {2}), isTrue);
      expect(current.updateShouldNotifyDependent(old, {1, 2}), isTrue);
    });
  });

  group('SharedValue - widget integration', () {
    testWidgets('widget rebuilds when watched SharedValue changes', (
      tester,
    ) async {
      SharedValue.didWrap = false;
      SharedValue.stateNonceMap.clear();

      final counter = SharedValue(value: 0);
      int buildCount = 0;

      await tester.pumpWidget(
        SharedValue.wrapApp(
          MaterialApp(
            home: Builder(
              builder: (context) {
                buildCount++;
                final val = counter.of(context);
                return Text('$val');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      final initialBuildCount = buildCount;

      counter.$ = 1;
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(buildCount, greaterThan(initialBuildCount));
    });
  });
}
