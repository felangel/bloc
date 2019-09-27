import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
}

class LoadCatalog extends CatalogEvent {
  @override
  List<Object> get props => [];
}
