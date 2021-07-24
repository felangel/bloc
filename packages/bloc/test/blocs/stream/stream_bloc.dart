import 'package:bloc/bloc.dart';

class StreamEvent {}

class StreamBloc extends Bloc<StreamEvent, int> {
  StreamBloc(Stream<int> stream) : super(0) {
    on<StreamEvent>((_, emit) {
      return emit.listen<int>(
        stream,
        (i) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          emit(i);
        },
      );
    }, restartable());
  }
}
