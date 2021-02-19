import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos_cubit/simple_bloc_observer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos_cubit/localization.dart';
import 'package:flutter_todos_cubit/cubits/cubits.dart';
import 'package:flutter_todos_cubit/models/models.dart';
import 'package:flutter_todos_cubit/screens/screens.dart';

void main() {
  // We can set a Bloc's observer to an instance of `SimpleBlocObserver`.
  // This will allow us to handle all transitions and errors in SimpleBlocObserver.
  Bloc.observer = SimpleBlocObserver();
  runApp(
    BlocProvider(
      create: (context) {
        return TodosCubit(
          todosRepository: const TodosRepositoryFlutter(
            fileStorage: const FileStorage(
              '__flutter_bloc_app__',
              getApplicationDocumentsDirectory,
            ),
          ),
        )..todosLoaded();
      },
      child: TodosApp(),
    ),
  );
}

class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlutterBlocLocalizations().appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        FlutterBlocLocalizationsDelegate(),
      ],
      routes: {
        ArchSampleRoutes.home: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<TabCubit>(
                create: (context) => TabCubit(),
              ),
              BlocProvider<FilteredTodosCubit>(
                create: (context) => FilteredTodosCubit(
                  todosCubit: BlocProvider.of<TodosCubit>(context),
                ),
              ),
              BlocProvider<StatsCubit>(
                create: (context) => StatsCubit(
                  todosCubit: BlocProvider.of<TodosCubit>(context),
                ),
              ),
            ],
            child: HomeScreen(),
          );
        },
        ArchSampleRoutes.addTodo: (context) {
          return AddEditScreen(
            key: ArchSampleKeys.addTodoScreen,
            onSave: (task, note) {
              BlocProvider.of<TodosCubit>(context)
                .todoAdded(Todo(task, note: note),
              );
            },
            isEditing: false,
          );
        },
      },
    );
  }
}
