import 'package:flutter_bloc/flutter_bloc.dart';

class AvoidPublicMethodOnBlocBloc extends Bloc<int, int> {
  AvoidPublicMethodOnBlocBloc(super.initialState);

  // expect_lint: avoid_public_methods_on_bloc
  void publicMethod() {}

  void _privateMethod() {}
}
