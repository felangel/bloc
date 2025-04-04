import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/commands/new/bundles/bundles.dart';
import 'package:mason/mason.dart';

/// Signature for [MasonGenerator.fromBundle].
typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

/// Signature for [MasonGenerator.fromBrick].
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

/// {@template new_command}
/// The `bloc new <template>` command generates code from various templates.
/// {@endtemplate}
class NewCommand extends Command<int> {
  /// {@macro new_command}
  NewCommand({required Logger logger}) {
    for (final bundle in bundles) {
      addSubcommand(GeneratorCommand(bundle: bundle, logger: logger));
    }
  }

  @override
  String get summary => '$invocation\n$description';

  @override
  String get description => 'Generate new bloc components.';

  @override
  String get name => 'new';
}

/// {@template generator_subcommand}
/// A generic command for generating code from a brick or bundle.
/// {@endtemplate}
class GeneratorCommand extends Command<int> {
  /// {@macro generator_command}
  GeneratorCommand({
    required this.logger,
    required this.bundle,
    MasonGeneratorFromBrick? generatorFromBrick,
    MasonGeneratorFromBundle? generatorFromBundle,
  }) : _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick,
       _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle {
    argParser
      ..addOptionsForBundle(bundle)
      ..addOption(
        'output-directory',
        abbr: 'o',
        help: 'The desired output directory.',
      );
  }

  /// The logger user to notify the user of the command's progress.
  final Logger logger;

  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  /// The desired output [Directory].
  /// Specified via --output-directory and defaults to `.`.
  Directory get outputDirectory {
    return Directory(argResults?['output-directory'] as String? ?? '.');
  }

  /// The bundle used for generation.
  final MasonBundle bundle;

  @override
  String get name => bundle.name;

  @override
  String get description => bundle.description;

  Map<String, dynamic> get _vars => {
    for (final entry in bundle.vars.entries) entry.key: argResults![entry.key],
  };

  @override
  Future<int> run() async {
    final generator = await _buildGenerator();
    final generateProgress = logger.progress('Generating');
    final target = DirectoryGeneratorTarget(outputDirectory);
    var vars = _vars;
    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);
    final files = await generator.generate(target, vars: vars, logger: logger);
    generateProgress.complete('Generated ${files.length} file(s)');
    logger.flush((message) => logger.info(darkGray.wrap(message)));

    return ExitCode.success.code;
  }

  Future<MasonGenerator> _buildGenerator() async {
    try {
      final brick = Brick.version(
        name: bundle.name,
        version: '^${bundle.version}',
      );
      logger.detail(
        '''Building generator from brick: ${brick.name} ${brick.location.version}''',
      );
      return await _generatorFromBrick(brick);
    } on Exception catch (error) {
      logger.detail('Building generator from brick failed: $error');
    }
    logger.detail(
      '''Building generator from bundle ${bundle.name} ${bundle.version}''',
    );
    return _generatorFromBundle(bundle);
  }
}

extension on ArgParser {
  void addOptionsForBundle(MasonBundle bundle) {
    for (final entry in bundle.vars.entries) {
      final name = entry.key;
      final properties = entry.value;
      final type = properties.type;
      switch (type) {
        case BrickVariableType.array:
        case BrickVariableType.list:
          addMultiOption(
            name,
            help: properties.description,
            allowed: properties.values,
            defaultsTo: properties.defaultValues as Iterable<String>?,
          );
        case BrickVariableType.enumeration:
          addOption(
            name,
            help: properties.description,
            mandatory: properties.defaultValue == null,
            allowed: properties.values,
            defaultsTo: properties.defaultValue as String?,
          );
        case BrickVariableType.number:
        case BrickVariableType.string:
          addOption(
            name,
            help: properties.description,
            mandatory: properties.defaultValue == null,
            defaultsTo: properties.defaultValue?.toString(),
          );
        case BrickVariableType.boolean:
          addFlag(
            name,
            help: properties.description,
            defaultsTo: properties.defaultValue as bool?,
          );
      }
    }
  }
}
