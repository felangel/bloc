import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complex_list/list/list.dart';

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complex List')),
      body: BlocBuilder<ListCubit, ListState>(
        builder: (context, state) {
          switch (state.status) {
            case ListStatus.failure:
              return const Center(child: Text('Oops something went wrong!'));
            case ListStatus.success:
              return _ListView(items: state.items);
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({Key? key, required this.items}) : super(key: key);

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: Text('no content'))
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return _ItemTile(
                item: items[index],
                onDeletePressed: (id) {
                  context.read<ListCubit>().deleteItem(id);
                },
              );
            },
            itemCount: items.length,
          );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    Key? key,
    required this.item,
    required this.onDeletePressed,
  }) : super(key: key);

  final Item item;
  final ValueSetter<String> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('#${item.id}'),
      title: Text(item.value),
      trailing: item.isDeleting
          ? const CircularProgressIndicator()
          : IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDeletePressed(item.id),
            ),
    );
  }
}
