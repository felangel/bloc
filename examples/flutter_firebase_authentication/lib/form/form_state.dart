import 'package:meta/meta.dart';

@immutable
abstract class FormState {}

class Initial extends FormState {
  @override
  String toString() => 'Initial';
}

class Editing extends FormState {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool submittedSuccessfully;
  final bool hasError;

  bool get isFormValid => isEmailValid && isPasswordValid;

  Editing({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.submittedSuccessfully,
    @required this.hasError,
  });

  factory Editing.empty() {
    return Editing(
      isEmailValid: false,
      isPasswordValid: false,
      isSubmitting: false,
      submittedSuccessfully: false,
      hasError: false,
    );
  }

  factory Editing.loading() {
    return Editing(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      submittedSuccessfully: false,
      hasError: false,
    );
  }

  factory Editing.failure() {
    return Editing(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      submittedSuccessfully: false,
      hasError: true,
    );
  }

  factory Editing.success() {
    return Editing(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      submittedSuccessfully: true,
      hasError: false,
    );
  }

  Editing update({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
      submittedSuccessfully: false,
      hasError: false,
    );
  }

  Editing copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitting,
    bool submittedSuccessfully,
    bool hasError,
  }) {
    return Editing(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittedSuccessfully:
          submittedSuccessfully ?? this.submittedSuccessfully,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  String toString() {
    return '''Editing {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      submittedSuccessfully: $submittedSuccessfully,
      hasError: $hasError,
    }''';
  }
}
