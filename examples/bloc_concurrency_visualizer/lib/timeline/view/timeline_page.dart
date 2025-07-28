import 'package:bloc_concurrency_visualizer/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc Concurrency Visualizer'),
        forceMaterialTransparency: true,
      ),
      body: ListView.builder(
        itemCount: Transformer.values.length,
        itemBuilder: (_, i) => TimelineView(transformer: Transformer.values[i]),
      ),
    );
  }
}

class TimelineView extends StatefulWidget {
  const TimelineView({required this.transformer, super.key});

  final Transformer transformer;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(seconds: 10);
  static const _spacing = 8.0;

  late final TimelineBloc _bloc;
  late final AnimationController _timelineController;

  @override
  void initState() {
    super.initState();
    _timelineController = AnimationController(vsync: this, duration: _duration)
      ..addListener(_onAnimation);

    _bloc = TimelineBloc(
      transformer: widget.transformer,
      now: () => _timelineController.value,
    );
  }

  void _onAnimation() {
    if (_timelineController.isCompleted) {
      _bloc.add(const TimelineCompleted());
      _timelineController.reset();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonStyle = OutlinedButton.styleFrom(
      shape: const BeveledRectangleBorder(),
      side: const BorderSide(width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    final title = Text(
      widget.transformer.title,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    );

    final description = Text(
      widget.transformer.description,
      style: theme.textTheme.bodyMedium,
    );

    final addTaskButton = OutlinedButton(
      style: buttonStyle,
      onPressed: () {
        _bloc.add(const TimelineTaskQueued());
        if (!_timelineController.isAnimating) {
          _timelineController.forward();
        }
      },
      child: const Text('add task'),
    );

    final resetButton = OutlinedButton(
      style: buttonStyle,
      onPressed: () {
        _bloc.add(const TimelineReset());
        _timelineController.reset();
      },
      child: const Text('reset'),
    );

    final actions = Row(
      spacing: _spacing,
      children: [addTaskButton, resetButton],
    );

    final timeline = BlocBuilder<TimelineBloc, TimelineState>(
      bloc: _bloc,
      builder: (context, state) => Timeline(
        cursorPosition: _timelineController.value,
        tasks: [...state.tasks.values],
      ),
    );

    const gap = SizedBox(height: _spacing);

    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [title, description, gap, actions, gap, timeline],
      ),
    );
  }
}

class Timeline extends StatelessWidget {
  const Timeline({
    required this.tasks,
    required this.cursorPosition,
    super.key,
  });

  final double cursorPosition;
  final List<Task> tasks;

  static const _height = 100.0;
  static const _barCount = 4;
  static const _barSpacing = 6.5;
  static const _barHeight = _height / 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final background = Positioned.fill(
      child: SizedBox(
        width: width,
        height: _height,
        child: DecoratedBox(decoration: BoxDecoration(border: Border.all())),
      ),
    );

    final cursor = Positioned(
      left: width * cursorPosition,
      child: SizedBox(
        width: 1,
        height: _height,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border.all(), color: Colors.black),
        ),
      ),
    );

    final instructions = Align(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'timeline is empty',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('tap "add task" to enqueue tasks'),
        ],
      ),
    );

    return SizedBox(
      width: width,
      height: _height,
      child: Stack(
        children: [
          background,
          cursor,
          if (tasks.isEmpty) instructions,
          for (final (index, task) in tasks.indexed) ...[
            _BarBackground(
              left: width * task.start,
              top: (index % _barCount) * (_barHeight + _barSpacing),
              height: _barHeight,
              value: cursorPosition,
              task: task,
            ),
            _BarForeground(
              left: width * task.start,
              top: (index % _barCount) * (_barHeight + _barSpacing),
              height: _barHeight,
              width: width,
              task: task,
              text: Text(
                '#${index + 1} ${task.status.text}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: task.status.color,
                  decoration: task.isCanceled
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarBackground extends StatelessWidget {
  const _BarBackground({
    required this.left,
    required this.top,
    required this.height,
    required this.value,
    required this.task,
  });

  final double left;
  final double top;
  final double height;
  final double value;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: (((task.end ?? value) - task.start) * width).abs(),
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: task.isCanceled
                ? Border(left: BorderSide(color: task.status.borderColor))
                : Border.all(color: task.status.borderColor),
            color: task.status.fillColor,
          ),
        ),
      ),
    );
  }
}

class _BarForeground extends StatelessWidget {
  const _BarForeground({
    required this.left,
    required this.top,
    required this.height,
    required this.width,
    required this.text,
    required this.task,
  });

  final double left;
  final double top;
  final double height;
  final double width;
  final Text text;
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: 100,
        height: height,
        child: Padding(padding: const EdgeInsets.only(left: 4), child: text),
      ),
    );
  }
}

extension on TaskStatus {
  String get text {
    return switch (this) {
      TaskStatus.queued => 'Queued',
      TaskStatus.running => 'Running',
      TaskStatus.finished => 'Finished',
      TaskStatus.canceled => 'Canceled',
    };
  }

  Color get borderColor {
    return switch (this) {
      TaskStatus.queued => Colors.orange.shade800,
      TaskStatus.running => Colors.lightBlue.shade800,
      TaskStatus.finished => Colors.greenAccent.shade700,
      TaskStatus.canceled => Colors.grey.shade800,
    };
  }

  Color get fillColor {
    return switch (this) {
      TaskStatus.queued => Colors.orange.shade300,
      TaskStatus.running => Colors.lightBlue.shade300,
      TaskStatus.finished => Colors.greenAccent.shade200,
      TaskStatus.canceled => Colors.transparent,
    };
  }

  Color get color {
    return switch (this) {
      TaskStatus.queued => Colors.black,
      TaskStatus.running => Colors.black,
      TaskStatus.finished => Colors.black,
      TaskStatus.canceled => Colors.grey.shade700,
    };
  }
}

extension on Transformer {
  String get title {
    return switch (this) {
      Transformer.concurrent => 'Concurrent',
      Transformer.sequential => 'Sequential',
      Transformer.droppable => 'Droppable',
      Transformer.restartable => 'Restartable',
    };
  }

  String get description {
    return switch (this) {
      Transformer.concurrent => 'Process all tasks in parallel.',
      Transformer.sequential => 'Process tasks in order, one at a time.',
      Transformer.restartable => 'Only process the most recent task.',
      Transformer.droppable => 'Ignore new tasks if a task is processing.',
    };
  }
}
