import 'package:bloc/bloc.dart';

import 'package:flutter/widgets.dart';

/// [State] with defined [Bloc]
/// uses stateBloc function to initialize Bloc and provide it
/// to [State] as an object
abstract class BlocState<T extends StatefulWidget, B extends Bloc>
    extends State<T> {
  ///public Bloc object in a [State]
  B bloc;

  ///abstract Function to create a Bloc
  B stateBloc(BuildContext context);

  @override
  void initState() {
    bloc = stateBloc(context);
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
