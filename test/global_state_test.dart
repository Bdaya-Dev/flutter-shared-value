import 'package:bdaya_shared_value/bdaya_shared_value.dart';
import 'package:bdaya_shared_value/inherited_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    SharedValue.didWrap = true;
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
      final values = <int>[];
      sv.stream.listen(values.add);
      sv.setIfChanged(5);
      expect(values, isEmpty);
    });

    test('setIfChanged updates when value differs', () async {
      final sv = SharedValue(value: 5);
      final values = <int>[];
      sv.stream.listen(values.add);
      sv.setIfChanged(10);
      expect(sv.$, 10);
      await Future<void>.delayed(Duration.zero);
      expect(values, [10]);
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

    test('streamWithInitial captures value at subscription time', () async {
      final sv = SharedValue(value: 1);
      sv.$ = 42;

      final values = <int>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      expect(values, [42]);
      await sub.cancel();
    });

    test(
      'streamWithInitial supports multiple independent subscriptions',
      () async {
        final sv = SharedValue(value: 10);
        final valuesA = <int>[];
        final valuesB = <int>[];

        final subA = sv.streamWithInitial.listen(valuesA.add);
        await Future<void>.delayed(Duration.zero);

        sv.$ = 20;
        await Future<void>.delayed(Duration.zero);

        final subB = sv.streamWithInitial.listen(valuesB.add);
        await Future<void>.delayed(Duration.zero);

        sv.$ = 30;
        await Future<void>.delayed(Duration.zero);

        expect(valuesA, [10, 20, 30]);
        expect(valuesB, [20, 30]);

        await subA.cancel();
        await subB.cancel();
      },
    );

    test('streamWithInitial does not duplicate the initial value', () async {
      final sv = SharedValue(value: 7);
      final values = <int>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(values, [7]);
      await sub.cancel();
    });

    test('streamWithInitial forwards many rapid changes in order', () async {
      final sv = SharedValue(value: 0);
      final values = <int>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);

      for (var i = 1; i <= 10; i++) {
        sv.$ = i;
      }

      await Future<void>.delayed(Duration.zero);
      expect(values, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      await sub.cancel();
    });

    test('streamWithInitial works with String type', () async {
      final sv = SharedValue(value: 'hello');
      final values = <String>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      sv.$ = 'world';
      await Future<void>.delayed(Duration.zero);

      expect(values, ['hello', 'world']);
      await sub.cancel();
    });

    test('streamWithInitial works with nullable type', () async {
      final sv = SharedValue<int?>(value: null);
      final values = <int?>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      sv.$ = 5;
      await Future<void>.delayed(Duration.zero);
      sv.$ = null;
      await Future<void>.delayed(Duration.zero);

      expect(values, [null, 5, null]);
      await sub.cancel();
    });

    test('cancelling streamWithInitial subscription stops receiving', () async {
      final sv = SharedValue(value: 0);
      final values = <int>[];
      final sub = sv.streamWithInitial.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      sv.$ = 1;
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();

      sv.$ = 2;
      sv.$ = 3;
      await Future<void>.delayed(Duration.zero);

      expect(values, [0, 1]);
    });

    test('each streamWithInitial call returns a fresh stream', () async {
      final sv = SharedValue(value: 5);

      final stream1 = sv.streamWithInitial;
      final stream2 = sv.streamWithInitial;

      expect(identical(stream1, stream2), isFalse);

      final v1 = <int>[];
      final v2 = <int>[];
      final s1 = stream1.listen(v1.add);
      final s2 = stream2.listen(v2.add);

      await Future<void>.delayed(Duration.zero);
      expect(v1, [5]);
      expect(v2, [5]);

      await s1.cancel();
      await s2.cancel();
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
    test('updateShouldNotify returns true when keys changed', () {
      final old = SharedValueInheritedModel(
        changedKeys: const {},
        child: const SizedBox(),
      );
      final current = SharedValueInheritedModel(
        changedKeys: {1},
        child: const SizedBox(),
      );
      expect(current.updateShouldNotify(old), isTrue);
    });

    test('updateShouldNotify returns false when no keys changed', () {
      final old = SharedValueInheritedModel(
        changedKeys: {1},
        child: const SizedBox(),
      );
      final current = SharedValueInheritedModel(
        changedKeys: const {},
        child: const SizedBox(),
      );
      expect(current.updateShouldNotify(old), isFalse);
    });

    test('updateShouldNotifyDependent filters by watched key', () {
      final old = SharedValueInheritedModel(
        changedKeys: const {},
        child: const SizedBox(),
      );
      final current = SharedValueInheritedModel(
        changedKeys: {2},
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
