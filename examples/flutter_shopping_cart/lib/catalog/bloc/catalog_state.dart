part of 'catalog_bloc.dart';

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object> get props => [];
}

final class CatalogLoading extends CatalogState {}

final class CatalogLoaded extends CatalogState {
  const CatalogLoaded(this.catalog);

  final Catalog catalog;

  @override
  List<Object> get props => [catalog];
}

final class CatalogError extends CatalogState {}
