import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/bloc/bloc.dart';

const TextStyle kNumberStyle = TextStyle(
  fontSize: 27,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
);

class PageContent extends StatelessWidget {
  const PageContent({Key key, @required this.count})
      : assert(count != null),
        super(key: key);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlocBuilder<AppBloc, AppState>(
              builder: (BuildContext context, AppState state) {
                return Counter(
                  'Active page index is: ',
                  state.activePageIndex,
                );
              },
            ),
            const SizedBox(height: 20),
            Counter('Local count is: ', count),
          ],
        ),
      ),
    );
  }
}

class Counter extends StatelessWidget {
  const Counter(this.label, this.count, {Key key}) : super(key: key);

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(label ?? ''),
        Text('$count', style: kNumberStyle),
      ],
    );
  }
}
