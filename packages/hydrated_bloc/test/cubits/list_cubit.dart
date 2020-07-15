import 'package:hydrated_bloc/hydrated_bloc.dart';

class ListCubit extends HydratedCubit<List<String>> {
  ListCubit() : super(const <String>[]);

  void addItem(String item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<String> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<String> fromJson(Map<String, dynamic> json) {
    return json['state'] as List<String>;
  }
}
