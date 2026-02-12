import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockStorage extends Mock implements Storage {}

class ExpiringCounterCubit extends HydratedCubit<int> {
  ExpiringCounterCubit({Storage? storage, Duration? expirationDuration})
      : super(0, storage: storage, expirationDuration: expirationDuration);

  void increment() => emit(state + 1);

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}

class NonExpiringCounterCubit extends HydratedCubit<int> {
  NonExpiringCounterCubit({Storage? storage}) : super(0, storage: storage);

  void increment() => emit(state + 1);

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}

void main() {
  group('HydratedBloc Cache Expiration', () {
    late Storage storage;

    setUp(() {
      storage = MockStorage();
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when(() => storage.delete(any())).thenAnswer((_) async {});
    });

    group('ExpiringCounterCubit', () {
      test('saves state with timestamp when expiration is enabled', () async {
        when<dynamic>(() => storage.read(any())).thenReturn(null);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        )..increment();
        await Future<void>.delayed(Duration.zero);

        final captured = verify(
          () => storage.write('ExpiringCounterCubit', captureAny<dynamic>()),
        ).captured;

        expect(captured, hasLength(2)); // Initial state + increment
        final savedData = captured.last as Map<String, dynamic>;
        expect(savedData.containsKey('__hydrated_state__'), isTrue);
        expect(savedData.containsKey('__hydrated_timestamp__'), isTrue);
        expect(savedData['__hydrated_state__'], {'value': 1});
        expect(savedData['__hydrated_timestamp__'], isA<int>());

        await cubit.close();
      });

      test('restores non-expired state successfully', () async {
        final now = DateTime.now();
        final savedData = {
          '__hydrated_state__': {'value': 42},
          '__hydrated_timestamp__': now.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(savedData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        expect(cubit.state, 42);

        await cubit.close();
      });

      test('does not restore expired state and uses default state', () async {
        final pastTime = DateTime.now().subtract(const Duration(days: 10));
        final expiredData = {
          '__hydrated_state__': {'value': 42},
          '__hydrated_timestamp__': pastTime.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(expiredData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        // Should use default state (0) instead of expired state (42)
        expect(cubit.state, 0);

        await cubit.close();
      });

      test('deletes expired data from storage', () async {
        final pastTime = DateTime.now().subtract(const Duration(days: 10));
        final expiredData = {
          '__hydrated_state__': {'value': 42},
          '__hydrated_timestamp__': pastTime.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(expiredData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        // Verify that delete was called to clear expired data
        await Future<void>.delayed(const Duration(milliseconds: 100));
        verify(() => storage.delete('ExpiringCounterCubit')).called(1);

        await cubit.close();
      });

      test('handles legacy data without expiration wrapper', () async {
        // Old format data without wrapper
        final legacyData = {'value': 99};
        when<dynamic>(() => storage.read(any())).thenReturn(legacyData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        // Should restore legacy data successfully
        expect(cubit.state, 99);

        await cubit.close();
      });

      test('state on exact expiration boundary is considered expired',
          () async {
        final saveTime =
            DateTime.now().subtract(const Duration(days: 7, seconds: 1));
        final boundaryData = {
          '__hydrated_state__': {'value': 42},
          '__hydrated_timestamp__': saveTime.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(boundaryData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        // Should be expired
        expect(cubit.state, 0);

        await cubit.close();
      });
    });

    group('NonExpiringCounterCubit (backward compatibility)', () {
      test('saves state without timestamp wrapper', () async {
        when<dynamic>(() => storage.read(any())).thenReturn(null);

        final cubit = NonExpiringCounterCubit(storage: storage)..increment();
        await Future<void>.delayed(Duration.zero);

        final captured = verify(
          () => storage.write('NonExpiringCounterCubit', captureAny<dynamic>()),
        ).captured;

        expect(captured, hasLength(2));
        final savedData = captured.last as Map<String, dynamic>;
        // Should NOT have expiration wrapper
        expect(savedData.containsKey('__hydrated_state__'), isFalse);
        expect(savedData.containsKey('__hydrated_timestamp__'), isFalse);
        expect(savedData, {'value': 1});

        await cubit.close();
      });

      test('restores state normally without expiration check', () async {
        final savedData = {'value': 42};
        when<dynamic>(() => storage.read(any())).thenReturn(savedData);

        final cubit = NonExpiringCounterCubit(storage: storage);

        expect(cubit.state, 42);

        await cubit.close();
      });

      test('does not delete data even if it has old timestamp', () async {
        // Data with very old timestamp but no expiration configured
        final veryOldTime = DateTime.now().subtract(const Duration(days: 365));
        final oldData = {
          '__hydrated_state__': {'value': 42},
          '__hydrated_timestamp__': veryOldTime.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(oldData);

        final cubit = NonExpiringCounterCubit(storage: storage);

        // Should still restore the data since no expiration is configured
        expect(cubit.state, 42);

        // Should not attempt to delete
        await Future<void>.delayed(const Duration(milliseconds: 100));
        verifyNever(() => storage.delete('NonExpiringCounterCubit'));

        await cubit.close();
      });
    });

    group('Edge cases', () {
      test('handles missing timestamp in wrapped data gracefully', () async {
        final malformedData = {
          '__hydrated_state__': {'value': 42},
          // Missing __hydrated_timestamp__
        };
        when<dynamic>(() => storage.read(any())).thenReturn(malformedData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        // Should restore the state since timestamp is missing
        expect(cubit.state, 42);

        await cubit.close();
      });

      test('handles null state data in wrapper', () async {
        final nullStateData = {
          '__hydrated_state__': null,
          '__hydrated_timestamp__': DateTime.now().millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(nullStateData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(days: 7),
        );

        // Should use default state
        expect(cubit.state, 0);

        await cubit.close();
      });

      test('different expiration durations work correctly', () async {
        // Test with 1 hour expiration
        final oneHourAgo = DateTime.now().subtract(const Duration(minutes: 30));
        final recentData = {
          '__hydrated_state__': {'value': 100},
          '__hydrated_timestamp__': oneHourAgo.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(recentData);

        final cubit = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(hours: 1),
        );

        // Should restore since only 30 minutes passed
        expect(cubit.state, 100);

        await cubit.close();

        // Now test with expired
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        final oldData = {
          '__hydrated_state__': {'value': 200},
          '__hydrated_timestamp__': twoHoursAgo.millisecondsSinceEpoch,
        };
        when<dynamic>(() => storage.read(any())).thenReturn(oldData);

        final cubit2 = ExpiringCounterCubit(
          storage: storage,
          expirationDuration: const Duration(hours: 1),
        );

        // Should use default state since > 1 hour passed
        expect(cubit2.state, 0);

        await cubit2.close();
      });
    });
  });
}
