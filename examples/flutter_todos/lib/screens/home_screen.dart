import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/blocs/blocs.dart';
import 'package:flutter_todos/widgets/widgets.dart';
import 'package:flutter_todos/localization.dart';
import 'package:flutter_todos/models/models.dart';

class HomeScreen extends StatefulWidget {
  final void Function() onInit;

  HomeScreen({@required this.onInit}) : super(key: ArchSampleKeys.homeScreen);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TabBloc _tabBloc = TabBloc();
  FilteredTodosBloc _filteredTodosBloc;
  StatsBloc _statsBloc;

  @override
  void initState() {
    widget.onInit();
    _filteredTodosBloc = FilteredTodosBloc(
      todosBloc: BlocProvider.of<TodosBloc>(context),
    );
    _statsBloc = StatsBloc(
      todosBloc: BlocProvider.of<TodosBloc>(context),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _tabBloc,
      builder: (BuildContext context, AppTab activeTab) {
        return BlocProviderTree(
          blocProviders: [
            BlocProvider<TabBloc>(bloc: _tabBloc),
            BlocProvider<FilteredTodosBloc>(bloc: _filteredTodosBloc),
            BlocProvider<StatsBloc>(bloc: _statsBloc),
          ],
          child: Scaffold(
            appBar: AppBar(
              title: Text(FlutterBlocLocalizations.of(context).appTitle),
              actions: [
                FilterButton(visible: activeTab == AppTab.todos),
                ExtraActions(),
              ],
            ),
            body: activeTab == AppTab.todos ? FilteredTodos() : Stats(),
            floatingActionButton: FloatingActionButton(
              key: ArchSampleKeys.addTodoFab,
              onPressed: () {
                Navigator.pushNamed(context, ArchSampleRoutes.addTodo);
              },
              child: Icon(Icons.add),
              tooltip: ArchSampleLocalizations.of(context).addTodo,
            ),
            bottomNavigationBar: TabSelector(
              activeTab: activeTab,
              onTabSelected: (tab) => _tabBloc.dispatch(UpdateTab(tab)),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _statsBloc.dispose();
    _filteredTodosBloc.dispose();
    _tabBloc.dispose();
    super.dispose();
  }
}
