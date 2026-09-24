import 'package:flutter/material.dart';

/// Application-wide language mode. Input language detection remains automatic;
/// this preference controls how the Criterivox interface and generated output
/// are presented to the human.
class CriterivoxLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final String? script;

  const CriterivoxLanguage._(
    this.code,
    this.nativeName,
    this.englishName, {
    this.script,
  });

  static const auto = CriterivoxLanguage._('auto', 'Auto', 'Automatic');
  static const english = CriterivoxLanguage._('en', 'English', 'English');
  static const hindi = CriterivoxLanguage._('hi', 'हिन्दी', 'Hindi', script: 'Devanagari');
  static const marathi = CriterivoxLanguage._('mr', 'मराठी', 'Marathi', script: 'Devanagari');
  static const bengali = CriterivoxLanguage._('bn', 'বাংলা', 'Bengali', script: 'Bengali');
  static const gujarati = CriterivoxLanguage._('gu', 'ગુજરાતી', 'Gujarati', script: 'Gujarati');
  static const tamil = CriterivoxLanguage._('ta', 'தமிழ்', 'Tamil', script: 'Tamil');
  static const telugu = CriterivoxLanguage._('te', 'తెలుగు', 'Telugu', script: 'Telugu');
  static const kannada = CriterivoxLanguage._('kn', 'ಕನ್ನಡ', 'Kannada', script: 'Kannada');
  static const malayalam = CriterivoxLanguage._('ml', 'മലയാളം', 'Malayalam', script: 'Malayalam');
  static const punjabi = CriterivoxLanguage._('pa', 'ਪੰਜਾਬੀ', 'Punjabi', script: 'Gurmukhi');
  static const urdu = CriterivoxLanguage._('ur', 'اردو', 'Urdu', script: 'Arabic');
  static const nepali = CriterivoxLanguage._('ne', 'नेपाली', 'Nepali', script: 'Devanagari');

  static const supported = <CriterivoxLanguage>[auto, english, hindi, marathi];

  bool get isAutomatic => code == 'auto';
  bool get isHindi => code == 'hi';

  static CriterivoxLanguage fromCode(String? value) =>
      supported.firstWhere(
        (item) => item.code == value,
        orElse: () => auto,
      );
}

class CriterivoxLanguageScope extends InheritedWidget {
  final CriterivoxLanguage language;
  final ValueChanged<CriterivoxLanguage> onChanged;

  const CriterivoxLanguageScope({
    super.key,
    required this.language,
    required this.onChanged,
    required super.child,
  });

  static CriterivoxLanguageScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CriterivoxLanguageScope>();

  @override
  bool updateShouldNotify(CriterivoxLanguageScope oldWidget) =>
      language.code != oldWidget.language.code;
}

class CriterivoxLanguageSelector extends StatelessWidget {
  const CriterivoxLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CriterivoxLanguageScope.maybeOf(context);
    final language = scope?.language ?? CriterivoxLanguage.auto;
    return PopupMenuButton<CriterivoxLanguage>(
      tooltip: language.englishName == 'Automatic' ? 'Language / भाषा' : language.nativeName,
      initialValue: language,
      onSelected: scope?.onChanged ?? (_) {},
      itemBuilder: (context) => [
        for (final item in CriterivoxLanguage.supported)
          PopupMenuItem<CriterivoxLanguage>(
            value: item,
            child: Row(
              children: [
                if (item.code == language.code)
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(item.nativeName),
                if (!item.isAutomatic) ...[
                  const SizedBox(width: 8),
                  Text(
                    item.englishName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.language),
      ),
    );
  }
}

class CriterivoxLocalizedText {
  static const technicalTerms = <String>{
    'Criterivox','S5','S6','IDLE','RECEIVE','WORK','COMMUNICATE','HANDOFF',
    'COMPLETE','WARNING','EVIDENCE','DECISION','ASSUMPTION','HYPOTHESIS',
    'IMPLEMENTED','FUTURE','UNKNOWN','HIGH','MEDIUM','LOW','MCP',
  };

  static String preserveTechnical(String value) => value;
}


class CriterivoxStrings {
  final CriterivoxLanguage language;
  const CriterivoxStrings(this.language);

  String _text(String en, Map<String, String> translations) =>
      translations[language.code] ?? en;

  String get startHere => _text('START HERE', {'hi':'यहाँ से शुरू करें','mr':'येथून सुरू करा'});
  String get appIntroduction => _text('App Introduction', {'hi':'ऐप परिचय','mr':'अॅप परिचय'});
  String get humanTerritory => _text('HUMAN TERRITORY', {'hi':'मानव क्षेत्र','mr':'मानवी क्षेत्र'});
  String get loginSignup => _text('LOGIN / SIGN UP', {'hi':'लॉग इन / साइन अप','mr':'लॉग इन / साइन अप'});
  String get humanResidence => _text('Human Residence', {'hi':'मानव निवास','mr':'मानवी निवास'});
  String get signUpLogin => _text('Sign Up / Log In', {'hi':'साइन अप / लॉग इन','mr':'साइन अप / लॉग इन'});
  String get guestPass => _text('Guest Pass', {'hi':'अतिथि पास','mr':'अतिथी पास'});
  String get privateRoom => _text('Private Room', {'hi':'निजी कक्ष','mr':'खाजगी कक्ष'});
  String get collaborationRoom => _text('Collaboration Room', {'hi':'सहयोग कक्ष','mr':'सहकार्य कक्ष'});
  String get decisionDesk => _text('Decision Desk', {'hi':'निर्णय डेस्क','mr':'निर्णय डेस्क'});
  String get previousDecisions => _text('Previous Decisions', {'hi':'पिछले निर्णय','mr':'मागील निर्णय'});
  String get collaborationCommons => _text('COLLABORATION COMMONS', {'hi':'सहयोग साझा क्षेत्र','mr':'सहकार्य सामायिक क्षेत्र'});
  String get meetingHall => _text('Meeting Hall', {'hi':'बैठक कक्ष','mr':'बैठक सभागृह'});
  String get projectRooms => _text('Project Rooms', {'hi':'परियोजना कक्ष','mr':'प्रकल्प कक्ष'});
  String get sharedWorkspaces => _text('Shared Workspaces', {'hi':'साझा कार्यक्षेत्र','mr':'सामायिक कार्यक्षेत्र'});
}
