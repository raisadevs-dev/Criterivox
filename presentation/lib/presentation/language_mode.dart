import 'package:flutter/material.dart';

class CriterivoxLanguage {
  final String code;

  const CriterivoxLanguage._(this.code);

  static const english = CriterivoxLanguage._('en');
  static const hindi = CriterivoxLanguage._('hi');

  bool get isHindi => code == 'hi';

  String text(String englishText, {String? hindiText}) {
    if (!isHindi) return englishText;
    return hindiText ?? englishText;
  }

  static CriterivoxLanguage fromCode(String? value) => value == 'hi' ? hindi : english;
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

class CriterivoxLocalizedText {
  static const technicalTerms = <String>{
    'Criterivox', 'S5', 'S6', 'IDLE', 'RECEIVE', 'WORK', 'COMMUNICATE',
    'HANDOFF', 'COMPLETE', 'WARNING', 'EVIDENCE', 'DECISION', 'ASSUMPTION',
    'HYPOTHESIS', 'IMPLEMENTED', 'FUTURE', 'UNKNOWN', 'HIGH', 'MEDIUM', 'LOW', 'MCP',
  };

  static String preserveTechnical(String value) => value;
}
