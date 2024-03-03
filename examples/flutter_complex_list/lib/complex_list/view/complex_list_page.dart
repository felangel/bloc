import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';

class ComplexListPage extends StatelessWidget {
  const ComplexListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => ComplexListCubit(
          repository: context.read<Repository>(),
        )..fetchList(),
        child: const ComplexListView(),
      ),
    );
  }
}

class ComplexListView extends StatelessWidget {
  const ComplexListView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ComplexListCubit>().state;
    switch (state.status) {
      case ListStatus.failure:
        return const Center(child: Text('Oops something went wrong!'));
      case ListStatus.success:
        return ItemView(items: state.items);
      case ListStatus.loading:
        return const Center(child: CircularProgressIndicator());
    }
  }
}

class ItemView extends StatelessWidget {
  const ItemView({required this.items, super.key});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: Text('No Content'))
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ItemTile(
                item: items[index],
                onDeletePressed: (id) {
                  context.read<ComplexListCubit>().deleteItem(id);
                },
              );
            },
            itemCount: items.length,
          );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({
    required this.item,
    required this.onDeletePressed,
    super.key,
  });

  final Item item;
  final ValueSetter<String> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: ListTile(
        title: Text(item.value),
        trailing: item.isDeleting
            ? const CircularProgressIndicator()
            : IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.error),
                onPressed: () => onDeletePressed(item.id),
              ),
      ),
    );
  }
}
