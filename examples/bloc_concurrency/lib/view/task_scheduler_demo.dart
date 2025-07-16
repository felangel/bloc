import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/view/task_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo app for task scheduling using different BLoC concurrency strategies.
class TaskSchedulerDemo extends StatefulWidget {
  /// Creates an instance of [TaskSchedulerDemo].
  const TaskSchedulerDemo({super.key});

  @override
  State<TaskSchedulerDemo> createState() => _TaskSchedulerDemoState();
}

class _TaskSchedulerDemoState extends State<TaskSchedulerDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SequentialTaskBloc()),
        BlocProvider(create: (_) => ConcurrentTaskBloc()),
        BlocProvider(create: (_) => DroppableTaskBloc()),
        BlocProvider(create: (_) => RestartableTaskBloc()),
        BlocProvider(create: (_) => DebounceTaskBloc()),
        BlocProvider(create: (_) => ThrottleTaskBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Task Scheduler - BLoC Concurrency Transformers Demo',
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sequential'),
              Tab(text: 'Concurrent'),
              Tab(text: 'Droppable'),
              Tab(text: 'Restartable'),
              Tab(text: 'Debounce'),
              Tab(text: 'Throttle'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            TaskTab<SequentialTaskBloc>(
              title: 'Sequential Tasks',
              description:
                  'One task at a time - each task waits for previous to finish',
              color: Colors.blue,
            ),
            TaskTab<ConcurrentTaskBloc>(
              title: 'Concurrent Tasks',
              description:
                  'Tasks run concurrently - multiple tasks can execute at once',
              color: Colors.green,
            ),
            TaskTab<DroppableTaskBloc>(
              title: 'Droppable Tasks',
              description:
                  'While a task is running, subsequent tasks are dropped',
              color: Colors.orange,
            ),
            TaskTab<RestartableTaskBloc>(
              title: 'Restartable Tasks',
              description: 'New tasks cancel currently running tasks',
              color: Colors.purple,
            ),
            TaskTab<DebounceTaskBloc>(
              title: 'Debounce Tasks',
              description: 'Tasks are delayed until a quiet period (2000ms)',
              color: Colors.deepOrange,
            ),
            TaskTab<ThrottleTaskBloc>(
              title: 'Throttle Tasks',
              description:
                  'Tasks are limited to one execution per time window (1s)',
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}
