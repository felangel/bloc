part of 'new_car_bloc.dart';

abstract class NewCarEvent extends Equatable {
  const NewCarEvent();

  @override
  List<Object?> get props => [];
}

class NewCarFormLoaded extends NewCarEvent {
  const NewCarFormLoaded();
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
