import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  @override
  CatalogState get initialState => CatalogLoading();

  @override
  Stream<CatalogState> mapEventToState(
    CatalogEvent event,
  ) async* {
    if (event is LoadCatalog) {
      yield* _mapLoadCatalogToState();
    }
  }

  Stream<CatalogState> _mapLoadCatalogToState() async* {
    yield CatalogLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500));
      yield CatalogLoaded(Catalog());
    } catch (_) {
      yield CatalogError();
    }
  }
}
