part of 'new_car_bloc.dart';

final class NewCarState extends Equatable {
  const NewCarState._({
    this.brands = const <String>[],
    this.brand,
    this.models = const <String>[],
    this.model,
    this.years = const <String>[],
    this.year,
  });

  const NewCarState.initial() : this._();

  const NewCarState.brandsLoadInProgress() : this._();

  const NewCarState.brandsLoadSuccess({required List<String> brands})
      : this._(brands: brands);

  const NewCarState.modelsLoadInProgress({
    required List<String> brands,
    String? brand,
  }) : this._(brands: brands, brand: brand);

  const NewCarState.modelsLoadSuccess({
    required List<String> brands,
    required String? brand,
    required List<String> models,
  }) : this._(brands: brands, brand: brand, models: models);

  const NewCarState.yearsLoadInProgress({
    required List<String> brands,
    required String? brand,
    required List<String> models,
    required String? model,
  }) : this._(brands: brands, brand: brand, models: models, model: model);

  const NewCarState.yearsLoadSuccess({
    required List<String> brands,
    required String? brand,
    required List<String> models,
    required String? model,
    required List<String> years,
  }) : this._(
          brands: brands,
          brand: brand,
          models: models,
          model: model,
          years: years,
        );

  NewCarState copyWith({
    List<String>? brands,
    String? brand,
    List<String>? models,
    String? model,
    List<String>? years,
    String? year,
  }) {
    return NewCarState._(
      brands: brands ?? this.brands,
      brand: brand ?? this.brand,
      models: models ?? this.models,
      model: model ?? this.model,
      years: years ?? this.years,
      year: year ?? this.year,
    );
  }

  final List<String> brands;
  final String? brand;

  final List<String> models;
  final String? model;

  final List<String> years;
  final String? year;

  bool get isComplete => brand != null && model != null && year != null;

  @override
  List<Object?> get props => [brands, brand, models, model, years, year];
}
