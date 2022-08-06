import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/app.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_complex_list/simple_bloc_observer.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(App(repository: Repository()));
}
