```dart
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MyBloc(),
      child: MyApp(),
    ),
  );
}

@immutable
sealed class MyEvent {}

final class EventA extends MyEvent {}

final class EventB extends MyEvent {}

@immutable
sealed class MyState {}

final class StateA extends MyState {}

final class StateB extends MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(StateA()) {
    on<EventA>((event, emit) => emit(StateA()));
    on<EventB>((event, emit) => emit(StateB()));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<MyBloc, MyState>(
        builder: (_, state) => state is StateA ? PageA() : PageB(),
      ),
    );
  }
}

class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page A'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Go to PageB'),
          onPressed: () {
            context.read<MyBloc>().add(EventB());
          },
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page B'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Go to PageA'),
          onPressed: () {
            context.read<MyBloc>().add(EventA());
          },
        ),
      ),
    );
  }
}
```
