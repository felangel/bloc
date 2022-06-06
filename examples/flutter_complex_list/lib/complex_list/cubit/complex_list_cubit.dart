import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';

part 'complex_list_state.dart';

class ComplexListCubit extends Cubit<ComplexListState> {
  ComplexListCubit({required this.repository})
      : super(const ComplexListState.loading());

  final Repository repository;

  Future<void> fetchList() async {
    try {
      final items = await repository.fetchItems();
      emit(ComplexListState.success(items));
    } on Exception {
      emit(const ComplexListState.failure());
    }
  }

  Future<void> deleteItem(String id) async {
    final deleteInProgress = state.items.map((item) {
      return item.id == id ? item.copyWith(isDeleting: true) : item;
    }).toList();

    emit(ComplexListState.success(deleteInProgress));

    unawaited(
      repository.deleteItem(id).then((_) {
        final deleteSuccess = List.of(state.items)
          ..removeWhere((element) => element.id == id);
        emit(ComplexListState.success(deleteSuccess));
      }),
    );
  }
}
