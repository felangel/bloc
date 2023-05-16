```dart
import 'package:bloc/bloc.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() : super(Initial()) {
    on<FetchData>((event, emit) async {
      emit(Loading());
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(Success());
    });
  }
}
```
