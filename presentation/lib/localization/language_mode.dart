import 'package:flutter/material.dart';

/// One application-wide language mode. Human input language is detected
/// independently and can be code-mixed or transliterated.
enum CriterivoxLanguage {
  auto,
  english,
  hindi,
  marathi,
  bengali,
  gujarati,
  tamil,
  telugu,
  kannada,
  malayalam,
  punjabi,
  urdu,
  nepali,
}

extension CriterivoxLanguageX on CriterivoxLanguage {
  String get code => switch (this) {
    CriterivoxLanguage.auto => 'auto',
    CriterivoxLanguage.english => 'en',
    CriterivoxLanguage.hindi => 'hi',
    CriterivoxLanguage.marathi => 'mr',
    CriterivoxLanguage.bengali => 'bn',
    CriterivoxLanguage.gujarati => 'gu',
    CriterivoxLanguage.tamil => 'ta',
    CriterivoxLanguage.telugu => 'te',
    CriterivoxLanguage.kannada => 'kn',
    CriterivoxLanguage.malayalam => 'ml',
    CriterivoxLanguage.punjabi => 'pa',
    CriterivoxLanguage.urdu => 'ur',
    CriterivoxLanguage.nepali => 'ne',
  };

  String get nativeName => switch (this) {
    CriterivoxLanguage.auto => 'Auto',
    CriterivoxLanguage.english => 'English',
    CriterivoxLanguage.hindi => 'हिन्दी',
    CriterivoxLanguage.marathi => 'मराठी',
    CriterivoxLanguage.bengali => 'বাংলা',
    CriterivoxLanguage.gujarati => 'ગુજરાતી',
    CriterivoxLanguage.tamil => 'தமிழ்',
    CriterivoxLanguage.telugu => 'తెలుగు',
    CriterivoxLanguage.kannada => 'ಕನ್ನಡ',
    CriterivoxLanguage.malayalam => 'മലയാളം',
    CriterivoxLanguage.punjabi => 'ਪੰਜਾਬੀ',
    CriterivoxLanguage.urdu => 'اردو',
    CriterivoxLanguage.nepali => 'नेपाली',
  };

  String get englishName => switch (this) {
    CriterivoxLanguage.auto => 'Automatic',
    CriterivoxLanguage.english => 'English',
    CriterivoxLanguage.hindi => 'Hindi',
    CriterivoxLanguage.marathi => 'Marathi',
    CriterivoxLanguage.bengali => 'Bengali',
    CriterivoxLanguage.gujarati => 'Gujarati',
    CriterivoxLanguage.tamil => 'Tamil',
    CriterivoxLanguage.telugu => 'Telugu',
    CriterivoxLanguage.kannada => 'Kannada',
    CriterivoxLanguage.malayalam => 'Malayalam',
    CriterivoxLanguage.punjabi => 'Punjabi',
    CriterivoxLanguage.urdu => 'Urdu',
    CriterivoxLanguage.nepali => 'Nepali',
  };

  bool get automatic => this == CriterivoxLanguage.auto;

  static CriterivoxLanguage fromCode(String? code) =>
      CriterivoxLanguage.values.firstWhere(
        (item) => item.code == code,
        orElse: () => CriterivoxLanguage.auto,
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
      language != oldWidget.language;
}

class CriterivoxLanguageSelector extends StatelessWidget {
  const CriterivoxLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CriterivoxLanguageScope.of(context);
    return PopupMenuButton<CriterivoxLanguage>(
      tooltip: scope.language == CriterivoxLanguage.auto ? 'Language / भाषा' : scope.language.nativeName,
      onSelected: scope.onChanged,
      itemBuilder: (context) => [
        for (final language in CriterivoxLanguage.values)
          PopupMenuItem(
            value: language,
            child: Row(
              children: [
                if (language == scope.language)
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(language.nativeName),
                const SizedBox(width: 8),
                Text(
                  language.englishName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
      child: Chip(
        avatar: const Icon(Icons.language, size: 18),
        label: Text(scope.language.nativeName),
      ),
    );
  }
}

class CriterivoxStrings {
  final CriterivoxLanguage language;
  const CriterivoxStrings(this.language);

  String _text(String english, Map<CriterivoxLanguage, String> values) =>
      values[language] ?? english;

  String get bloom => 'Bloom';
  String get stewardship => _text('Data Stewardship', {
    CriterivoxLanguage.hindi: 'डेटा प्रबंधन',
    CriterivoxLanguage.marathi: 'डेटा व्यवस्थापन',
  });
  String get context => _text('Context Workspace', {
    CriterivoxLanguage.hindi: 'कॉन्टेक्स्ट वर्कस्पेस',
    CriterivoxLanguage.marathi: 'संदर्भ कार्यक्षेत्र',
  });
  String get analysis => _text('Analysis Workspace', {
    CriterivoxLanguage.hindi: 'विश्लेषण कार्यक्षेत्र',
    CriterivoxLanguage.marathi: 'विश्लेषण कार्यक्षेत्र',
  });
  String get chat => _text('Character Chat', {
    CriterivoxLanguage.hindi: 'कैरेक्टर चैट',
    CriterivoxLanguage.marathi: 'कॅरेक्टर चॅट',
  });
  String get live => _text('LIVE', {CriterivoxLanguage.hindi: 'लाइव'});
  String get connecting => _text('CONNECTING', {CriterivoxLanguage.hindi: 'कनेक्ट हो रहा है'});
  String get languageLabel => _text('Language', {CriterivoxLanguage.hindi: 'भाषा'});
  String get livingSystem => _text('Living system', {CriterivoxLanguage.hindi: 'सक्रिय सिस्टम'});
}
