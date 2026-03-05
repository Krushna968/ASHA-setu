// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'आशा सेतु';

  @override
  String get loginGreetings => 'नमस्ते, आशा दीदी';

  @override
  String get loginSubtext =>
      'अपने दैनिक स्वास्थ्य कार्यों को प्रबंधित करने के लिए साइन इन करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get individuals => 'व्यक्तियों';

  @override
  String get visits => 'मुलाकातें';

  @override
  String get inventory => 'भंडार';

  @override
  String get tasks => 'कार्य';

  @override
  String get logVisit => 'मुलाकात दर्ज करें';

  @override
  String get addIndividual => 'व्यक्ति जोड़ें';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get confirmLogout => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get retry => 'पुन: प्रयास करें';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get daysAgo => 'दिन पहले';

  @override
  String get search => 'खोजें';

  @override
  String get goodMorning => 'शुभ प्रभात,';

  @override
  String get goodAfternoon => 'शुभ दोपहर,';

  @override
  String get goodEvening => 'शुभ संध्या,';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get recentActivity => 'हालिया गतिविधि';

  @override
  String get housesDone => 'घर पूरे हुए';

  @override
  String totalHouses(Object count) {
    return 'कुल: $count घर';
  }

  @override
  String get targetAchieved => 'दैनिक लक्ष्य प्राप्त हुआ!';

  @override
  String get highRisk => 'उच्च जोखिम';

  @override
  String get dueToday => 'आज देय';

  @override
  String synced(Object time) {
    return 'सिंक किया गया: $time';
  }

  @override
  String get directoryTitle => 'व्यक्ति निर्देशिका';

  @override
  String registeredCount(Object count) {
    return '$count पंजीकृत व्यक्ति';
  }

  @override
  String get searchHint => 'नाम या पते से खोजें...';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoryGeneral => 'सामान्य';

  @override
  String ageLabel(Object age) {
    return 'आयु $age';
  }

  @override
  String lastVisit(Object date) {
    return 'पिछली मुलाकात: $date';
  }

  @override
  String get todaysTasks => 'आज के कार्य';

  @override
  String pendingHouses(Object count) {
    return '$count लंबित घर';
  }

  @override
  String get allHousesVisited => 'सभी घर पूरे हुए! 🎉';

  @override
  String get progress => 'प्रगति';

  @override
  String get tapToViewTasks => '• अपने कार्य कैलेंडर को देखने के लिए टैप करें।';

  @override
  String get greatJob => '• अपने काम पर बने रहने के लिए बहुत अच्छा काम किया।';

  @override
  String noMatch(Object query) {
    return '\"$query\" से कोई व्यक्ति नहीं मिला';
  }

  @override
  String get noIndividualsInCategory => 'इस श्रेणी में कोई व्यक्ति नहीं है';

  @override
  String get detailsComingSoon => 'व्यक्ति का विवरण जल्द ही आ रहा है!';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get unknownAddress => 'अज्ञात पता';

  @override
  String get logVisitTitle => 'स्वास्थ्य मुलाकात दर्ज करें';

  @override
  String get selectHousehold => 'घर चुनें';

  @override
  String get individualStep => 'व्यक्ति';

  @override
  String get detailsStep => 'विवरण';

  @override
  String get notesStep => 'नोट्स';

  @override
  String get selectHouseLabel => 'एक घर चुनें';

  @override
  String get searchIndividualHint => 'व्यक्ति खोजें...';

  @override
  String get noIndividualsFound => 'इस खोज के लिए कोई व्यक्ति नहीं मिला।';

  @override
  String get visitDate => 'मुलाकात की तारीख';

  @override
  String get visitType => 'मुलाकात का प्रकार';

  @override
  String get routineCheckup => 'नियमित जांच';

  @override
  String get immunization => 'टीकाकरण';

  @override
  String get followUp => 'अनुवर्ती कार्रवाई';

  @override
  String get emergency => 'आपातकालीन';

  @override
  String get symptomsObserved => 'देखे गए लक्षण';

  @override
  String get otherObservationsHint => 'कोई अन्य अवलोकन...';

  @override
  String get houseClosed => 'घर बंद था';

  @override
  String get next => 'अगला';

  @override
  String get back => 'पीछे';

  @override
  String get submitVisit => 'मुलाकात जमा करें';

  @override
  String get successVisitLogged => 'मुलाकात सफलतापूर्वक दर्ज की गई!';

  @override
  String get visitLoggedAndHouseClosed =>
      'मुलाकात दर्ज की गई और घर को बंद घोषित किया गया!';

  @override
  String get visitLoggedSuccessfully => 'मुलाकात सफलतापूर्वक दर्ज की गई!';

  @override
  String get visitSavedOffline =>
      'मुलाकात ऑफ़लाइन सहेजी गई (बाद में सिंक होगी)';

  @override
  String get failed => 'विफल';

  @override
  String get house => 'घर';

  @override
  String get individual => 'व्यक्ति';

  @override
  String get details => 'विवरण';

  @override
  String get symptoms => 'लक्षण';

  @override
  String get noHouseholdsFound => 'कोई घर नहीं मिला';

  @override
  String get members => 'सदस्य';

  @override
  String get individualsInThisHouse => 'इस घर में व्यक्ति';

  @override
  String get noIndividualsInThisHouse => 'इस घर में कोई व्यक्ति नहीं है';

  @override
  String get registerIndividualPrompt =>
      'पहले इस घर में एक व्यक्ति को पंजीकृत करें';

  @override
  String get age => 'आयु';

  @override
  String get ancFollowUp => 'ANC अनुवर्ती';

  @override
  String get pncFollowUp => 'PNC अनुवर्ती';

  @override
  String get medicineDelivery => 'दवा वितरण';

  @override
  String get healthEducation => 'स्वास्थ्य शिक्षा';

  @override
  String get feverHighTemperature => 'बुखार / उच्च तापमान';

  @override
  String get persistentCough => 'लगातार खांसी';

  @override
  String get breathingDifficulty => 'सांस लेने में कठिनाई';

  @override
  String get diarrheaStomachPain => 'दस्त / पेट दर्द';

  @override
  String get bodyPainWeakness => 'बदन दर्द / कमजोरी';

  @override
  String get skinRashAllergy => 'त्वचा पर दाने / एलर्जी';

  @override
  String get tapAllThatApply => 'जो लागू हो उन पर टैप करें';

  @override
  String get notesObservations => 'नोट्स / अवलोकन';

  @override
  String get anyAdditionalObservations => 'कोई अतिरिक्त अवलोकन...';

  @override
  String get markHouseAsClosed => 'घर को बंद के रूप में चिह्नित करें';

  @override
  String get houseClosedExplanation => 'इससे मैप पर घर ग्रे हो जाएगा';

  @override
  String get submitAndCloseHouse => 'जमा करें और घर बंद करें';

  @override
  String get continueText => 'जारी रखें';

  @override
  String get home => 'मुख्य पृष्ठ';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get calendar => 'कैलेंडर';

  @override
  String get profile => 'प्रोफ़ाइल';
}
