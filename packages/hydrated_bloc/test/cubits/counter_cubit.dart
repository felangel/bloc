import 'package:hydrated_bloc/hydrated_bloc.dart';

class CounterCubit extends Cubit<int> with HydratedMixin {
  CounterCubit() : super(0) {
    hydrate();
  }

  void setToFive() {
    emit(5);
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    return 5;
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    return {'state': 5};
  }
}
