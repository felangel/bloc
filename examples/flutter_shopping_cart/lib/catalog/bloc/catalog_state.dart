part of 'catalog_bloc.dart';

@immutable
abstract class CatalogState extends Equatable {
  const CatalogState();
}

class CatalogLoading extends CatalogState {
  @override
  List<Object> get props => [];
}

class CatalogLoaded extends CatalogState {
  final Catalog catalog;

  const CatalogLoaded(this.catalog);

  @override
  List<Object> get props => [catalog];
}

class CatalogError extends CatalogState {
  @override
  List<Object> get props => [];
}
