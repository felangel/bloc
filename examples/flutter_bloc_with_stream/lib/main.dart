import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_bloc_with_stream/ticker/ticker.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  runApp(TickerApp());
}

/// {@template ticker_app}
/// [MaterialApp] which sets the [TickerPage] as the `home`.
/// [TickerApp] also provides an instance of [TickerBloc] to
/// the [TickerPage].
/// {@endtemplate}
class TickerApp extends MaterialApp {
  /// {@macro ticker_app}
  TickerApp({Key? key})
      : super(
          key: key,
          home: BlocProvider(
            create: (_) => TickerBloc(Ticker()),
            child: TickerPage(),
          ),
        );
}

/// [StatelessWidget] which consumes a [TickerBloc]
/// and responds to changes in the [TickerState].
/// [TickerPage] also notifies the [TickerBloc] when
/// the user taps on the start button.
class TickerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bloc with Streams'),
      ),
      body: BlocBuilder<TickerBloc, TickerState>(
        builder: (context, state) {
          if (state is TickerTickSuccess) {
            return Center(
              child: Text('Tick #${state.count}'),
            );
          }
          return const Center(
            child: Text('Press the floating button to start'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<TickerBloc>().add(TickerStarted()),
        tooltip: 'Start',
        child: const Icon(Icons.timer),
      ),
    );
  }
}
