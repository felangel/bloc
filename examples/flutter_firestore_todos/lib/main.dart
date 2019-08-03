import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firestore_todos/blocs/authentication_bloc/bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';
import 'package:flutter_firestore_todos/screens/screens.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(TodosApp());
}

class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          builder: (context) {
            return AuthenticationBloc(
              userRepository: FirebaseUserRepository(),
            )..dispatch(AppStarted());
          },
        ),
        BlocProvider<TodosBloc>(
          builder: (context) {
            return TodosBloc(
              todosRepository: FirebaseTodosRepository(),
            )..dispatch(LoadTodos());
          },
        )
      ],
      child: MaterialApp(
        title: 'Firestore Todos',
        routes: {
          '/': (context) {
            return BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  final todosBloc = BlocProvider.of<TodosBloc>(context);
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider<TabBloc>(
                        builder: (context) => TabBloc(),
                      ),
                      BlocProvider<FilteredTodosBloc>(
                        builder: (context) =>
                            FilteredTodosBloc(todosBloc: todosBloc),
                      ),
                      BlocProvider<StatsBloc>(
                        builder: (context) => StatsBloc(todosBloc: todosBloc),
                      ),
                    ],
                    child: HomeScreen(),
                  );
                }
                if (state is Unauthenticated) {
                  return Center(
                    child: Text('Could not authenticate with Firestore'),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            );
          },
          '/addTodo': (context) {
            final todosBloc = BlocProvider.of<TodosBloc>(context);
            return AddEditScreen(
              onSave: (task, note) {
                todosBloc.dispatch(
                  AddTodo(Todo(task, note: note)),
                );
              },
              isEditing: false,
            );
          },
        },
      ),
    );
  }
}
