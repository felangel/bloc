// ignore_for_file: unused_local_variable
import 'package:bloc_lint/bloc_lint.dart';

// Usage: dart run main.dart ./path/to/analyze
void main(List<String> args) {
  // Analyze the provided file or directory and report all diagnostics.
  final diagnostics = const Linter().analyze(uri: Uri.parse(args.first));
}
