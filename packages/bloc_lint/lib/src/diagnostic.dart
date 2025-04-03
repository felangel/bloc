import 'package:bloc_lint/bloc_lint.dart';

/// The severity of the reported lint rule.
enum Severity {
  /// The diagnostic is reported as an error.
  error,

  /// The diagnostic is reported as an warning.
  warning,

  /// The diagnostic is reported as info.
  info,

  /// The diagnostic is reported as a hint.
  hint,
}

/// {@template diagnostic}
/// A diagnostic which is reported by a lint rule.
/// {@endtemplate}
class Diagnostic {
  /// {@macro diagnostic}
  const Diagnostic({
    required this.range,
    required this.source,
    required this.message,
    required this.description,
    required this.code,
    required this.severity,
    this.hint = '',
  });

  /// The affected range.
  final Range range;

  /// The source of the lint rule (e.g. who reported it).
  final String source;

  /// The message associated with the lint.
  final String message;

  /// An optional property to describe the error code.
  final String description;

  /// A hint or recommendation usually presented to the user.
  final String hint;

  /// The diagnostic's code, which usually appear in the user interface.
  final String code;

  /// The severity level of the lint.
  final Severity severity;

  /// Converts a [Diagnostic] to a [Map].
  Map<String, dynamic> toJson() {
    return {
      'range': range.toJson(),
      'source': source,
      'message': message,
      'description': description,
      'hint': hint,
      'code': code,
      'severity': severity.name,
    };
  }
}
