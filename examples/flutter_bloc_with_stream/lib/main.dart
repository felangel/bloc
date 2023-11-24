import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_bloc_with_stream/ticker/ticker.dart';

void main() => runApp(TickerApp());

/// {@template ticker_app}
/// [MaterialApp] which sets the [TickerPage] as the `home`.
/// [TickerApp] also provides an instance of [TickerBloc] to
/// the [TickerPage].
/// {@endtemplate}
class TickerApp extends MaterialApp {
  /// {@macro ticker_app}
  TickerApp({super.key})
      : super(
          home: BlocProvider(
            create: (_) => TickerBloc(Ticker()),
            child: const TickerPage(),
          ),
        );
}

/// {@template ticker_page}
/// [StatelessWidget] which consumes a [TickerBloc]
/// and responds to changes in the [TickerState].
/// [TickerPage] also notifies the [TickerBloc] when
/// the user taps on the start button.
/// {@endtemplate}
class TickerPage extends StatelessWidget {
  /// {@macro ticker_page}
  const TickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<TickerBloc, TickerState>(
          builder: (context, state) {
            return switch (state) {
              TickerInitial() =>
                const Text('Press the floating button to start.'),
              TickerTickSuccess() => Text('Tick #${state.count}'),
              TickerComplete() =>
                const Text('Complete! Press the floating button to restart.')
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<TickerBloc>().add(const TickerStarted()),
        tooltip: 'Start',
        child: const Icon(Icons.timer),
      ),
    );
  }
}
