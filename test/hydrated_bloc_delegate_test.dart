import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:platform/platform.dart';

class MockBloc extends Mock implements HydratedBloc<dynamic, dynamic> {}

class MockStorage extends Mock implements HydratedBlocStorage {}

void main() {
  MockStorage storage;
  HydratedBlocDelegate delegate;
  MockBloc bloc;

  setUp(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    String response = '.';

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return response;
    });

    storage = MockStorage();
    delegate = HydratedBlocDelegate(storage);
    bloc = MockBloc();
  });

  tearDown(() async {
    final file = File('./.hydrated_bloc.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('HydratedBlocDelegate', () {
    test(
        'should call storage.write when onTransition is called using the static build',
        () async {
      delegate = await HydratedBlocDelegate.build(
        FakePlatform(operatingSystem: 'ios'),
      );
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      Map<String, String> expected = {'nextState': 'json'};
      when(bloc.id).thenReturn('');
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
    });

    test(
        'should call storage.write when onTransition is called using the static build with bloc id',
        () async {
      delegate = await HydratedBlocDelegate.build(
        FakePlatform(operatingSystem: 'ios'),
      );
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      Map<String, String> expected = {'nextState': 'json'};
      when(bloc.id).thenReturn('A');
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      expect(delegate.storage.read('MockBlocA'), '{"nextState":"json"}');
    });

    test('should call storage.write when onTransition is called', () {
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      Map<String, String> expected = {'nextState': 'json'};
      when(bloc.id).thenReturn('');
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      verify(storage.write('MockBloc', json.encode(expected))).called(1);
    });

    test('should call storage.write when onTransition is called with bloc id',
        () {
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      Map<String, String> expected = {'nextState': 'json'};
      when(bloc.id).thenReturn('A');
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      verify(storage.write('MockBlocA', json.encode(expected))).called(1);
    });
  });
}
