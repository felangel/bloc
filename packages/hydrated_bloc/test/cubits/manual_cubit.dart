import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ManualCubit extends HydratedCubit<Dog?> {
  ManualCubit() : super(null);

  void setDog(Dog dog) => emit(dog);

  @override
  Map<String, dynamic>? toJson(Dog? state) => state?.toJson();

  @override
  Dog fromJson(Map<String, dynamic> json) => Dog.fromJson(json);
}

class Dog {
  const Dog(this.name, this.age, this.toys);

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      json['name'] as String,
      json['age'] as int,
      (json['toys'] as List)
          .map(
            (dynamic toy) =>
                Toy.fromJson(Map<String, dynamic>.from(toy as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'age': age,
      'toys': toys.map<dynamic>((toy) => toy.toJson()).toList(),
    };
  }

  final String name;
  final int age;
  final List<Toy> toys;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is Dog &&
        o.name == name &&
        o.age == age &&
        listEquals(o.toys, toys);
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode ^ toys.hashCode;
}

class Toy {
  const Toy(this.name);

  factory Toy.fromJson(Map<String, dynamic> json) {
    return Toy(
      json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
    };
  }

  final String name;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Toy && o.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
