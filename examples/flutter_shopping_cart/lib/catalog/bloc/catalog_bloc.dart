import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:meta/meta.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required this.shoppingRepository}) : super(CatalogLoading());

  final ShoppingRepository shoppingRepository;

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
      final catalog = await shoppingRepository.fetchCatalog();
      yield CatalogLoaded(Catalog(itemNames: catalog));
    } catch (_) {
      yield CatalogError();
    }
  }
}
