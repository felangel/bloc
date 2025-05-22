import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Title text shown in the AppBar of the Todos Overview Page
  ///
  /// In en, this message translates to:
  /// **'Flutter Todos'**
  String get todosOverviewAppBarTitle;

  /// Tooltip text shown in the filter dropdown of the Todos Overview Page
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get todosOverviewFilterTooltip;

  /// Text shown in the filter dropdown of the Todos Overview Page for the option to display all todos
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get todosOverviewFilterAll;

  /// Text shown in the filter dropdown of the Todos Overview Page for the option to display active todos only
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get todosOverviewFilterActiveOnly;

  /// Text shown in the filter dropdown of the Todos Overview Page for the option to display completed todos only
  ///
  /// In en, this message translates to:
  /// **'Completed only'**
  String get todosOverviewFilterCompletedOnly;

  /// Button text shown in the options dropdown of the Todos Overview Page that marks all current todos as complete
  ///
  /// In en, this message translates to:
  /// **'Mark all complete'**
  String get todosOverviewMarkAllCompleteButtonText;

  /// Button text shown in the options dropdown of the Todos Overview Page that deletes all completed todos
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get todosOverviewClearCompletedButtonText;

  /// Text shown in the Todos Overview Page when no todos are found with the selected filters
  ///
  /// In en, this message translates to:
  /// **'No todos found with the selected filters.'**
  String get todosOverviewEmptyText;

  /// Snackbar text shown when a todo is deleted from the Todos Overview Page
  ///
  /// In en, this message translates to:
  /// **'Todo \"{todoTitle}\" deleted.'**
  String todosOverviewTodoDeletedSnackbarText(Object todoTitle);

  /// Button text shown in the snackbar that undoes a deletion of a todo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get todosOverviewUndoDeletionButtonText;

  /// Snackbar text shown when an error occurs while loading todos
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading todos.'**
  String get todosOverviewErrorSnackbarText;

  /// Tooltip text shown in the options dropdown of the Todos Overview Page
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get todosOverviewOptionsTooltip;

  /// Button text shown in the options dropdown of the Todos Overview Page that marks all todos as complete
  ///
  /// In en, this message translates to:
  /// **'Mark all as completed'**
  String get todosOverviewOptionsMarkAllComplete;

  /// Button text shown in the options dropdown of the Todos Overview Page that marks all todos as incomplete
  ///
  /// In en, this message translates to:
  /// **'Mark all as incomplete'**
  String get todosOverviewOptionsMarkAllIncomplete;

  /// Button text shown in the options dropdown of the Todos Overview Page that deletes all completed todos
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get todosOverviewOptionsClearCompleted;

  /// Title text shown in the AppBar of the Todo Details Page
  ///
  /// In en, this message translates to:
  /// **'Todo Details'**
  String get todoDetailsAppBarTitle;

  /// Tooltip text shown in the delete button on the Todo Details Page
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get todoDetailsDeleteButtonTooltip;

  /// Tooltip text shown in the edit button on the Todo Details Page
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get todoDetailsEditButtonTooltip;

  /// Title text shown in the AppBar of the Todo Edit Page when editing an existing todo
  ///
  /// In en, this message translates to:
  /// **'Edit Todo'**
  String get editTodoEditAppBarTitle;

  /// Title text shown in the AppBar of the Todo Edit Page when adding a new todo
  ///
  /// In en, this message translates to:
  /// **'Add Todo'**
  String get editTodoAddAppBarTitle;

  /// Label text shown in the title input field of the Todo Edit Page
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editTodoTitleLabel;

  /// Label text shown in the description input field of the Todo Edit Page
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get editTodoDescriptionLabel;

  /// Tooltip text shown in the save button on the Todo Edit Page
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editTodoSaveButtonTooltip;

  /// Title text shown in the AppBar of the Stats Page
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsAppBarTitle;

  /// Label text shown in the completed todos count section of the Stats Page
  ///
  /// In en, this message translates to:
  /// **'Completed todos'**
  String get statsCompletedTodoCountLabel;

  /// Label text shown in the active todos count section of the Stats Page
  ///
  /// In en, this message translates to:
  /// **'Active todos'**
  String get statsActiveTodoCountLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
