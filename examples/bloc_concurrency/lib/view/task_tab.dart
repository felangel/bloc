import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/view/state_card.dart';
import 'package:bloc_concurrency_demo/view/task_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Represents a tab in the task scheduler demo.
class TaskTab<T extends BaseTaskBloc> extends StatefulWidget {
  /// Creates an instance of [TaskTab].
  const TaskTab({
    required this.title,
    required this.description,
    required this.color,
    super.key,
  });

  /// The title of the tab
  final String title;

  /// The description of the tab
  final String description;

  /// The color associated with the tab, used for UI representation
  final Color color;

  @override
  TaskTabState<T> createState() => TaskTabState<T>();
}

/// Represents the state of the task tab
class TaskTabState<T extends BaseTaskBloc> extends State<TaskTab<T>> {
  /// The counter for the number of tasks sent
  int taskCounter = 1;

  void _sendTaskEvent() {
    // For concurrent and restartable, use PerformTaskEvent directly
    if (T == ConcurrentTaskBloc || T == RestartableTaskBloc) {
      context.read<T>().add(PerformTaskEvent(taskCounter));
    } else {
      // For others, use TriggerTaskEvent to show queue/drop behavior
      context.read<T>().add(TriggerTaskEvent(taskCounter));
    }
    taskCounter++;
  }

  void _reset() {
    context.read<T>().add(const ClearTasksEvent());
    taskCounter = 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, TaskState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: widget.color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StateCard(
                            title: 'Running',
                            value: state.runningTasks.length.toString(),
                            color: Colors.orange,
                          ),

                          //Cancelled
                          StateCard(
                            title: 'Cancelled',
                            value: state.cancelledTasks.length.toString(),
                            color: Colors.purple,
                          ),
                          StateCard(
                            title: 'Completed',
                            value: state.completedTasks.length.toString(),
                            color: Colors.green,
                          ),

                          StateCard(
                            title: 'Total Sent',
                            value: (taskCounter - 1).toString(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _sendTaskEvent,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('PERFORM TASK($taskCounter)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.clear),
                    label: const Text('CLEAR TASKS'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TaskTimeline(
                  tasks: state.tasks,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
