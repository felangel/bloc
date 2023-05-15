part of 'new_car_bloc.dart';

sealed class NewCarEvent extends Equatable {
  const NewCarEvent();

  @override
  List<Object?> get props => [];
}

final class NewCarFormLoaded extends NewCarEvent {
  const NewCarFormLoaded();
}

final class NewCarBrandChanged extends NewCarEvent {
  const NewCarBrandChanged({this.brand});

  final String? brand;

  @override
  List<Object?> get props => [brand];
}

final class NewCarModelChanged extends NewCarEvent {
  const NewCarModelChanged({this.model});

  final String? model;

  @override
  List<Object?> get props => [model];
}

final class NewCarYearChanged extends NewCarEvent {
  const NewCarYearChanged({this.year});

  final String? year;

  @override
  List<Object?> get props => [year];
}
