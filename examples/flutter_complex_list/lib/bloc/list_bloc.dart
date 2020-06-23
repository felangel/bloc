import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_complex_list/models/models.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  final Repository repository;

  ListBloc({@required this.repository}) : super(Loading());

  @override
  Stream<ListState> mapEventToState(
    ListEvent event,
  ) async* {
    if (event is Fetch) {
      try {
        final items = await repository.fetchItems();
        yield Loaded(items: items);
      } catch (_) {
        yield Failure();
      }
    }
    if (event is Delete) {
      final listState = state;
      if (listState is Loaded) {
        final List<Item> updatedItems =
            List<Item>.from(listState.items).map((Item item) {
          return item.id == event.id ? item.copyWith(isDeleting: true) : item;
        }).toList();
        yield Loaded(items: updatedItems);
        repository.deleteItem(event.id).listen((id) {
          add(Deleted(id: id));
        });
      }
    }
    if (event is Deleted) {
      final listState = state;
      if (listState is Loaded) {
        final List<Item> updatedItems = List<Item>.from(listState.items)
          ..removeWhere((item) => item.id == event.id);
        yield Loaded(items: updatedItems);
      }
    }
  }
}
