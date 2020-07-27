part of 'catalog_bloc.dart';

@immutable
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
}

class CatalogStarted extends CatalogEvent {
  @override
  List<Object> get props => [];
}
