part of 'catalog_bloc.dart';

@immutable
abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object> get props => [];
}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  const CatalogLoaded(this.catalog);

  final Catalog catalog;

  @override
  List<Object> get props => [catalog];
}

class CatalogError extends CatalogState {}
