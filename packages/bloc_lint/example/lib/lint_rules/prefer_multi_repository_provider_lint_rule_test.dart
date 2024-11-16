import 'package:bloc_lint_example/sample_repository/repository_a.dart';
import 'package:bloc_lint_example/sample_repository/repository_b.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final expectPreferMultiRepositoryProvider = RepositoryProvider(
    create: (_) => RepositoryA(),
    // expect_lint: prefer_multi_repository_provider
    child: RepositoryProvider(
      create: (_) => RepositoryB(),
    ),
  );

  final dontExpectPreferMultiBlocProvider = MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (_) => RepositoryA()),
      RepositoryProvider(create: (_) => RepositoryB()),
    ],
    child: Container(),
  );
}
