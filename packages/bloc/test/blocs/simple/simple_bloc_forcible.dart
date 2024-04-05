import 'package:bloc/bloc.dart';

class SimpleBlocForcible extends Bloc<bool, String> {
  SimpleBlocForcible() : super('') {
    on<bool>((force, emit) => emit('data', force: force));
  }
}
