// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coffee Shop Manager';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get shopCode => 'Shop Code';

  @override
  String get shopCodeHelper => 'Enter the shop code to join a shop';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get joinShop => 'Join Shop';

  @override
  String get shopNotFound => 'Shop not found. Please sign out and try again.';

  @override
  String get signOut => 'Sign Out';

  @override
  String signInError(Object error) {
    return 'Failed to sign in: $error';
  }

  @override
  String signUpError(Object error) {
    return 'Failed to sign up: $error';
  }

  @override
  String joinShopError(Object error) {
    return 'Failed to join shop: $error';
  }

  @override
  String get requestSentSuccess => 'Request sent successfully';

  @override
  String get signOutSuccess => 'Signed out successfully';

  @override
  String signOutError(Object error) {
    return 'Error signing out: $error';
  }

  @override
  String get itemsScreenTitle => 'Inventory Items';

  @override
  String get editItem => 'Edit Item';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get inventoryTitle => 'Record Quantities';

  @override
  String get lowStockAlert => 'Low Stock Alerts';

  @override
  String get searchItems => 'Search Items';

  @override
  String get sortByName => 'Sort by Name';

  @override
  String get sortByQuantity => 'Sort by Quantity';

  @override
  String get sortByThreshold => 'Sort by Threshold';

  @override
  String get noItems => 'No items in inventory.';

  @override
  String get saveConfirmationMessage =>
      'Do you want to save the quantities and update sales?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get positiveQuantityError => 'Quantities must be positive';

  @override
  String get noValidQuantitiesError => 'No valid quantities to save';

  @override
  String get saveSuccessMessage => 'Quantities saved and sales updated';

  @override
  String get undo => 'Undo';

  @override
  String get undoSuccessMessage => 'Save operation undone';

  @override
  String get saveError => 'Error during save';

  @override
  String get clearQuantitiesSuccess => 'Selected quantities cleared';

  @override
  String get prefillQuantitiesSuccess => 'Quantities prefilled';

  @override
  String get clearSelectedQuantitiesTooltip => 'Clear selected quantities';

  @override
  String get prefillQuantitiesTooltip => 'Prefill quantities';

  @override
  String get prefillQuantitiesTitle => 'Prefill Quantities';

  @override
  String get quantity => 'Quantity';

  @override
  String get buyPrice => 'Buy Price';

  @override
  String get sellPrice => 'Sell Price';

  @override
  String get lowStockThreshold => 'Low Stock Threshold';

  @override
  String get isSellable => 'Is Sellable';

  @override
  String get confirm => 'Confirm';

  @override
  String get sortOrderTooltip => 'Change sort order';

  @override
  String get date => 'Date';

  @override
  String get session => 'Session';

  @override
  String get weather => 'Weather';

  @override
  String get item => 'Item';

  @override
  String get quantityHint => 'Qty';

  @override
  String get invalidInput => 'Invalid';

  @override
  String get negativeQuantityError => 'Must be >= 0';

  @override
  String get salesTitle => 'Sales';

  @override
  String get adminTitle => 'Admin';

  @override
  String get deliveriesTitle => 'Deliveries';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get dashboardTooltip => 'View Dashboard';

  @override
  String get inventoryTooltip => 'Manage Inventory';

  @override
  String get salesTooltip => 'View Sales';

  @override
  String get adminTooltip => 'Access Admin Settings';

  @override
  String get deliveriesTooltip => 'Manage Deliveries';

  @override
  String get statisticsTooltip => 'View Statistics';

  @override
  String get errorLoadingRequests => 'Error loading requests';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get requestDenied => 'Request denied';

  @override
  String get requestSentWaitingApproval =>
      'Request sent, waiting for owner approval';

  @override
  String get unknownUser => 'Unknown User';
}
