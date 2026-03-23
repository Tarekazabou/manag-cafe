import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// Title of the application
  ///
  /// In en, this message translates to:
  /// **'Coffee Shop Manager'**
  String get appTitle;

  /// Label for the sign-up button and title
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Label for the sign-in button and title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Label for the email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for the password field in the sign-up/sign-in form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for the shop code field
  ///
  /// In en, this message translates to:
  /// **'Shop Code'**
  String get shopCode;

  /// Helper text for the shop code input field
  ///
  /// In en, this message translates to:
  /// **'Enter the shop code to join a shop'**
  String get shopCodeHelper;

  /// Text for the link to switch to sign-in mode
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// Text for the link to switch to sign-up mode
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccount;

  /// Label for the join shop button
  ///
  /// In en, this message translates to:
  /// **'Join Shop'**
  String get joinShop;

  /// Error message when shop is not found
  ///
  /// In en, this message translates to:
  /// **'Shop not found. Please sign out and try again.'**
  String get shopNotFound;

  /// Label for the sign-out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Error message for sign-in failure
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in: {error}'**
  String signInError(Object error);

  /// Error message for sign-up failure
  ///
  /// In en, this message translates to:
  /// **'Failed to sign up: {error}'**
  String signUpError(Object error);

  /// Error message for failure to join shop
  ///
  /// In en, this message translates to:
  /// **'Failed to join shop: {error}'**
  String joinShopError(Object error);

  /// Success message for sending a shop join request
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully'**
  String get requestSentSuccess;

  /// Success message for signing out
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signOutSuccess;

  /// Error message for sign-out failure
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String signOutError(Object error);

  /// Title for the inventory items screen
  ///
  /// In en, this message translates to:
  /// **'Inventory Items'**
  String get itemsScreenTitle;

  /// Label for editing an inventory item
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// Title for the dashboard tab
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Title for the inventory recording screen
  ///
  /// In en, this message translates to:
  /// **'Record Quantities'**
  String get inventoryTitle;

  /// Label for low stock alerts section
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlert;

  /// Label for search items input
  ///
  /// In en, this message translates to:
  /// **'Search Items'**
  String get searchItems;

  /// Label for sorting items by name
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// Label for sorting items by quantity
  ///
  /// In en, this message translates to:
  /// **'Sort by Quantity'**
  String get sortByQuantity;

  /// Label for sorting items by threshold
  ///
  /// In en, this message translates to:
  /// **'Sort by Threshold'**
  String get sortByThreshold;

  /// Message when there are no items in inventory
  ///
  /// In en, this message translates to:
  /// **'No items in inventory.'**
  String get noItems;

  /// Confirmation message before saving quantities
  ///
  /// In en, this message translates to:
  /// **'Do you want to save the quantities and update sales?'**
  String get saveConfirmationMessage;

  /// Label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Error message when quantities are not positive
  ///
  /// In en, this message translates to:
  /// **'Quantities must be positive'**
  String get positiveQuantityError;

  /// Error message when there are no valid quantities to save
  ///
  /// In en, this message translates to:
  /// **'No valid quantities to save'**
  String get noValidQuantitiesError;

  /// Success message after saving quantities
  ///
  /// In en, this message translates to:
  /// **'Quantities saved and sales updated'**
  String get saveSuccessMessage;

  /// Label for undo button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Success message after undoing a save operation
  ///
  /// In en, this message translates to:
  /// **'Save operation undone'**
  String get undoSuccessMessage;

  /// Error message during save operation
  ///
  /// In en, this message translates to:
  /// **'Error during save'**
  String get saveError;

  /// Success message after clearing selected quantities
  ///
  /// In en, this message translates to:
  /// **'Selected quantities cleared'**
  String get clearQuantitiesSuccess;

  /// Success message after prefilling quantities
  ///
  /// In en, this message translates to:
  /// **'Quantities prefilled'**
  String get prefillQuantitiesSuccess;

  /// Tooltip for clearing selected quantities
  ///
  /// In en, this message translates to:
  /// **'Clear selected quantities'**
  String get clearSelectedQuantitiesTooltip;

  /// Tooltip for prefilling quantities
  ///
  /// In en, this message translates to:
  /// **'Prefill quantities'**
  String get prefillQuantitiesTooltip;

  /// Title for prefilling quantities dialog
  ///
  /// In en, this message translates to:
  /// **'Prefill Quantities'**
  String get prefillQuantitiesTitle;

  /// Label for quantity field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Label for buy price field
  ///
  /// In en, this message translates to:
  /// **'Buy Price'**
  String get buyPrice;

  /// Label for sell price field
  ///
  /// In en, this message translates to:
  /// **'Sell Price'**
  String get sellPrice;

  /// Label for low stock threshold field
  ///
  /// In en, this message translates to:
  /// **'Low Stock Threshold'**
  String get lowStockThreshold;

  /// Label for is sellable toggle
  ///
  /// In en, this message translates to:
  /// **'Is Sellable'**
  String get isSellable;

  /// Label for confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Tooltip for changing sort order
  ///
  /// In en, this message translates to:
  /// **'Change sort order'**
  String get sortOrderTooltip;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Label for session field
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// Label for weather field
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// Label for item field
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// Hint for quantity input field
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantityHint;

  /// Label for invalid input
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalidInput;

  /// Error message for negative quantity
  ///
  /// In en, this message translates to:
  /// **'Must be >= 0'**
  String get negativeQuantityError;

  /// Title for the sales tab
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTitle;

  /// Title for the admin tab
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminTitle;

  /// Title for the deliveries tab
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveriesTitle;

  /// Title for the statistics tab
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// Tooltip for the dashboard tab
  ///
  /// In en, this message translates to:
  /// **'View Dashboard'**
  String get dashboardTooltip;

  /// Tooltip for the inventory tab
  ///
  /// In en, this message translates to:
  /// **'Manage Inventory'**
  String get inventoryTooltip;

  /// Tooltip for the sales tab
  ///
  /// In en, this message translates to:
  /// **'View Sales'**
  String get salesTooltip;

  /// Tooltip for the admin tab
  ///
  /// In en, this message translates to:
  /// **'Access Admin Settings'**
  String get adminTooltip;

  /// Tooltip for the deliveries tab
  ///
  /// In en, this message translates to:
  /// **'Manage Deliveries'**
  String get deliveriesTooltip;

  /// Tooltip for the statistics tab
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get statisticsTooltip;

  /// Error message when loading requests fails
  ///
  /// In en, this message translates to:
  /// **'Error loading requests'**
  String get errorLoadingRequests;

  /// Message when no join requests are found
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// Message when a join request is denied
  ///
  /// In en, this message translates to:
  /// **'Request denied'**
  String get requestDenied;

  /// Message when a join request is sent and awaiting approval
  ///
  /// In en, this message translates to:
  /// **'Request sent, waiting for owner approval'**
  String get requestSentWaitingApproval;

  /// Label for an unknown user in join requests
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
