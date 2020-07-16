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

class HeavyListCubit extends HydratedCubit<List<HeavyObject>> {
  HeavyListCubit() : super(const <HeavyObject>[]);

  void addItem(HeavyObject item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<HeavyObject> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<HeavyObject> fromJson(Map<String, dynamic> json) {
    return json['state'] as List<HeavyObject>;
  }
}

class HeavyObject {
  const HeavyObject(this.value);
  final int value;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'value': value};
  }

  HeavyObject fromJson(Map<String, dynamic> json) {
    return HeavyObject(json['value'] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is HeavyObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
