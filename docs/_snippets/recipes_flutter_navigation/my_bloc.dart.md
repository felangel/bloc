```dart
import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(StateA()) {
    on<EventA>((event, emit) => emit(StateA()));
    on<EventB>((event, emit) => emit(StateB()));
  }
}
```
