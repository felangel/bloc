import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class EventBaseClassSuffixLintRuleTestBloc extends Bloc<
// expect_lint: event_base_class_suffix
    EventBaseClassSuffixLintRuleTestError,
    EventBaseClassSuffixLintRuleTestState> {
  EventBaseClassSuffixLintRuleTestBloc()
      : super(EventBaseClassSuffixLintRuleTestInitial()) {
    on<EventBaseClassSuffixLintRuleTestError>((event, emit) {
      // TODO: implement event handler
    });
  }
}

@immutable
sealed class EventBaseClassSuffixLintRuleTestError {}

@immutable
sealed class EventBaseClassSuffixLintRuleTestState {}

final class EventBaseClassSuffixLintRuleTestInitial
    extends EventBaseClassSuffixLintRuleTestState {}
