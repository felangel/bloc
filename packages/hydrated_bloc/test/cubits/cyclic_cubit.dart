import 'package:hydrated_bloc/hydrated_bloc.dart';

class CyclicCubit extends HydratedCubit<Cycle1> {
  CyclicCubit() : super(null);

  void setCyclic(Cycle1 cycle1) => emit(cycle1);

  @override
  Map<String, dynamic> toJson(Cycle1 state) => state?.toJson();

  @override
  Cycle1 fromJson(Map<String, dynamic> json) => Cycle1.fromJson(json);
}

class Cycle1 {
  Cycle1([this.cycle2]);

  factory Cycle1.fromJson(Map<String, dynamic> json) {
    return Cycle1(
      json['cycle2'] as Cycle2,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cycle2': cycle2,
    };
  }

  Cycle2 cycle2;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is Cycle1 && o.cycle2 == cycle2;
  }

  @override
  int get hashCode => cycle2.hashCode;
}

class Cycle2 {
  Cycle2([this.cycle1]);

  factory Cycle2.fromJson(Map<String, dynamic> json) {
    return Cycle2(
      json['cycle1'] as Cycle1,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cycle1': cycle1,
    };
  }

  Cycle1 cycle1;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is Cycle2 && o.cycle1 == cycle1;
  }

  @override
  int get hashCode => cycle1.hashCode;
}
