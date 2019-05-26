import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

abstract class HydratedBloc<Event, State> extends Bloc<Event, State> {
  final HydratedBlocStorage storage =
      (BlocSupervisor.delegate as HydratedBlocDelegate).storage;

  @mustCallSuper
  @override
  State get initialState =>
      fromJson(storage?.read(this.runtimeType.toString()));

  State fromJson(String json);
  String toJson(State state);
}
