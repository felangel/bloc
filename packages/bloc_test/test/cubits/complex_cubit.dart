import 'package:bloc/bloc.dart';

abstract class ComplexState {}

class ComplexStateA extends ComplexState {}

class ComplexStateB extends ComplexState {}

class ComplexCubit extends Cubit<ComplexState> {
  ComplexCubit() : super(ComplexStateA());

  void emitA() => emit(ComplexStateA());
  void emitB() => emit(ComplexStateB());
}
