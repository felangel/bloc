part of 'new_car_bloc.dart';

@immutable
abstract class NewCarEvent extends Equatable {
  const NewCarEvent();
}

class NewCarFormLoaded extends NewCarEvent {
  const NewCarFormLoaded();

  @override
  List<Object?> get props => [];
}

class NewCarBrandChanged extends NewCarEvent {
  const NewCarBrandChanged({this.brand});

  final String? brand;

  @override
  List<Object?> get props => [brand];
}

class NewCarModelChanged extends NewCarEvent {
  const NewCarModelChanged({this.model});

  final String? model;

  @override
  List<Object?> get props => [model];
}

class NewCarYearChanged extends NewCarEvent {
  const NewCarYearChanged({this.year});

  final String? year;

  @override
  List<Object?> get props => [year];
}
