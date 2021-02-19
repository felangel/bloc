import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos_cubit/models/models.dart';

class TabCubit extends Cubit<AppTab> {
  TabCubit() : super(AppTab.todos);

  Future<void> tabUpdated(final AppTab tab) async {
    emit(tab);
  }
}
