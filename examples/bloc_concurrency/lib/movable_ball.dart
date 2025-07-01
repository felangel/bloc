import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/index.dart';
import 'package:movable_ball/bridge_tab.dart';

/// Demo app for movable balls crossing a bridge using different
///  BLoC concurrency strategies.
class MovableBallDemo extends StatefulWidget {
  /// Creates an instance of [MovableBallDemo].
  const MovableBallDemo({super.key});

  @override
  MovableBallDemoState createState() => MovableBallDemoState();
}

/// State for [MovableBallDemo] that manages the tab controller
///  and BLoC providers.
class MovableBallDemoState extends State<MovableBallDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DebounceBloc()),
        BlocProvider(create: (_) => ThrottleBloc()),
        BlocProvider<SequentialBloc>(create: (_) => SequentialBloc()),
        BlocProvider<ConcurrentBloc>(create: (_) => ConcurrentBloc()),
        BlocProvider<DroppableBloc>(create: (_) => DroppableBloc()),
        BlocProvider<RestartableBloc>(create: (_) => RestartableBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🌉 Bridge & Balls Demo - Bloc Concurrency'),
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
            BridgeTab<SequentialBloc>(
              title: 'Sequential Bridge',
              description:
                  'One ball at a time - each ball waits for previous to finish',
              color: Colors.blue,
              icon: '🔵',
            ),
            BridgeTab<ConcurrentBloc>(
              title: 'Concurrent Bridge',
              description:
                  'All balls cross together - any can reach destination'
                  ' at any time',
              color: Colors.green,
              icon: '🟢',
            ),
            BridgeTab<DroppableBloc>(
              title: 'Droppable Bridge',
              description:
                  'While first ball crosses, all other balls are discarded',
              color: Colors.orange,
              icon: '🟠',
            ),
            BridgeTab<RestartableBloc>(
              title: 'Restartable Bridge',
              description:
                  'Latest ball cancels previous ones -'
                  ' only newest ball reaches destination',
              color: Colors.purple,
              icon: '🟣',
            ),
            BridgeTab<DebounceBloc>(
              title: 'Debounce Bridge',
              description: 'Sends only after a quiet period (2000ms)',
              color: Colors.deepOrange,
              icon: '🟧',
            ),
            BridgeTab<ThrottleBloc>(
              title: 'Throttle Bridge',
              description: 'Sends only once per time window (1s)',
              color: Colors.indigo,
              icon: '🔵',
            ),
          ],
        ),
      ),
    );
  }
}
