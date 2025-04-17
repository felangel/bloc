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
      test('can hydrate', () {
        final cubit = MyCubit();
        when(() => storage.read('MyCubit')).thenReturn({'value': 42});

        cubit.hydrate(storage: storage);
        expect(cubit.state, 42);
      });

      group('onHydrationError', () {
        test('gets called when an issue with the hydration happens', () {
          var called = false;
          final cubit = MyCubit();
          // Return an invalid value, the number is a string.
          when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

          cubit.hydrate(
            storage: storage,
            onHydrationError: (_, __) {
              called = true;
              return HydrationErrorBehavior.retain;
            },
          );
          expect(called, isTrue);
        });

        group('when returning HydrationErrorBehavior.retain', () {
          test("don't store the initial state", () {
            final cubit = MyCubit();
            // Return an invalid value, the number is a string.
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

            cubit.hydrate(
              storage: storage,
              onHydrationError: (_, __) {
                return HydrationErrorBehavior.retain;
              },
            );
            expect(cubit.state, 0);
            verifyNever(() => storage.write(any(), any<dynamic>()));
          });

          test('can emit states on the callback, which will not be saved', () {
            final cubit = MyCubit();
            // Return an invalid value, the number is a string.
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

            cubit.hydrate(
              storage: storage,
              onHydrationError: (_, __) {
                cubit.emit(-1);
                return HydrationErrorBehavior.retain;
              },
            );
            expect(cubit.state, -1);
            verifyNever(() => storage.write(any(), any<dynamic>()));
          });

          test('new states are not stored until the hydration succeds', () {
            final cubit = MyCubit();
            // Return an invalid value, the number is a string.
            when(() => storage.read('MyCubit')).thenReturn({'value': '42'});

            cubit
              ..hydrate(
                storage: storage,
                onHydrationError: (_, __) {
                  cubit.emit(-1);
                  return HydrationErrorBehavior.retain;
                },
              )
              ..emit(10);

            expect(cubit.state, 10);
            verifyNever(() => storage.write(any(), any<dynamic>()));

            when(() => storage.read('MyCubit')).thenReturn({'value': 42});
            cubit.hydrate(
              storage: storage,
              onHydrationError: (_, __) {
                return HydrationErrorBehavior.retain;
              },
            );

            expect(cubit.state, 42);
            verify(() => storage.write('MyCubit', {'value': 42})).called(1);
          });
        });
      });
    });
  });
}
