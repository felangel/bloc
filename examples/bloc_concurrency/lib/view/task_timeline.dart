import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:flutter/material.dart';

/// Represents the timeline of tasks in the task scheduler demo.
class TaskTimeline extends StatelessWidget {
  /// Creates an instance of [TaskTimeline].
  const TaskTimeline({
    required this.tasks,
    required this.color,
    super.key,
  });

  /// The list of tasks to display in the timeline
  final List<Task> tasks;

  /// The color associated with the timeline, used for UI representation
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Timeline',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: tasks.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks yet. Tap TASK PERFORM() to start!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TaskItem(task: task),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: task.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                task.id.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task ${task.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _getStatusIcon(),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (task.status) {
      case TaskStatus.running:
        return Colors.blue.shade50;
      case TaskStatus.finished:
        return Colors.green.shade50;
      case TaskStatus.cancelled:
        return Colors.red.shade50;
      case TaskStatus.dropped:
        return Colors.orange.shade100;
      case TaskStatus.waiting:
        return Colors.amber.shade50;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case TaskStatus.running:
        return 'Running...';
      case TaskStatus.finished:
        return 'Finished';
      case TaskStatus.cancelled:
        return 'Cancelled';
      case TaskStatus.dropped:
        return task.statusMessage ?? 'Dropped';
      case TaskStatus.waiting:
        return task.statusMessage ?? 'Waiting...';
    }
  }

  Widget _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.running:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TaskStatus.finished:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case TaskStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      case TaskStatus.dropped:
        return const Icon(Icons.block, color: Colors.orange, size: 20);
      case TaskStatus.waiting:
        return const Icon(Icons.hourglass_empty, color: Colors.amber, size: 20);
    }
  }
}
