import 'package:bloc_lint_example/sample_cubit/cubit_a_cubit.dart';
import 'package:bloc_lint_example/sample_cubit/cubit_b_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final expectPreferMultiBlocProvider = BlocProvider(
    create: (_) => ACubit(),
    // expect_lint: prefer_multi_bloc_provider
    child: BlocProvider(
      create: (_) => BCubit(),
    ),
  );

  final dontExpectPreferMultiBlocProvider = MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ACubit()),
      BlocProvider(create: (_) => BCubit()),
    ],
    child: Container(),
  );
}
