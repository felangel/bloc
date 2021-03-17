part of 'new_car_bloc.dart';

class NewCarState {
  const NewCarState({
    required this.brands,
    required this.brand,
    required this.models,
    required this.model,
    required this.years,
    required this.year,
  });

  final List<String> brands;
  final String? brand;

  final List<String> models;
  final String? model;

  final List<String> years;
  final String? year;

  bool get isComplete => brand != null && model != null && year != null;

  const NewCarState.initial()
      : this(
          brands: const <String>[],
          brand: null,
          models: const <String>[],
          model: null,
          years: const <String>[],
          year: null,
        );

  const NewCarState.brandsLoadInProgress()
      : this(
          brands: const <String>[],
          brand: null,
          models: const <String>[],
          model: null,
          years: const <String>[],
          year: null,
        );

  const NewCarState.brandsLoadSuccess({required List<String> brands})
      : this(
          brands: brands,
          brand: null,
          models: const <String>[],
          model: null,
          years: const <String>[],
          year: null,
        );

  const NewCarState.modelsLoadInProgress({
    required List<String> brands,
    String? brand,
  }) : this(
          brands: brands,
          brand: brand,
          models: const <String>[],
          model: null,
          years: const <String>[],
          year: null,
        );

  const NewCarState.modelsLoadSuccess({
    required List<String> brands,
    required String? brand,
    required List<String> models,
  }) : this(
          brands: brands,
          brand: brand,
          models: models,
          model: null,
          years: const <String>[],
          year: null,
        );

  const NewCarState.yearsLoadInProgress({
    required List<String> brands,
    required String? brand,
    required List<String> models,
    required String? model,
  }) : this(
          brands: brands,
          brand: brand,
          models: models,
          model: model,
          years: const <String>[],
          year: null,
        );

  const NewCarState.yearsLoadSuccess({
    required List<String> brands,
    required String? brand,
    required List<String> models,
    required String? model,
    required List<String> years,
  }) : this(
          brands: brands,
          brand: brand,
          models: models,
          model: model,
          years: years,
          year: null,
        );

  NewCarState copyWith({
    List<String>? brands,
    String? brand,
    List<String>? models,
    String? model,
    List<String>? years,
    String? year,
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
