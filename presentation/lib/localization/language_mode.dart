import 'package:shared_preferences/shared_preferences.dart';

enum CriterivoxLanguage { english, hindi }

class CriterivoxLanguageMode {
  static const _key = 'criterivox.language_mode';

  static Future<CriterivoxLanguage> load() async {
    final preferences = await SharedPreferences.getInstance();
    return _parse(preferences.getString(_key));
  }

  static Future<void> save(CriterivoxLanguage language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, language.name);
  }

  static CriterivoxLanguage _parse(String? value) {
    return value == CriterivoxLanguage.hindi.name
        ? CriterivoxLanguage.hindi
        : CriterivoxLanguage.english;
  }
}

class CriterivoxStrings {
  final CriterivoxLanguage language;

  const CriterivoxStrings(this.language);

  String get bloom => _text('Bloom', 'ब्लूम');
  String get stewardship => _text('Data Stewardship', 'डेटा प्रबंधन');
  String get context => _text('Context Workspace', 'कॉन्टेक्स्ट वर्कस्पेस');
  String get analysis => _text('Analysis Workspace', 'विश्लेषण वर्कस्पेस');
  String get chat => _text('Character Chat', 'कैरेक्टर चैट');
  String get live => _text('LIVE', 'लाइव');
  String get connecting => _text('CONNECTING', 'कनेक्ट हो रहा है');
  String get language => _text('Language', 'भाषा');
  String get english => _text('English', 'अंग्रेज़ी');
  String get hindi => _text('Hindi', 'हिंदी');
  String get livingSystem => _text('Living system', 'सक्रिय सिस्टम');

  String _text(String englishText, String hindiText) =>
      language == CriterivoxLanguage.hindi ? hindiText : englishText;
}
