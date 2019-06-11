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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Ticker _ticker;
  TickerBloc _tickerBloc;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker();
    _tickerBloc = TickerBloc(_ticker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bloc with Streams'),
      ),
      body: BlocBuilder(
        bloc: _tickerBloc,
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
          _tickerBloc.dispatch(StartTicker());
        },
        tooltip: 'Start',
        child: Icon(Icons.timer),
      ),
    );
  }

  @override
  void dispose() {
    _tickerBloc.dispose();
    super.dispose();
  }
}
