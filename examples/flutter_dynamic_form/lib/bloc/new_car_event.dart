part of 'new_car_bloc.dart';

@immutable
abstract class NewCarEvent {
  const NewCarEvent();
}

class NewCarFormLoaded extends NewCarEvent {}

class NewCarBrandChanged extends NewCarEvent {
  const NewCarBrandChanged({this.brand});

  final String? brand;
}

class NewCarModelChanged extends NewCarEvent {
  const NewCarModelChanged({this.model});

  final String? model;
}

class NewCarYearChanged extends NewCarEvent {
  const NewCarYearChanged({this.year});

  final String? year;
}
