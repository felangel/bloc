import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:flutter_todos/edit_todo/riverpod/edit_todo_notifier.dart';

import 'package:flutter_todos/edit_todo/riverpod/edit_todo_state.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

class EditTodoPage extends ConsumerWidget {
  const EditTodoPage({super.key, this.initialTodo});

  final Todo? initialTodo;

  static Route<void> route({Todo? initialTodo}) => MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ProviderScope(
          overrides: [
            editTodoNotifierProvider.overrideWith(
              (ref) => EditTodoNotifier(
                ref.read(todosRepositoryProvider),
                initialTodo,
              ),
            ),
          ],
          child: EditTodoPage(initialTodo: initialTodo),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(editTodoNotifierProvider);

    ref.listen<EditTodoState>(
      editTodoNotifierProvider,
      (previous, state) {
        if (state.status == EditTodoStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == EditTodoStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('failure'),
              backgroundColor: Color(0xFFF44336),
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.initialTodo == null
              ? l10n.editTodoAddAppBarTitle
              : l10n.editTodoEditAppBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.status.isLoadingOrSuccess
            ? null
            : () => ref.read(editTodoNotifierProvider.notifier).submit(),
        child: state.status.isLoadingOrSuccess
            ? const CircularProgressIndicator()
            : const Icon(Icons.check),
      ),
      body: EditTodoView(initialTodo: state.initialTodo),
    );
  }
}

class EditTodoView extends ConsumerWidget {
  const EditTodoView({super.key, this.initialTodo});

  final Todo? initialTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Refactor, not efficacious.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TitleField(initialValue: initialTodo?.title ?? ''),
            const SizedBox(height: 8),
            _DescriptionField(initialValue: initialTodo?.description ?? ''),
          ],
        ),
      ),
    );
  }
}

class _TitleField extends ConsumerWidget {
  const _TitleField({required this.initialValue});

  final String initialValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return TextFormField(
      key: const Key('editTodoView_title_textFormField'),
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: l10n.editTodoTitleLabel,
      ),
      maxLength: 50,
      onChanged: (value) =>
          ref.read(editTodoNotifierProvider.notifier).titleChanged(value),
    );
  }
}

class _DescriptionField extends ConsumerWidget {
  const _DescriptionField({required this.initialValue});

  final String initialValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: l10n.editTodoDescriptionLabel,
      ),
      maxLength: 300,
      maxLines: 5,
      onChanged: (value) =>
          ref.read(editTodoNotifierProvider.notifier).descriptionChanged(value),
    );
  }
}
