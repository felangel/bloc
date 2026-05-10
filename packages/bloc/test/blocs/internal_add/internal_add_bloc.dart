import 'package:bloc/bloc.dart';

abstract class InternalAddEvent {
  const InternalAddEvent();
}

class InternalAddSubscriptionRequested extends InternalAddEvent {
  const InternalAddSubscriptionRequested();
}

class InternalAddDataReceived extends InternalAddEvent {
  const InternalAddDataReceived({required this.value});

  final int value;
}

class InternalAddBloc extends Bloc<InternalAddEvent, int> {
  InternalAddBloc({required Stream<int> stream}) : super(0) {
    on<InternalAddSubscriptionRequested>(
      (event, emit) => emit.onEach<int>(
        stream,
        onData: (data) {
          if (!isClosed) add(InternalAddDataReceived(value: data));
        },
      ),
    );
    on<InternalAddDataReceived>((event, emit) => emit(event.value));
  }
}
