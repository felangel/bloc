import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';

class App extends MaterialApp {
  App({required Repository repository})
      : super(
          home: RepositoryProvider.value(
            value: repository,
            child: const ComplexListPage(),
          ),
        );
}
