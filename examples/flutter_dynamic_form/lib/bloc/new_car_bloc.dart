import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';
import 'package:meta/meta.dart';

part 'new_car_event.dart';
part 'new_car_state.dart';

class NewCarBloc extends Bloc<NewCarEvent, NewCarState> {
  final NewCarRepository _newCarRepository;

  NewCarBloc({NewCarRepository newCarRepository})
      : _newCarRepository = newCarRepository,
        super(NewCarState.initial());

  @override
  Stream<NewCarState> mapEventToState(
    NewCarEvent event,
  ) async* {
    if (event is NewCarFormLoaded) {
      yield* _mapNewCarFormLoadedToState();
    } else if (event is NewCarBrandChanged) {
      yield* _mapNewCarBrandChangedToState(event);
    } else if (event is NewCarModelChanged) {
      yield* _mapNewCarModelChangedToState(event);
    } else if (event is NewCarYearChanged) {
      yield* _mapNewCarYearChangedToState(event);
    }
  }

  Stream<NewCarState> _mapNewCarFormLoadedToState() async* {
    yield NewCarState.brandsLoadInProgress();
    final brands = await _newCarRepository.fetchBrands();
    yield NewCarState.brandsLoadSuccess(brands: brands);
  }

  Stream<NewCarState> _mapNewCarBrandChangedToState(
      NewCarBrandChanged event) async* {
    final currentState = state;
    yield NewCarState.modelsLoadInProgress(
      brands: currentState.brands,
      brand: event.brand,
    );
    final models = await _newCarRepository.fetchModels(brand: event.brand);
    yield NewCarState.modelsLoadSuccess(
      brands: currentState.brands,
      brand: event.brand,
      models: models,
    );
  }

  Stream<NewCarState> _mapNewCarModelChangedToState(
      NewCarModelChanged event) async* {
    final currentState = state;
    yield NewCarState.yearsLoadInProgress(
      brands: currentState.brands,
      brand: currentState.brand,
      models: currentState.models,
      model: event.model,
    );
    final years = await _newCarRepository.fetchYears(
      brand: currentState.brand,
      model: event.model,
    );
    yield NewCarState.yearsLoadSuccess(
      brands: currentState.brands,
      brand: currentState.brand,
      models: currentState.models,
      model: event.model,
      years: years,
    );
  }

  Stream<NewCarState> _mapNewCarYearChangedToState(
      NewCarYearChanged event) async* {
    yield state.copyWith(year: event.year);
  }
}
