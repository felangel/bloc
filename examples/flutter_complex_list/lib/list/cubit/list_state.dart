part of 'list_cubit.dart';

enum ListStatus { loading, success, failure }

class ListState extends Equatable {
  const ListState._({
    this.status = ListStatus.loading,
    this.items = const <Item>[],
  });

  const ListState.loading() : this._();

  const ListState.success(List<Item> items)
      : this._(status: ListStatus.success, items: items);

  const ListState.failure() : this._(status: ListStatus.failure);

  final ListStatus status;
  final List<Item> items;

  @override
  List<Object> get props => [status, items];
}
