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

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get viewAll => 'View All';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get daysAgo => 'days ago';

  @override
  String get search => 'Search';

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get goodAfternoon => 'Good Afternoon,';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get housesDone => 'HOUSES DONE';

  @override
  String totalHouses(Object count) {
    return 'Total: $count Houses';
  }

  @override
  String get targetAchieved => 'Daily Target Achieved!';

  @override
  String get highRisk => 'High Risk';

  @override
  String get dueToday => 'Due Today';

  @override
  String synced(Object time) {
    return 'Synced: $time';
  }

  @override
  String get directoryTitle => 'Individual Directory';

  @override
  String registeredCount(Object count) {
    return '$count registered individuals';
  }

  @override
  String get searchHint => 'Search by name or address...';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGeneral => 'General';

  @override
  String ageLabel(Object age) {
    return 'Age $age';
  }

  @override
  String lastVisit(Object date) {
    return 'Last visit: $date';
  }

  @override
  String get todaysTasks => 'TODAY\'S TASKS';

  @override
  String pendingHouses(Object count) {
    return '$count Pending Houses';
  }

  @override
  String get allHousesVisited => 'All houses visited! 🎉';

  @override
  String get progress => 'Progress';

  @override
  String get tapToViewTasks => '• Tap to view your task calendar.';

  @override
  String get greatJob => '• Great job staying on top of your work.';

  @override
  String noMatch(Object query) {
    return 'No individuals match \"$query\"';
  }

  @override
  String get noIndividualsInCategory => 'No individuals in this category';

  @override
  String get detailsComingSoon => 'Individual Details coming soon!';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownAddress => 'Unknown Address';

  @override
  String get logVisitTitle => 'Log Healthcare Visit';

  @override
  String get selectHousehold => 'Select Household';

  @override
  String get individualStep => 'Individual';

  @override
  String get detailsStep => 'Details';

  @override
  String get notesStep => 'Notes';

  @override
  String get selectHouseLabel => 'Select a household';

  @override
  String get searchIndividualHint => 'Search individual...';

  @override
  String get noIndividualsFound => 'No individuals found for this search.';

  @override
  String get visitDate => 'Visit Date';

  @override
  String get visitType => 'Visit Type';

  @override
  String get routineCheckup => 'Routine Checkup';

  @override
  String get immunization => 'Immunization';

  @override
  String get followUp => 'Follow-up';

  @override
  String get emergency => 'Emergency';

  @override
  String get symptomsObserved => 'Symptoms Observed';

  @override
  String get otherObservationsHint => 'Any other observations...';

  @override
  String get houseClosed => 'House was closed';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get submitVisit => 'Submit Visit';

  @override
  String get successVisitLogged => 'Visit logged successfully!';

  @override
  String get visitLoggedAndHouseClosed =>
      'Visit logged & house marked as closed!';

  @override
  String get visitLoggedSuccessfully => 'Visit logged successfully!';

  @override
  String get visitSavedOffline => 'Visit saved offline (will sync later)';

  @override
  String get failed => 'Failed';

  @override
  String get house => 'House';

  @override
  String get individual => 'Individual';

  @override
  String get details => 'Details';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get noHouseholdsFound => 'No households found';

  @override
  String get members => 'members';

  @override
  String get individualsInThisHouse => 'individuals in this house';

  @override
  String get noIndividualsInThisHouse => 'No individuals in this house';

  @override
  String get registerIndividualPrompt =>
      'Register an individual to this house first';

  @override
  String get age => 'Age';

  @override
  String get ancFollowUp => 'ANC Follow-up';

  @override
  String get pncFollowUp => 'PNC Follow-up';

  @override
  String get medicineDelivery => 'Medicine Delivery';

  @override
  String get healthEducation => 'Health Education';

  @override
  String get feverHighTemperature => 'Fever / High Temperature';

  @override
  String get persistentCough => 'Persistent Cough';

  @override
  String get breathingDifficulty => 'Breathing Difficulty';

  @override
  String get diarrheaStomachPain => 'Diarrhea / Stomach Pain';

  @override
  String get bodyPainWeakness => 'Body Pain / Weakness';

  @override
  String get skinRashAllergy => 'Skin Rash / Allergy';

  @override
  String get tapAllThatApply => 'Tap all that apply';

  @override
  String get notesObservations => 'Notes / Observations';

  @override
  String get anyAdditionalObservations => 'Any additional observations...';

  @override
  String get markHouseAsClosed => 'Mark House as Closed';

  @override
  String get houseClosedExplanation =>
      'This will grey out the house on the map';

  @override
  String get submitAndCloseHouse => 'Submit & Close House';

  @override
  String get continueText => 'Continue';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get calendar => 'Calendar';

  @override
  String get profile => 'Profile';
}
