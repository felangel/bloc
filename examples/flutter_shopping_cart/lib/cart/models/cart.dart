import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';

@immutable
class Cart extends Equatable {
  final Catalog _catalog;
  final List<int> _itemIds;

  Cart(this._catalog, Cart previous)
      : assert(_catalog != null),
        _itemIds = previous?._itemIds ?? [];

  @override
  List<Object> get props => [_catalog, _itemIds];
}
