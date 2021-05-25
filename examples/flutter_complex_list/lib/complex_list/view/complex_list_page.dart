import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';

class ComplexListPage extends StatelessWidget {
  const ComplexListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complex List')),
      body: BlocProvider(
        create: (_) => ComplexListCubit(
          repository: context.read<Repository>(),
        )..fetchList(),
        child: ComplexListView(),
      ),
    );
  }
}

class ComplexListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ComplexListCubit>().state;
    switch (state.status) {
      case ListStatus.failure:
        return const Center(child: Text('Oops something went wrong!'));
      case ListStatus.success:
        return ItemView(items: state.items);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}

class ItemView extends StatelessWidget {
  const ItemView({Key? key, required this.items}) : super(key: key);

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: Text('no content'))
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
    Key? key,
    required this.item,
    required this.onDeletePressed,
  }) : super(key: key);

  final Item item;
  final ValueSetter<String> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: Text('#${item.id}'),
        title: Text(item.value),
        trailing: item.isDeleting
            ? const CircularProgressIndicator()
            : IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDeletePressed(item.id),
              ),
      ),
    );
  }
}
