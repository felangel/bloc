import 'dart:core';
import 'dart:io';
import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_lint/src/analysis_options.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

/// The `pubspec.lock` file path for this project.
String getPubspecLockPath(Directory cwd) {
  return p.join(cwd.path, 'pubspec.lock');
}

/// The `analysis_options.yaml` file path for this project.
String getAnalysisOptionsPath(Directory cwd) {
  return p.join(cwd.path, 'analysis_options.yaml');
}

/// Gets the list of [Glob] patterns to be excluded for this project.
List<Glob> getExcludes(Directory cwd) {
  final analysisOptions = findAnalysisOptions(cwd);
  if (analysisOptions == null) return <Glob>[];
  final excludes = analysisOptions.yaml.analyzer?.exclude ?? <String>[];
  final context = p.Context(current: analysisOptions.file.parent.path);
  return excludes.map((e) => Glob(e, context: context)).toList();
}

/// Gets the list of [LintRule] for this project.
List<LintRule> getLintRules(Directory cwd) {
  final analysisOptions = findAnalysisOptions(cwd);
  if (analysisOptions == null) return [];
  final blocAnalysis = analysisOptions.yaml.bloc;
  if (blocAnalysis == null) return [];
  return blocAnalysis.rules.entries
      .map((analysisEntry) {
        final rule = analysisEntry.key;
        final state = analysisEntry.value;
        if (state.isDisabled) return null;
        final entry = allRules.entries.firstWhereOrNull((e) => e.key == rule);
        if (entry == null) return null;
        final builder = entry.value;
        final severity = state.toSeverity(fallback: builder().severity);
        return builder(severity);
      })
      .whereType<LintRule>()
      .toList();
}

/// The `analysis_options.yaml` file for this project.
///
/// Returns `null` if the file does not exist or is invalid.
File? getAnalysisOptionsFile(Directory cwd) {
  final root = getProjectRoot(cwd);
  if (root == null) return null;
  final file = File(getAnalysisOptionsPath(root));
  if (!file.existsSync()) return null;
  return file;
}

/// The parsed `analysis_options.yaml` file for this project.
///
/// Returns `null` if the file does not exist or is invalid.
AnalysisOptions? findAnalysisOptions(Directory cwd) {
  final file = getAnalysisOptionsFile(cwd);
  if (file == null) return null;
  return AnalysisOptions.tryParse(file);
}

/// The `pubspec.lock` file for this project, parsed into a [PubspecLock]
/// object.
///
/// Returns `null` if the file does not exist or is invalid.
PubspecLock? getPubspecLock(Directory cwd) {
  final root = getProjectRoot(cwd);
  if (root == null) return null;
  final file = File(getPubspecLockPath(root));
  if (!file.existsSync()) return null;
  try {
    return PubspecLock.parse(file.readAsStringSync());
  } on Exception catch (_) {
    return null;
  }
}

/// Returns the root directory of the nearest project.
Directory? getProjectRoot(Directory cwd) {
  final file = findNearestAncestor(
    where: (path) => File(getPubspecLockPath(Directory(path))),
    cwd: cwd,
  );
  if (file == null) return null;
  return Directory(p.dirname(file.path));
}

/// Finds nearest ancestor file relative to the [cwd] that satisfies [where].
File? findNearestAncestor({
  required File? Function(String path) where,
  Directory? cwd,
}) {
  Directory? prev;
  var dir = cwd ?? Directory.current;
  while (prev?.path != dir.path) {
    final file = where(dir.path);
    if (file?.existsSync() ?? false) return file;
    prev = dir;
    dir = dir.parent;
  }
  return null;
}
