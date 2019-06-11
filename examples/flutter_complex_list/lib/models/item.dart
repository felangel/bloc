import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String value;
  final bool isDeleting;

  Item({
    @required this.id,
    @required this.value,
    this.isDeleting = false,
  }) : super([id, value, isDeleting]);

  Item copyWith({
    String id,
    String value,
    bool isDeleting,
  }) {
    return Item(
      id: id ?? this.id,
      value: value ?? this.value,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  String toString() =>
      'Item { id: $id, value: $value, isDeleting: $isDeleting }';
}
