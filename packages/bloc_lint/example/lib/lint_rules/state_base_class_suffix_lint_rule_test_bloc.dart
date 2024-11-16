import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class StateBaseClassSuffixLintRuleTestBloc extends Bloc<
    StateBaseClassSuffixLintRuleTestEvent,
// expect_lint: state_base_class_suffix
    StateBaseClassSuffixLintRuleTestError> {
  StateBaseClassSuffixLintRuleTestBloc()
      : super(StateBaseClassSuffixLintRuleTestInitial()) {
    on<StateBaseClassSuffixLintRuleTestEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

@immutable
sealed class StateBaseClassSuffixLintRuleTestEvent {}

@immutable
sealed class StateBaseClassSuffixLintRuleTestError {}

final class StateBaseClassSuffixLintRuleTestInitial
    extends StateBaseClassSuffixLintRuleTestError {}
