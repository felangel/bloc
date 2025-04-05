import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/commands/commands.dart';
import 'package:bloc_tools/src/commands/new/bundles/bundles.dart' show bundles;
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

class _MockMasonBundle extends Mock implements MasonBundle {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockGeneratorHooks extends Mock implements GeneratorHooks {}

class _FakeGeneratorTarget extends Fake implements GeneratorTarget {}

void main() {
  group('bloc new', () {
    late Logger logger;
    late NewCommand command;

    setUp(() {
      logger = _MockLogger();
      command = NewCommand(logger: logger);
    });

    test('has correct name, description, and subcommands', () {
      expect(command.name, equals('new'));
      expect(command.description, equals('Generate new bloc components.'));
      expect(
        command.subcommands,
        isA<Map<String, Command<int>>>()
            .having(
              (commands) => commands.keys,
              'names',
              equals(bundles.map((b) => b.name)),
            )
            .having(
              (commands) => commands.values.map((c) => c.description),
              'descriptions',
              equals(bundles.map((b) => b.description)),
            ),
      );
    });
  });

  group(GeneratorCommand, () {
    late MasonBundle bundle;
    late MasonGenerator generator;
    late GeneratorHooks hooks;
    late Progress progress;
    late Logger logger;
    late GeneratorCommand command;

    setUpAll(() {
      registerFallbackValue(_FakeGeneratorTarget());
    });

    setUp(() {
      bundle = _MockMasonBundle();
      generator = _MockMasonGenerator();
      hooks = _MockGeneratorHooks();
      logger = _MockLogger();
      progress = _MockProgress();

      when(() => bundle.name).thenReturn('name');
      when(() => bundle.description).thenReturn('description');
      when(() => bundle.version).thenReturn('1.0.0+1');
      when(() => bundle.vars).thenReturn({
        'array': const BrickVariableProperties.array(
          description: 'array description',
          values: ['a', 'b', 'c'],
          defaultValues: ['a'],
        ),
        'list': const BrickVariableProperties.list(
          description: 'list description',
          separator: ',',
        ),
        'enum': const BrickVariableProperties.enumeration(
          description: 'enum description',
          values: ['a', 'b', 'c'],
          defaultValue: 'a',
        ),
        'number': const BrickVariableProperties.number(
          description: 'number description',
          defaultValue: 42,
        ),
        'string': const BrickVariableProperties.string(
          description: 'string description',
          defaultValue: 'hello',
        ),
        'bool': const BrickVariableProperties.boolean(
          description: 'bool description',
          defaultValue: true,
        ),
      });
      when(() => logger.progress(any())).thenReturn(progress);
      when(() => generator.hooks).thenReturn(hooks);
      when(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          logger: any(named: 'logger'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => hooks.preGen(
          vars: any(named: 'vars'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => hooks.postGen(
          vars: any(named: 'vars'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).thenAnswer((_) async {});

      command = GeneratorCommand(
        logger: logger,
        bundle: bundle,
        generatorFromBrick: (_) async => generator,
        generatorFromBundle: (_) async => generator,
      );
    });

    group('--output-directory', () {
      test('defaults to "."', () {
        expect(command.outputDirectory.path, equals('.'));
      });
    });

    group('run', () {
      test('completes using hosted brick', () async {
        var generatorFromBrickCallCount = 0;
        final command = GeneratorCommand(
          logger: logger,
          bundle: bundle,
          generatorFromBrick: (_) async {
            generatorFromBrickCallCount++;
            return generator;
          },
        );
        final runner = _TestCommandRunner(command: command);
        await expectLater(
          runner.run([command.name]),
          completion(equals(ExitCode.success.code)),
        );
        expect(generatorFromBrickCallCount, equals(1));
      });

      test('falls back to bundle', () async {
        var generatorFromBrickCallCount = 0;
        var generatorFromBundleCallCount = 0;
        final command = GeneratorCommand(
          logger: logger,
          bundle: bundle,
          generatorFromBrick: (_) async {
            generatorFromBrickCallCount++;
            throw Exception('oops');
          },
          generatorFromBundle: (_) async {
            generatorFromBundleCallCount++;
            return generator;
          },
        );
        final runner = _TestCommandRunner(command: command);
        await expectLater(
          runner.run([command.name]),
          completion(equals(ExitCode.success.code)),
        );
        expect(generatorFromBrickCallCount, equals(1));
        expect(generatorFromBundleCallCount, equals(1));
      });
    });
  });
}

class _TestCommandRunner extends CommandRunner<int> {
  _TestCommandRunner({required GeneratorCommand command}) : super('', '') {
    addCommand(command);
  }
}
