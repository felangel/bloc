import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(CatalogLoading());

  @override
  Stream<CatalogState> mapEventToState(
    CatalogEvent event,
  ) async* {
    if (event is CatalogStarted) {
      yield* _mapCatalogStartedToState();
    }
  }

  Stream<CatalogState> _mapCatalogStartedToState() async* {
    yield CatalogLoading();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      yield CatalogLoaded(Catalog());
    } catch (_) {
      yield CatalogError();
    }
  }
}
