import 'package:bloc_tools/src/commands/new/bundles/bloc_bundle.dart';
import 'package:bloc_tools/src/commands/new/bundles/cubit_bundle.dart';
import 'package:bloc_tools/src/commands/new/bundles/hydrated_bloc_bundle.dart';
import 'package:bloc_tools/src/commands/new/bundles/hydrated_cubit_bundle.dart';
import 'package:bloc_tools/src/commands/new/bundles/replay_bloc_bundle.dart';
import 'package:bloc_tools/src/commands/new/bundles/replay_cubit_bundle.dart';

/// All the supported bundles.
final bundles = [
  blocBundle,
  cubitBundle,
  hydratedBlocBundle,
  hydratedCubitBundle,
  replayBlocBundle,
  replayCubitBundle,
];
