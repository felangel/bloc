part of 'new_car_bloc.dart';

@immutable
abstract class NewCarEvent {
  const NewCarEvent();
}

class NewCarFormLoaded extends NewCarEvent {}

class NewCarBrandChanged extends NewCarEvent {
  final String brand;

  const NewCarBrandChanged({this.brand});
}

class NewCarModelChanged extends NewCarEvent {
  final String model;

  const NewCarModelChanged({this.model});
}

class NewCarYearChanged extends NewCarEvent {
  final String year;

  const NewCarYearChanged({this.year});
}
