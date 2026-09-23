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

  static const supported = <CriterivoxLanguage>[
    auto, english, hindi, marathi, bengali, gujarati, tamil, telugu,
    kannada, malayalam, punjabi, urdu, nepali,
  ];

  bool get isAutomatic => code == 'auto';
  bool get isHindi => code == 'hi';

  String text(String englishText, {String? hindiText}) {
    if (isHindi) return hindiText ?? englishText;
    return englishText;
  }

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

  static CriterivoxLanguageScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CriterivoxLanguageScope>()!;

  @override
  bool updateShouldNotify(CriterivoxLanguageScope oldWidget) =>
      language.code != oldWidget.language.code;
}

class CriterivoxLanguageSelector extends StatelessWidget {
  const CriterivoxLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CriterivoxLanguageScope.of(context);
    return PopupMenuButton<CriterivoxLanguage>(
      tooltip: 'Language',
      initialValue: scope.language,
      onSelected: scope.onChanged,
      itemBuilder: (context) => [
        for (final language in CriterivoxLanguage.supported)
          PopupMenuItem<CriterivoxLanguage>(
            value: language,
            child: Row(
              children: [
                if (language.code == scope.language.code)
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(language.nativeName),
                if (!language.isAutomatic) ...[
                  const SizedBox(width: 8),
                  Text(
                    language.englishName,
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
