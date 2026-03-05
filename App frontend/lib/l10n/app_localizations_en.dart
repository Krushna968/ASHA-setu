// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ASHA Setu';

  @override
  String get loginGreetings => 'Greetings, ASHA Worker';

  @override
  String get loginSubtext => 'Sign in to manage your daily healthcare tasks';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get individuals => 'Individuals';

  @override
  String get visits => 'Visits';

  @override
  String get inventory => 'Inventory';

  @override
  String get tasks => 'Tasks';

  @override
  String get logVisit => 'Log Visit';

  @override
  String get addIndividual => 'Add Individual';
}
