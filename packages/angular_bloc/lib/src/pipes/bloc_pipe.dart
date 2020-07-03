import 'package:angular/core.dart' show ChangeDetectorRef, Pipe;
import 'package:angular_cubit/angular_cubit.dart';
import 'package:bloc/bloc.dart';

/// {@template blocpipe}
/// A `pipe` which helps bind [Bloc] state changes to the presentation layer.
/// [BlocPipe] handles rendering the html element in response to new states.
/// [BlocPipe] is very similar to `AsyncPipe` but has simplified API
/// to reduce the amount of boilerplate code needed.
/// {@endtemplate}
@Pipe('bloc', pure: false)
class BlocPipe extends CubitPipe {
  /// {@macro blocpipe}
  BlocPipe(ChangeDetectorRef ref) : super(ref);
}
