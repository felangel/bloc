import 'package:flutter/material.dart';
import 'ticker/ticker.dart';
import 'bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ticker = Ticker();
    final tickerBloc = TickerBloc(ticker);
    return BlocBuilder(
      bloc: tickerBloc,
      builder: (BuildContext context, TickerState state) {
        if (state is InitialTickerState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Press the floating button to start',
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                tickerBloc.dispatch(StartTicker());
              },
              tooltip: 'Start',
              child: Icon(Icons.watch),
            ),
          );
        } else if (state is TickUpdate) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tick #${state.count}'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
