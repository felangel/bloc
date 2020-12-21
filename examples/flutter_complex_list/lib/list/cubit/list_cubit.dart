import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_complex_list/list/list.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:pedantic/pedantic.dart';

part 'list_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit({required this.repository}) : super(const ListState.loading());

  final Repository repository;

  Future<void> fetchList() async {
    try {
      final items = await repository.fetchItems();
      emit(ListState.success(items));
    } on Exception {
      emit(const ListState.failure());
    }
  }

  Future<void> deleteItem(String id) async {
    final deleteInProgress = state.items.map((item) {
      return item.id == id ? item.copyWith(isDeleting: true) : item;
    }).toList();

    emit(ListState.success(deleteInProgress));

    unawaited(repository.deleteItem(id).then((_) {
      final deleteSuccess = List.of(state.items)
        ..removeWhere((element) => element.id == id);
      emit(ListState.success(deleteSuccess));
    }));
  }
}
