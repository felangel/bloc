part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();
}

final class CatalogStarted extends CatalogEvent {
  @override
  List<Object> get props => [];
}
