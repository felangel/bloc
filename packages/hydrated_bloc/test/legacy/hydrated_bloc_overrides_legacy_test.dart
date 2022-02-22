// ignore_for_file: deprecated_member_use_from_same_package

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class FakeBlocObserver extends Fake implements BlocObserver {}

class FakeStorage extends Fake implements Storage {}

void main() {
  group('HydratedBlocOverrides (legacy)', () {
    group('runZoned', () {
      test('uses default BlocObserver when not specified', () {
        HydratedBlocOverrides.runZoned(() {
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.blocObserver, isA<BlocObserver>());
        });
      });

      test('uses default EventTransformer when not specified', () {
        HydratedBlocOverrides.runZoned(() {
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.eventTransformer, isA<EventTransformer>());
        });
      });

      test('uses default storage when not specified', () {
        HydratedBlocOverrides.runZoned(() {
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.storage, isA<Storage>());
        });
      });

      test('uses custom BlocObserver when specified', () {
        final blocObserver = FakeBlocObserver();
        HydratedBlocOverrides.runZoned(() {
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.blocObserver, equals(blocObserver));
        }, blocObserver: blocObserver);
      });

      test('uses custom EventTransformer when specified', () {
        final eventTransformer = (Stream events, EventMapper mapper) {
          return events.asyncExpand<dynamic>(mapper);
        };
        HydratedBlocOverrides.runZoned(() {
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.eventTransformer, equals(eventTransformer));
        }, eventTransformer: eventTransformer);
      });

      test('uses custom storage when specified', () {
        final storage = FakeStorage();
        HydratedBlocOverrides.runZoned(() {
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.storage, equals(storage));
        }, storage: storage);
      });

      test(
          'uses current BlocObserver when not specified '
          'and zone already contains a BlocObserver', () {
        final blocObserver = FakeBlocObserver();
        HydratedBlocOverrides.runZoned(() {
          HydratedBlocOverrides.runZoned(() {
            final overrides = HydratedBlocOverrides.current;
            expect(overrides!.blocObserver, equals(blocObserver));
          });
        }, blocObserver: blocObserver);
      });

      test(
          'uses current EventTransformer when not specified '
          'and zone already contains an EventTransformer', () {
        final eventTransformer = (Stream events, EventMapper mapper) {
          return events.asyncExpand<dynamic>(mapper);
        };
        HydratedBlocOverrides.runZoned(() {
          HydratedBlocOverrides.runZoned(() {
            final overrides = HydratedBlocOverrides.current;
            expect(overrides!.eventTransformer, equals(eventTransformer));
          });
        }, eventTransformer: eventTransformer);
      });

      test(
          'uses nested BlocObserver when specified '
          'and zone already contains a BlocObserver', () {
        final rootBlocObserver = FakeBlocObserver();
        HydratedBlocOverrides.runZoned(() {
          final nestedBlocObserver = FakeBlocObserver();
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.blocObserver, equals(rootBlocObserver));
          HydratedBlocOverrides.runZoned(() {
            final overrides = HydratedBlocOverrides.current;
            expect(overrides!.blocObserver, equals(nestedBlocObserver));
          }, blocObserver: nestedBlocObserver);
        }, blocObserver: rootBlocObserver);
      });

      test(
          'uses nested EventTransformer when specified '
          'and zone already contains an EventTransformer', () {
        final rootEventTransformer = (Stream events, EventMapper mapper) {
          return events.asyncExpand<dynamic>(mapper);
        };
        HydratedBlocOverrides.runZoned(() {
          final nestedEventTransformer = (Stream events, EventMapper mapper) {
            return events.asyncExpand<dynamic>(mapper);
          };
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.eventTransformer, equals(rootEventTransformer));
          HydratedBlocOverrides.runZoned(() {
            final overrides = HydratedBlocOverrides.current;
            expect(overrides!.eventTransformer, equals(nestedEventTransformer));
          }, eventTransformer: nestedEventTransformer);
        }, eventTransformer: rootEventTransformer);
      });

      test(
          'uses nested storage when specified '
          'and zone already contains a storage', () {
        final rootStorage = FakeStorage();
        HydratedBlocOverrides.runZoned(() {
          final nestedStorage = FakeStorage();
          final overrides = HydratedBlocOverrides.current;
          expect(overrides!.storage, equals(rootStorage));
          HydratedBlocOverrides.runZoned(() {
            final overrides = HydratedBlocOverrides.current;
            expect(overrides!.storage, equals(nestedStorage));
          }, storage: nestedStorage);
        }, storage: rootStorage);
      });

      test('uses parent storage when nested zone does not specify', () {
        final storage = FakeStorage();
        HydratedBlocOverrides.runZoned(() {
          HydratedBlocOverrides.runZoned(() {
            final overrides = HydratedBlocOverrides.current;
            expect(overrides!.storage, equals(storage));
          });
        }, storage: storage);
      });

      test(
          'uses parent BlocOverrides BlocObserver '
          'when nested zone does not specify', () {
        final blocObserver = FakeBlocObserver();
        BlocOverrides.runZoned(() {
          HydratedBlocOverrides.runZoned(() {
            final hydratedOverrides = HydratedBlocOverrides.current;
            expect(hydratedOverrides!.blocObserver, equals(blocObserver));
            final overrides = BlocOverrides.current;
            expect(overrides!.blocObserver, equals(blocObserver));
          });
        }, blocObserver: blocObserver);
      });

      test(
          'uses nested BlocObserver '
          'when nested zone does specify and parent BlocOverrides '
          'specifies a different BlocObserver', () {
        final storage = FakeStorage();
        final rootBlocObserver = FakeBlocObserver();
        final nestedBlocObserver = FakeBlocObserver();
        BlocOverrides.runZoned(() {
          final overrides = BlocOverrides.current;
          expect(overrides!.blocObserver, equals(rootBlocObserver));
          HydratedBlocOverrides.runZoned(
            () {
              final overrides = HydratedBlocOverrides.current!;
              expect(overrides.blocObserver, equals(nestedBlocObserver));
              expect(overrides.storage, equals(storage));
            },
            blocObserver: nestedBlocObserver,
            storage: storage,
          );
        }, blocObserver: rootBlocObserver);
      });

      test('overrides cannot be mutated after zone is created', () {
        final originalStorage = FakeStorage();
        final otherStorage = FakeStorage();
        var storage = originalStorage;
        HydratedBlocOverrides.runZoned(() {
          storage = otherStorage;
          final overrides = HydratedBlocOverrides.current!;
          expect(overrides.storage, equals(originalStorage));
          expect(overrides.storage, isNot(equals(otherStorage)));
        }, storage: storage);
      });
    });
  });
}
