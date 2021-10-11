import 'package:flutter/material.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children: const [
        TodosOverviewPage(),
      ],
    );
  }
}
