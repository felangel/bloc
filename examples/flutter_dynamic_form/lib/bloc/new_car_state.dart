part of 'new_car_bloc.dart';

class NewCarState {
  final List<String> brands;
  final String brand;

  final List<String> models;
  final String model;

  final List<String> years;
  final String year;

  const NewCarState({
    @required this.brands,
    @required this.brand,
    @required this.models,
    @required this.model,
    @required this.years,
    @required this.year,
  });

  bool get isComplete => brand != null && model != null && year != null;

  factory NewCarState.initial() => NewCarState(
        brands: <String>[],
        brand: null,
        models: <String>[],
        model: null,
        years: <String>[],
        year: null,
      );

  factory NewCarState.brandsLoadInProgress() => NewCarState(
        brands: <String>[],
        brand: null,
        models: <String>[],
        model: null,
        years: <String>[],
        year: null,
      );

  factory NewCarState.brandsLoadSuccess({
    @required List<String> brands,
  }) =>
      NewCarState(
        brands: brands,
        brand: null,
        models: <String>[],
        model: null,
        years: <String>[],
        year: null,
      );

  factory NewCarState.modelsLoadInProgress({
    @required List<String> brands,
    @required String brand,
  }) =>
      NewCarState(
        brands: brands,
        brand: brand,
        models: <String>[],
        model: null,
        years: <String>[],
        year: null,
      );

  factory NewCarState.modelsLoadSuccess({
    @required List<String> brands,
    @required String brand,
    @required List<String> models,
  }) =>
      NewCarState(
        brands: brands,
        brand: brand,
        models: models,
        model: null,
        years: <String>[],
        year: null,
      );

  factory NewCarState.yearsLoadInProgress({
    @required List<String> brands,
    @required String brand,
    @required List<String> models,
    @required String model,
  }) =>
      NewCarState(
        brands: brands,
        brand: brand,
        models: models,
        model: model,
        years: <String>[],
        year: null,
      );

  factory NewCarState.yearsLoadSuccess({
    @required List<String> brands,
    @required String brand,
    @required List<String> models,
    @required String model,
    @required List<String> years,
  }) =>
      NewCarState(
        brands: brands,
        brand: brand,
        models: models,
        model: model,
        years: years,
        year: null,
      );

  NewCarState copyWith({
    List<String> brands,
    String brand,
    List<String> models,
    String model,
    List<String> years,
    String year,
  }) {
    return NewCarState(
      brands: brands ?? this.brands,
      brand: brand ?? this.brand,
      models: models ?? this.models,
      model: model ?? this.model,
      years: years ?? this.years,
      year: year ?? this.year,
    );
  }
}
