import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';

typedef BlocWidgetBuilder<S>(BuildContext context, S state);

class BlocBuilder<S> extends StatefulWidget {
  final Bloc<dynamic, S> bloc;
  final BlocWidgetBuilder<S> builder;

  const BlocBuilder({Key key, @required this.bloc, @required this.builder})
      : assert(bloc != null),
        assert(builder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => BlocBuilderState(bloc, builder);
}

class BlocBuilderState<S> extends State<BlocBuilder<S>> {
  final Bloc<dynamic, S> bloc;
  final BlocWidgetBuilder<S> builder;

  BlocBuilderState(this.bloc, this.builder);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      initialData: bloc.initialState,
      stream: bloc.state,
      builder: (BuildContext context, AsyncSnapshot<S> snapshot) {
        return builder(context, snapshot.data) as Widget;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }
}
