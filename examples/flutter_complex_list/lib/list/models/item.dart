import 'package:equatable/equatable.dart';

class Item extends Equatable {
  const Item({
    required this.id,
    required this.value,
    this.isDeleting = false,
  });

  final String id;
  final String value;
  final bool isDeleting;

  Item copyWith({String? id, String? value, bool? isDeleting}) {
    return Item(
      id: id ?? this.id,
      value: value ?? this.value,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object> get props => [id, value, isDeleting];
}
