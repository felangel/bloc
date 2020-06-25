import 'package:bloc/bloc.dart';

import 'package:flutter/widgets.dart';
import 'bloc_provider.dart';

/// [State] with provided defined [Bloc]
/// gets Bloc from [BuildContext] and provides it
/// to [State] as an object
abstract class ProvidedBlocState<T extends StatefulWidget, B extends Bloc>
    extends State<T> {
  ///public Bloc object in a [State]
  B bloc;

  B _stateBloc(BuildContext context) => BlocProvider.of<B>(context);

  @override
  void initState() {
    bloc = _stateBloc(context);
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
