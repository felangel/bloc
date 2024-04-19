import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/stats/riverpod/stats_notifier.dart';
import 'package:flutter_todos/stats/view/stats_view.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.microtask(
      () => ref.read(statsNotifierProvider.notifier).fetchStats(),
    );

    return const StatsView();
  }
}
