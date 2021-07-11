import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<dynamic, String> {
  SimpleBloc() : super('') {
    on<String>((_, emit) => emit('data'));
  }
}
