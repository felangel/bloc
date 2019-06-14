import 'package:flutter/material.dart';
import 'ticker/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_stream/bloc/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider(
        builder: (context) => TickerBloc(Ticker()),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tickerBloc = BlocProvider.of<TickerBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bloc with Streams'),
      ),
      body: BlocBuilder(
        bloc: tickerBloc,
        builder: (BuildContext context, TickerState state) {
          if (state is Initial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Press the floating button to start',
                  ),
                ],
              ),
            );
          } else if (state is Update) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tick #${state.count}'),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tickerBloc.dispatch(StartTicker());
        },
        tooltip: 'Start',
        child: Icon(Icons.timer),
      ),
    );
  }
}
