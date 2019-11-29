import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';
import './bloc.dart';

class NewCarBloc extends Bloc<NewCarEvent, NewCarState> {
  final NewCarRepository _newCarRepository;

  NewCarBloc({NewCarRepository newCarRepository})
      : _newCarRepository = newCarRepository;

  @override
  NewCarState get initialState => NewCarState.initial();

  @override
  Stream<NewCarState> mapEventToState(
    NewCarEvent event,
  ) async* {
    if (event is FormLoaded) {
      yield* _mapFormLoadedToState();
    } else if (event is BrandChanged) {
      yield* _mapBrandChangedToState(event);
    } else if (event is ModelChanged) {
      yield* _mapModelChangedToState(event);
    } else if (event is YearChanged) {
      yield* _mapYearChangedToState(event);
    }
  }

  Stream<NewCarState> _mapFormLoadedToState() async* {
    yield NewCarState.brandsLoading();
    final brands = await _newCarRepository.fetchBrands();
    yield NewCarState.brandsLoaded(brands: brands);
  }

  Stream<NewCarState> _mapBrandChangedToState(BrandChanged event) async* {
    final currentState = state;
    yield NewCarState.modelsLoading(
      brands: currentState.brands,
      brand: event.brand,
    );
    final models = await _newCarRepository.fetchModels(brand: event.brand);
    yield NewCarState.modelsLoaded(
      brands: currentState.brands,
      brand: event.brand,
      models: models,
    );
  }

  Stream<NewCarState> _mapModelChangedToState(ModelChanged event) async* {
    final currentState = state;
    yield NewCarState.yearsLoading(
      brands: currentState.brands,
      brand: currentState.brand,
      models: currentState.models,
      model: event.model,
    );
    final years = await _newCarRepository.fetchYears(
      brand: currentState.brand,
      model: event.model,
    );
    yield NewCarState.yearsLoaded(
      brands: currentState.brands,
      brand: currentState.brand,
      models: currentState.models,
      model: event.model,
      years: years,
    );
  }

  Stream<NewCarState> _mapYearChangedToState(YearChanged event) async* {
    yield state.copyWith(year: event.year);
  }
}
