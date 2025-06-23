// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get todosOverviewAppBarTitle => 'Flutter Todos';

  @override
  String get todosOverviewFilterTooltip => 'Filter';

  @override
  String get todosOverviewFilterAll => 'All';

  @override
  String get todosOverviewFilterActiveOnly => 'Active only';

  @override
  String get todosOverviewFilterCompletedOnly => 'Completed only';

  @override
  String get todosOverviewMarkAllCompleteButtonText => 'Mark all complete';

  @override
  String get todosOverviewClearCompletedButtonText => 'Clear completed';

  @override
  String get todosOverviewEmptyText =>
      'No todos found with the selected filters.';

  @override
  String todosOverviewTodoDeletedSnackbarText(Object todoTitle) {
    return 'Todo \"$todoTitle\" deleted.';
  }

  @override
  String get todosOverviewUndoDeletionButtonText => 'Undo';

  @override
  String get todosOverviewErrorSnackbarText =>
      'An error occurred while loading todos.';

  @override
  String get todosOverviewOptionsTooltip => 'Options';

  @override
  String get todosOverviewOptionsMarkAllComplete => 'Mark all as completed';

  @override
  String get todosOverviewOptionsMarkAllIncomplete => 'Mark all as incomplete';

  @override
  String get todosOverviewOptionsClearCompleted => 'Clear completed';

  @override
  String get todoDetailsAppBarTitle => 'Todo Details';

  @override
  String get todoDetailsDeleteButtonTooltip => 'Delete';

  @override
  String get todoDetailsEditButtonTooltip => 'Edit';

  @override
  String get editTodoEditAppBarTitle => 'Edit Todo';

  @override
  String get editTodoAddAppBarTitle => 'Add Todo';

  @override
  String get editTodoTitleLabel => 'Title';

  @override
  String get editTodoDescriptionLabel => 'Description';

  @override
  String get editTodoSaveButtonTooltip => 'Save changes';

  @override
  String get statsAppBarTitle => 'Stats';

  @override
  String get statsCompletedTodoCountLabel => 'Completed todos';

  @override
  String get statsActiveTodoCountLabel => 'Active todos';
}
