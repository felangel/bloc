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

class HeavyListCubit<T> extends HydratedCubit<List<T>> {
  HeavyListCubit(this._fromJson) : super(<T>[]);
  final T Function(dynamic json) _fromJson;

  void addItem(T item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<T> state) {
    return <String, dynamic>{'state': state};
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    return (json['state'] as List).map(_fromJson).toList();
  }
}

class ToMapObject {
  const ToMapObject(this.value);
  final int value;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'value': value};
  }

  static ToMapObject fromJson(Map<String, dynamic> map) {
    return ToMapObject(map['value'] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ToMapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ToListObject {
  const ToListObject(this.value);
  final int value;

  List<dynamic> toJson() {
    return <int>[value];
  }

  static ToListObject fromJson(List<dynamic> list) {
    return ToListObject(list[0] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ToListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ToListMapObject {
  ToListMapObject(int value) : value = ToMapObject(value);
  final ToMapObject value;

  List<dynamic> toJson() {
    return <ToMapObject>[value];
  }

  static ToListMapObject fromJson(List<dynamic> list) {
    return ToListMapObject(
      ToMapObject.fromJson(list[0] as Map<String, dynamic>).value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ToListMapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ToListListObject {
  ToListListObject(int value) : value = ToListObject(value);
  final ToListObject value;

  List<dynamic> toJson() {
    return <ToListObject>[value];
  }

  static ToListListObject fromJson(List<dynamic> list) {
    return ToListListObject(
      ToListObject.fromJson(list[0] as List<dynamic>).value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ToListListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
