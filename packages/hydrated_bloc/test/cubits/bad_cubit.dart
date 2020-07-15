import 'package:hydrated_bloc/hydrated_bloc.dart';

class BadCubit extends HydratedCubit<BadState> {
  BadCubit() : super(null);

  void setBad() => emit(BadState());

  @override
  Map<String, dynamic> toJson(BadState state) => state?.toJson();

  @override
  BadState fromJson(Map<String, dynamic> json) => null;
}

class BadState {
  BadState();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bad_obj': Object,
    };
  }
}
