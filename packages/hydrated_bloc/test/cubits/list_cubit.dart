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

class ListCubitMap<T extends ToJsonMap<E>, E> extends HydratedCubit<List<T>> {
  ListCubitMap(this._fromJson, [this.explicit = false]) : super(<T>[]);
  final T Function(Map<String, dynamic> json) _fromJson;
  final bool explicit;

  void addItem(T item) => emit(List.from(state)..add(item));

  @override
  Map<String, dynamic> toJson(List<T> state) {
    final map = <String, dynamic>{
      'state': explicit
          ? List<Map<String, E>>.from(state.map<dynamic>(
              (x) => x.toJson(),
            ))
          : state
    };
    return map;
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    final list = (json['state'] as List)
        .map((dynamic x) => x as Map<String, dynamic>)
        .map(_fromJson)
        .toList();
    return list;
  }
}

class ListCubitList<T extends ToJsonList<E>, E> extends HydratedCubit<List<T>> {
  ListCubitList(this._fromJson, [this.explicit = false]) : super(<T>[]);
  final T Function(List<dynamic> json) _fromJson;
  final bool explicit;

  void addItem(T item) => emit(List.from(state)..add(item));
  void reset() => emit(<T>[]);

  @override
  Map<String, dynamic> toJson(List<T> state) {
    final map = <String, dynamic>{
      'state': explicit
          ? List<List<E>>.from(state.map<dynamic>(
              (x) => x.toJson(),
            ))
          : state
    };
    return map;
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    final list = (json['state'] as List)
        .map((dynamic x) => x as List<dynamic>)
        .map(_fromJson)
        .toList();
    return list;
  }
}

mixin ToJsonMap<T> {
  Map<String, T> toJson();
}

class MapObject with ToJsonMap<int> {
  const MapObject(this.value);
  final int value;

  @override
  Map<String, int> toJson() {
    return <String, int>{'value': value};
  }

  static MapObject fromJson(Map<String, dynamic> map) {
    return MapObject(map['value'] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class MapCustomObject with ToJsonMap<CustomObject> {
  MapCustomObject(int value) : value = CustomObject(value);
  final CustomObject value;

  @override
  Map<String, CustomObject> toJson() {
    return <String, CustomObject>{'value': value};
  }

  static MapCustomObject fromJson(Map<String, dynamic> map) {
    return MapCustomObject(CustomObject.fromJson(
      map['value'] as Map<String, dynamic>,
    ).value);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MapCustomObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

mixin ToJsonList<T> {
  List<T> toJson();
}

class ListObject with ToJsonList<int> {
  const ListObject(this.value);
  final int value;

  @override
  List<int> toJson() {
    return <int>[value];
  }

  static ListObject fromJson(List<dynamic> list) {
    return ListObject(list[0] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ListMapObject with ToJsonList<MapObject> {
  ListMapObject(int value) : value = MapObject(value);
  final MapObject value;

  @override
  List<MapObject> toJson() {
    return <MapObject>[value];
  }

  static ListMapObject fromJson(List<dynamic> list) {
    return ListMapObject(
      MapObject.fromJson(list[0] as Map<String, dynamic>).value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListMapObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ListListObject with ToJsonList<ListObject> {
  ListListObject(int value) : value = ListObject(value);
  final ListObject value;

  @override
  List<ListObject> toJson() {
    return <ListObject>[value];
  }

  static ListListObject fromJson(List<dynamic> list) {
    return ListListObject(
      ListObject.fromJson(list[0] as List<dynamic>).value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListListObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class ListCustomObject with ToJsonList<CustomObject> {
  ListCustomObject(int value) : value = CustomObject(value);
  final CustomObject value;

  @override
  List<CustomObject> toJson() {
    return <CustomObject>[value];
  }

  static ListCustomObject fromJson(List<dynamic> list) {
    return ListCustomObject(CustomObject.fromJson(
      list[0] as Map<String, dynamic>,
    ).value);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ListCustomObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class CustomObject {
  CustomObject(this.value);
  final int value;

  Map<String, dynamic> toJson() {
    return <String, int>{'value': value};
  }

  static CustomObject fromJson(Map<String, dynamic> json) {
    return CustomObject(json['value'] as int);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CustomObject && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
