```dart
import 'package:bloc/bloc.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() : super(Initial());

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
  ) async* {
    if (event is FetchData) {
      yield Loading();
      await Future.delayed(Duration(seconds: 2));
      yield Success();
    }
  }
}
```
