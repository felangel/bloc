import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class StateBaseClassSuffixLintRuleTestCubit // expect_lint: state_base_class_suffix
    extends Cubit<StateBaseClassSuffixLintRuleTest> {
  StateBaseClassSuffixLintRuleTestCubit()
      : super(StateBaseClassSuffixLintRuleTestInitial());
}

@immutable
sealed class StateBaseClassSuffixLintRuleTest {}

final class StateBaseClassSuffixLintRuleTestInitial
    extends StateBaseClassSuffixLintRuleTest {}
