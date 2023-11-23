import 'package:hydrated_bloc/hydrated_bloc.dart';

class FromJsonStateCubit extends HydratedCubit<int> {
  FromJsonStateCubit() : super(0);

  final List<int> fromJsonCalls = [];

  void increment() => emit(state + 1);

  @override
  Map<String, dynamic>? toJson(int state) {
    return {'state': state};
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    fromJsonCalls.add(state);
    return json['state'] as int?;
  }
}
