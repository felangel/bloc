// ignore_for_file: avoid_print, require_trailing_commas
import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final projectRoot = flutterCreate();

  installBloc(projectRoot);
  installBlocLint(projectRoot);
  createAnalysisOptions(projectRoot);
  createCubit(projectRoot);

  final actual = lint(projectRoot);
  const expected = '''
warning[avoid_flutter_imports]: Avoid importing Flutter within cubit instances.
 --> lib/counter_cubit.dart:1
  |
  | import 'package:flutter/material.dart';
  |        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  = hint: Cubits should be decoupled from Flutter.
 docs: https://bloclibrary.dev/lint-rules/avoid_flutter_imports

1 issue found
Analyzed 2 files
''';
  if (!actual.contains(expected)) {
    throw Exception('''
FAIL

Expected ↓
$expected

Actual ↓
$actual
''');
  }
  print('PASS');
  Directory(projectRoot).deleteSync(recursive: true);
}

String flutterCreate() {
  final tempDir = Directory.systemTemp.createTempSync();
  const projectName = 'example';
  exec('flutter', [
    'create',
    '-e',
    projectName,
  ], workingDirectory: tempDir.path);
  return p.join(tempDir.path, projectName);
}

String exec(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  int? exitCode = 0,
}) {
  final result = Process.runSync(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != exitCode) {
    throw Exception('''
Error running "$executable ${arguments.join(' ')}"
Exited with code: ${result.exitCode}
stdout: ${result.stdout}
stderr: ${result.stderr}
''');
  }
  return result.stdout as String;
}

void installBloc(String projectRoot) {
  exec('flutter', ['pub', 'add', 'bloc'], workingDirectory: projectRoot);
}

void installBlocLint(String projectRoot) {
  exec('flutter', [
    'pub',
    'add',
    '--dev',
    'bloc_lint:^0.2.0-dev',
  ], workingDirectory: projectRoot);
}

void createAnalysisOptions(String projectRoot) {
  File(p.join(projectRoot, 'analysis_options.yaml')).writeAsStringSync('''
include: package:bloc_lint/recommended.yaml
''');
}

void createCubit(String projectRoot) {
  File(p.join(projectRoot, 'lib', 'counter_cubit.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''');
}

String lint(String projectRoot) {
  return exec(
    'bloc',
    ['lint', '.'],
    workingDirectory: projectRoot,
    exitCode: 1,
  );
}
