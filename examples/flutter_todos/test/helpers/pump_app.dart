import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    TodosRepository? todosRepository,
  }) {
    return pumpWidget(
      RepositoryProvider.value(
        value: todosRepository ?? MockTodosRepository(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    TodosRepository? todosRepository,
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      todosRepository: todosRepository,
    );
  }
}
