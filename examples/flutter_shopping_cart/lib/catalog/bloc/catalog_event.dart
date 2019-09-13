import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CatalogEvent extends Equatable {
  CatalogEvent([List props = const <dynamic>[]]) : super(props);
}

class LoadCatalog extends CatalogEvent {}
