import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';
import 'package:meta/meta.dart';

part 'new_car_event.dart';
part 'new_car_state.dart';

class NewCarBloc extends Bloc<NewCarEvent, NewCarState> {
  NewCarBloc({required NewCarRepository newCarRepository})
      : _newCarRepository = newCarRepository,
        super(NewCarState.initial());

  final NewCarRepository _newCarRepository;

  @override
  Stream<NewCarState> mapEventToState(
    NewCarEvent event,
  ) async* {
    if (event is NewCarFormLoaded) {
      yield* _mapNewCarFormLoadedToState();
    } else if (event is NewCarBrandChanged) {
      yield* _mapNewCarBrandChangedToState(event, state);
    } else if (event is NewCarModelChanged) {
      yield* _mapNewCarModelChangedToState(event, state);
    } else if (event is NewCarYearChanged) {
      yield _mapNewCarYearChangedToState(event);
    }
  }

  Stream<NewCarState> _mapNewCarFormLoadedToState() async* {
    yield NewCarState.brandsLoadInProgress();
    final brands = await _newCarRepository.fetchBrands();
    yield NewCarState.brandsLoadSuccess(brands: brands);
  }

  Stream<NewCarState> _mapNewCarBrandChangedToState(
    NewCarBrandChanged event,
    NewCarState state,
  ) async* {
    yield NewCarState.modelsLoadInProgress(
      brands: state.brands,
      brand: event.brand,
    );
    final models = await _newCarRepository.fetchModels(brand: event.brand);
    yield NewCarState.modelsLoadSuccess(
      brands: state.brands,
      brand: event.brand,
      models: models,
    );
  }

  Stream<NewCarState> _mapNewCarModelChangedToState(
    NewCarModelChanged event,
    NewCarState state,
  ) async* {
    yield NewCarState.yearsLoadInProgress(
      brands: state.brands,
      brand: state.brand,
      models: state.models,
      model: event.model,
    );
    final years = await _newCarRepository.fetchYears(
      brand: state.brand,
      model: event.model,
    );
    yield NewCarState.yearsLoadSuccess(
      brands: state.brands,
      brand: state.brand,
      models: state.models,
      model: event.model,
      years: years,
    );
  }

  NewCarState _mapNewCarYearChangedToState(NewCarYearChanged event) {
    return state.copyWith(year: event.year);
  }
}
