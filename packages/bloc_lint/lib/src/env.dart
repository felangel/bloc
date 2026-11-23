import 'dart:core';
import 'dart:io';

import 'package:bloc_lint/src/analysis_options.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

/// The `package_config.json` file path for this project.
String packageConfigPath(Directory cwd) {
  return p.join(cwd.path, '.dart_tool', 'package_config.json');
}

/// The `pubspec.lock` file path for this project.
String pubspecLockPath(Directory cwd) {
  return p.join(cwd.path, 'pubspec.lock');
}

/// The `analysis_options.yaml` file path for this project.
String analysisOptionsPath(Directory cwd) {
  return p.join(cwd.path, 'analysis_options.yaml');
}

/// The `package_config.json` file for this package.
///
/// Returns `null` if the file does not exist or is invalid.
File? findPackageConfigFile(Directory cwd) {
  final root = findProjectRoot(cwd);
  if (root == null) return null;
  final file = File(packageConfigPath(root));
  if (!file.existsSync()) return null;
  return file;
}

/// The nearest `analysis_options.yaml` file relative to the [cwd].
///
/// Like the Dart analyzer, this walks up from [cwd] through its ancestors
/// (including beyond the package root) which allows a single
/// `analysis_options.yaml` to be shared, for example, across a pub workspace.
///
/// Returns `null` if the file does not exist.
File? findAnalysisOptionsFile(Directory cwd) {
  return findNearestAncestor(
    where: (path) => File(analysisOptionsPath(Directory(path))),
    cwd: cwd,
  );
}

/// The resolved `analysis_options.yaml` file for this project.
///
/// Returns `null` if the file does not exist or is invalid.
AnalysisOptions? findAnalysisOptions(Directory cwd) {
  final file = findAnalysisOptionsFile(cwd);
  if (file == null) return null;
  return AnalysisOptions.tryResolve(file);
}

/// The `pubspec.lock` file for this project, parsed into a [PubspecLock]
/// object.
///
/// Returns `null` if the file does not exist or is invalid.
PubspecLock? findPubspecLock(Directory cwd) {
  final root = findProjectRoot(cwd);
  if (root == null) return null;
  final file = File(pubspecLockPath(root));
  if (!file.existsSync()) return null;
  try {
    return PubspecLock.parse(file.readAsStringSync());
  } on Exception {
    return null;
  }
}

/// Returns the root directory of the nearest project.
Directory? findProjectRoot(Directory cwd) {
  final file = findNearestAncestor(
    where: (path) => File(pubspecLockPath(Directory(path))),
    cwd: cwd,
  );
  if (file == null) return null;
  return Directory(p.dirname(file.path));
}

/// Finds nearest ancestor file relative to the [cwd] that satisfies [where].
File? findNearestAncestor({
  required File? Function(String path) where,
  required Directory cwd,
}) {
  Directory? prev;
  var dir = cwd;
  while (prev?.path != dir.path) {
    final file = where(dir.path);
    if (file?.existsSync() ?? false) return file;
    prev = dir;
    dir = dir.parent;
  }
  return null;
}
