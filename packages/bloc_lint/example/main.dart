// ignore_for_file: unused_local_variable
import 'package:bloc_lint/bloc_lint.dart';

void main(List<String> args) {
  final diagnostics = const Linter().analyze(uri: Uri.parse(args.first));
}
