part of 'complex_list_cubit.dart';

enum ListStatus { loading, success, failure }

class ComplexListState extends Equatable {
  const ComplexListState._({
    this.status = ListStatus.loading,
    this.items = const <Item>[],
  });

  const ComplexListState.loading() : this._();

  const ComplexListState.success(List<Item> items)
      : this._(status: ListStatus.success, items: items);

  const ComplexListState.failure() : this._(status: ListStatus.failure);

  final ListStatus status;
  final List<Item> items;

  @override
  List<Object> get props => [status, items];
}
