import 'package:hydrated_bloc/hydrated_bloc.dart';

class BadCubit extends HydratedCubit<BadState?> {
  BadCubit() : super(null);

  void setBad([dynamic badObject = Object]) => emit(BadState(badObject));

  @override
  Map<String, dynamic>? toJson(BadState? state) => state?.toJson();

  @override
  BadState? fromJson(Map<String, dynamic> json) => null;
}

class BadState {
  BadState(this.badObject);

  final dynamic badObject;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bad_obj': badObject,
    };
  }
}

class VeryBadObject {
  dynamic toJson() {
    return Object;
  }
}
