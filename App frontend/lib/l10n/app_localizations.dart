import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ASHA Setu'**
  String get appTitle;

  /// No description provided for @loginGreetings.
  ///
  /// In en, this message translates to:
  /// **'Greetings, ASHA Worker'**
  String get loginGreetings;

  /// No description provided for @loginSubtext.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your daily healthcare tasks'**
  String get loginSubtext;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @individuals.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get individuals;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visits;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @logVisit.
  ///
  /// In en, this message translates to:
  /// **'Log Visit'**
  String get logVisit;

  /// No description provided for @addIndividual.
  ///
  /// In en, this message translates to:
  /// **'Add Individual'**
  String get addIndividual;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @housesDone.
  ///
  /// In en, this message translates to:
  /// **'HOUSES DONE'**
  String get housesDone;

  /// No description provided for @totalHouses.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} Houses'**
  String totalHouses(Object count);

  /// No description provided for @targetAchieved.
  ///
  /// In en, this message translates to:
  /// **'Daily Target Achieved!'**
  String get targetAchieved;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced: {time}'**
  String synced(Object time);

  /// No description provided for @directoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Individual Directory'**
  String get directoryTitle;

  /// No description provided for @registeredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} registered individuals'**
  String registeredCount(Object count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or address...'**
  String get searchHint;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String ageLabel(Object age);

  /// No description provided for @lastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last visit: {date}'**
  String lastVisit(Object date);

  /// No description provided for @todaysTasks.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S TASKS'**
  String get todaysTasks;

  /// No description provided for @pendingHouses.
  ///
  /// In en, this message translates to:
  /// **'{count} Pending Houses'**
  String pendingHouses(Object count);

  /// No description provided for @allHousesVisited.
  ///
  /// In en, this message translates to:
  /// **'All houses visited! 🎉'**
  String get allHousesVisited;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @tapToViewTasks.
  ///
  /// In en, this message translates to:
  /// **'• Tap to view your task calendar.'**
  String get tapToViewTasks;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'• Great job staying on top of your work.'**
  String get greatJob;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No individuals match \"{query}\"'**
  String noMatch(Object query);

  /// No description provided for @noIndividualsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No individuals in this category'**
  String get noIndividualsInCategory;

  /// No description provided for @detailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Individual Details coming soon!'**
  String get detailsComingSoon;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownAddress.
  ///
  /// In en, this message translates to:
  /// **'Unknown Address'**
  String get unknownAddress;

  /// No description provided for @logVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Healthcare Visit'**
  String get logVisitTitle;

  /// No description provided for @selectHousehold.
  ///
  /// In en, this message translates to:
  /// **'Select Household'**
  String get selectHousehold;

  /// No description provided for @individualStep.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualStep;

  /// No description provided for @detailsStep.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsStep;

  /// No description provided for @notesStep.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesStep;

  /// No description provided for @selectHouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a household'**
  String get selectHouseLabel;

  /// No description provided for @searchIndividualHint.
  ///
  /// In en, this message translates to:
  /// **'Search individual...'**
  String get searchIndividualHint;

  /// No description provided for @noIndividualsFound.
  ///
  /// In en, this message translates to:
  /// **'No individuals found for this search.'**
  String get noIndividualsFound;

  /// No description provided for @visitDate.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get visitDate;

  /// No description provided for @visitType.
  ///
  /// In en, this message translates to:
  /// **'Visit Type'**
  String get visitType;

  /// No description provided for @routineCheckup.
  ///
  /// In en, this message translates to:
  /// **'Routine Checkup'**
  String get routineCheckup;

  /// No description provided for @immunization.
  ///
  /// In en, this message translates to:
  /// **'Immunization'**
  String get immunization;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @symptomsObserved.
  ///
  /// In en, this message translates to:
  /// **'Symptoms Observed'**
  String get symptomsObserved;

  /// No description provided for @otherObservationsHint.
  ///
  /// In en, this message translates to:
  /// **'Any other observations...'**
  String get otherObservationsHint;

  /// No description provided for @houseClosed.
  ///
  /// In en, this message translates to:
  /// **'House was closed'**
  String get houseClosed;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @submitVisit.
  ///
  /// In en, this message translates to:
  /// **'Submit Visit'**
  String get submitVisit;

  /// No description provided for @successVisitLogged.
  ///
  /// In en, this message translates to:
  /// **'Visit logged successfully!'**
  String get successVisitLogged;

  /// No description provided for @visitLoggedAndHouseClosed.
  ///
  /// In en, this message translates to:
  /// **'Visit logged & house marked as closed!'**
  String get visitLoggedAndHouseClosed;

  /// No description provided for @visitLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Visit logged successfully!'**
  String get visitLoggedSuccessfully;

  /// No description provided for @visitSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Visit saved offline (will sync later)'**
  String get visitSavedOffline;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @noHouseholdsFound.
  ///
  /// In en, this message translates to:
  /// **'No households found'**
  String get noHouseholdsFound;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @individualsInThisHouse.
  ///
  /// In en, this message translates to:
  /// **'individuals in this house'**
  String get individualsInThisHouse;

  /// No description provided for @noIndividualsInThisHouse.
  ///
  /// In en, this message translates to:
  /// **'No individuals in this house'**
  String get noIndividualsInThisHouse;

  /// No description provided for @registerIndividualPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register an individual to this house first'**
  String get registerIndividualPrompt;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ancFollowUp.
  ///
  /// In en, this message translates to:
  /// **'ANC Follow-up'**
  String get ancFollowUp;

  /// No description provided for @pncFollowUp.
  ///
  /// In en, this message translates to:
  /// **'PNC Follow-up'**
  String get pncFollowUp;

  /// No description provided for @medicineDelivery.
  ///
  /// In en, this message translates to:
  /// **'Medicine Delivery'**
  String get medicineDelivery;

  /// No description provided for @healthEducation.
  ///
  /// In en, this message translates to:
  /// **'Health Education'**
  String get healthEducation;

  /// No description provided for @feverHighTemperature.
  ///
  /// In en, this message translates to:
  /// **'Fever / High Temperature'**
  String get feverHighTemperature;

  /// No description provided for @persistentCough.
  ///
  /// In en, this message translates to:
  /// **'Persistent Cough'**
  String get persistentCough;

  /// No description provided for @breathingDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Breathing Difficulty'**
  String get breathingDifficulty;

  /// No description provided for @diarrheaStomachPain.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea / Stomach Pain'**
  String get diarrheaStomachPain;

  /// No description provided for @bodyPainWeakness.
  ///
  /// In en, this message translates to:
  /// **'Body Pain / Weakness'**
  String get bodyPainWeakness;

  /// No description provided for @skinRashAllergy.
  ///
  /// In en, this message translates to:
  /// **'Skin Rash / Allergy'**
  String get skinRashAllergy;

  /// No description provided for @tapAllThatApply.
  ///
  /// In en, this message translates to:
  /// **'Tap all that apply'**
  String get tapAllThatApply;

  /// No description provided for @notesObservations.
  ///
  /// In en, this message translates to:
  /// **'Notes / Observations'**
  String get notesObservations;

  /// No description provided for @anyAdditionalObservations.
  ///
  /// In en, this message translates to:
  /// **'Any additional observations...'**
  String get anyAdditionalObservations;

  /// No description provided for @markHouseAsClosed.
  ///
  /// In en, this message translates to:
  /// **'Mark House as Closed'**
  String get markHouseAsClosed;

  /// No description provided for @houseClosedExplanation.
  ///
  /// In en, this message translates to:
  /// **'This will grey out the house on the map'**
  String get houseClosedExplanation;

  /// No description provided for @submitAndCloseHouse.
  ///
  /// In en, this message translates to:
  /// **'Submit & Close House'**
  String get submitAndCloseHouse;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;
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
      <String>['en', 'hi', 'mr', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
