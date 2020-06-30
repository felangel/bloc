```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final int _duration = 60;

  @override
  TimerState get initialState => TimerInitial(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
```
