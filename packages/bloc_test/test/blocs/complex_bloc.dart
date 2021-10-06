import 'package:bloc/bloc.dart';

abstract class ComplexEvent {}

class ComplexEventA extends ComplexEvent {}

class ComplexEventB extends ComplexEvent {}

abstract class ComplexState {}

class ComplexStateA extends ComplexState {}

class ComplexStateB extends ComplexState {}

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  ComplexBloc() : super(ComplexStateA()) {
    on<ComplexEventA>((event, emit) => emit(ComplexStateA()));
    on<ComplexEventB>((event, emit) => emit(ComplexStateB()));
  }
}
