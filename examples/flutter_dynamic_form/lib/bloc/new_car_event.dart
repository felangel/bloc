import 'package:meta/meta.dart';

@immutable
abstract class NewCarEvent {
  const NewCarEvent();
}

class FormLoaded extends NewCarEvent {}

class BrandChanged extends NewCarEvent {
  final String brand;

  const BrandChanged({this.brand});
}

class ModelChanged extends NewCarEvent {
  final String model;

  const ModelChanged({this.model});
}

class YearChanged extends NewCarEvent {
  final String year;

  const YearChanged({this.year});
}
