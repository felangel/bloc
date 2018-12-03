import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<dynamic, String> {
  @override
  String get initialState => '';

  @override
  Stream<String> mapEventToState(String state, dynamic event) {
    return Observable.just('data');
  }
}
