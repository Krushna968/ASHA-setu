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
  String get patients => 'मरीज़';

  @override
  String get visits => 'मुलाकातें';

  @override
  String get inventory => 'भंडार';

  @override
  String get tasks => 'कार्य';

  @override
  String get logVisit => 'मुलाकात दर्ज करें';

  @override
  String get addPatient => 'मरीज़ जोड़ें';
}
