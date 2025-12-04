import 'package:hydrated_bloc/hydrated_bloc.dart';

class FromJsonStateCubit extends HydratedCubit<int> {
  FromJsonStateCubit({required void Function(int) onFromJson})
    : _onFromJson = onFromJson,
      super(0);

  final void Function(int) _onFromJson;

  void increment() => emit(state + 1);

  @override
  Map<String, dynamic>? toJson(int state) {
    return {'state': state};
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    _onFromJson.call(state);
    return json['state'] as int?;
  }
}
