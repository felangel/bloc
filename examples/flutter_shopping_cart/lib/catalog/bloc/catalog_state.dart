import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/catalog/models/models.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CatalogState extends Equatable {
  CatalogState([List props = const <dynamic>[]]) : super(props);
}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final Catalog catalog;

  CatalogLoaded(this.catalog) : super([catalog]);
}

class CatalogError extends CatalogState {}
