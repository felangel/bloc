// ignore_for_file: prefer_file_naming_conventions
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockStorage extends Mock implements Storage {}

class MyCubit extends Cubit<int> with HydratedMixin<int> {
  MyCubit() : super(0);

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic> toJson(int state) => {'value': state};
}

void main() {
  group('HydratedMixin', () {
    late Storage storage;

    setUp(() {
      storage = MockStorage();
    });

    group('hydrate', () {
      test('restores state from cache', () {
        final cubit = MyCubit();
        when(() => storage.read('MyCubit')).thenReturn({'value': 42});
        cubit.hydrate(storage: storage);
        expect(cubit.state, 42);
      });

      test('uses initial state on error by default', () {
        when(() => storage.read('MyCubit')).thenReturn({'value': '42'});
        final cubit = MyCubit()..hydrate(storage: storage);
        expect(cubit.state, 0);
        verify(() => storage.write('MyCubit', {'value': 0})).called(1);
      });

      group('onError', () {
        test('is called when an exception occurs during hydration', () {
          final cubit = MyCubit();
          var onErrorCallCount = 0;

          when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

          cubit.hydrate(
            storage: storage,
            onError: (_, __) {
              onErrorCallCount++;
              return HydrationErrorBehavior.overwrite;
            },
          );
          expect(onErrorCallCount, equals(1));
        });

        group('when error behavior is HydrationErrorBehavior.overwrite', () {
          test('storage.write is always called', () {
            final cubit = MyCubit();
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});
            cubit.hydrate(
              storage: storage,
              onError: (_, __) => HydrationErrorBehavior.overwrite,
            );
            expect(cubit.state, 0);
            verify(() => storage.write('MyCubit', {'value': 0})).called(1);
          });

          test('states emitted in onError are persisted', () {
            final cubit = MyCubit();
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

            cubit.hydrate(
              storage: storage,
              onError: (_, __) {
                cubit.emit(-1);
                return HydrationErrorBehavior.overwrite;
              },
            );
            expect(cubit.state, -1);
            verify(() => storage.write('MyCubit', {'value': -1})).called(1);
          });
        });

        group('when error behavior is HydrationErrorBehavior.retain', () {
          test('storage.write is never called', () {
            final cubit = MyCubit();
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});
            cubit.hydrate(
              storage: storage,
              onError: (_, __) => HydrationErrorBehavior.retain,
            );
            expect(cubit.state, 0);
            verifyNever(() => storage.write(any(), any<dynamic>()));
          });

          test('states emitted in onError are not persisted', () {
            final cubit = MyCubit();
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

            cubit.hydrate(
              storage: storage,
              onError: (_, __) {
                cubit.emit(-1);
                return HydrationErrorBehavior.retain;
              },
            );

            expect(cubit.state, -1);
            verifyNever(() => storage.write(any(), any<dynamic>()));
          });

          test('state changes are not persisted until hydration succeeds', () {
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});
            var cubit = MyCubit();

            cubit
              ..hydrate(
                storage: storage,
                onError: (_, __) {
                  cubit.emit(-1);
                  return HydrationErrorBehavior.retain;
                },
              )
              ..emit(10);

            expect(cubit.state, 10);
            verifyNever(() => storage.write(any(), any<dynamic>()));

            when(() => storage.read('MyCubit')).thenReturn({'value': 42});
            cubit = MyCubit()
              ..hydrate(
                storage: storage,
                onError: (_, __) => HydrationErrorBehavior.retain,
              );

            expect(cubit.state, 42);
            verify(() => storage.write('MyCubit', {'value': 42})).called(1);
          });
        });
      });
    });
  });
}
