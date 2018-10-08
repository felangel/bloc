import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';

typedef BlocWidgetBuilder<T>(BuildContext context, T state);

class BlocBuilder<T> extends StatefulWidget {
  final Bloc bloc;
  final BlocWidgetBuilder<T> builder;

  const BlocBuilder({Key key, @required this.bloc, @required this.builder})
      : assert(bloc != null),
        assert(builder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => BlocBuilderState(bloc, builder);
}

class BlocBuilderState<T> extends State<BlocBuilder<T>> {
  final Bloc bloc;
  final BlocWidgetBuilder<T> builder;

  BlocBuilderState(this.bloc, this.builder);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: bloc.initialState,
      stream: bloc.state,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        return builder(context, snapshot.data);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }
}
