import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/list/list.dart';
import 'package:flutter_complex_list/repository.dart';

class App extends MaterialApp {
  App()
      : super(
          home: BlocProvider(
            create: (_) => ListCubit(repository: Repository())..fetchList(),
            child: ListPage(),
          ),
        );
}
