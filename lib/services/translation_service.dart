import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SupportedLanguage { english, hindi, tamil }

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Map<String, OnDeviceTranslator> _translators = {};
  SupportedLanguage _currentLanguage = SupportedLanguage.english;

  SupportedLanguage get currentLanguage => _currentLanguage;

  final Map<SupportedLanguage, TranslateLanguage> _languageMap = {
    SupportedLanguage.english: TranslateLanguage.english,
    SupportedLanguage.hindi: TranslateLanguage.hindi,
    SupportedLanguage.tamil: TranslateLanguage.tamil,
  };

  final Map<SupportedLanguage, String> _languageNames = {
    SupportedLanguage.english: 'English',
    SupportedLanguage.hindi: 'हिंदी',
    SupportedLanguage.tamil: 'தமிழ்',
  };

  String getLanguageName(SupportedLanguage language) {
    return _languageNames[language] ?? 'English';
  }

  Future<void> initializeTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selected_language') ?? 'english';
    
    _currentLanguage = SupportedLanguage.values.firstWhere(
      (lang) => lang.toString().split('.').last == languageCode,
      orElse: () => SupportedLanguage.english,
    );

    // Initialize translators for non-English languages
    if (_currentLanguage != SupportedLanguage.english) {
      await _initializeTranslator(_currentLanguage);
    }
  }

  Future<void> _initializeTranslator(SupportedLanguage targetLanguage) async {
    final translatorKey = 'en_to_${targetLanguage.toString().split('.').last}';
    
    if (!_translators.containsKey(translatorKey)) {
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: _languageMap[targetLanguage]!,
      );
      _translators[translatorKey] = translator;
    }
  }

  Future<void> setLanguage(SupportedLanguage language) async {
    _currentLanguage = language;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language.toString().split('.').last);
    
    if (language != SupportedLanguage.english) {
      await _initializeTranslator(language);
    }
  }

  Future<String> translate(String text) async {
    if (_currentLanguage == SupportedLanguage.english || text.isEmpty) {
      return text;
    }

    try {
      final translatorKey = 'en_to_${_currentLanguage.toString().split('.').last}';
      final translator = _translators[translatorKey];
      
      if (translator != null) {
        return await translator.translateText(text);
      }
    } catch (e) {
      print('Translation error: $e');
    }
    
    return text; // Return original text if translation fails
  }

  Future<Map<String, String>> translateMap(Map<String, String> data) async {
    if (_currentLanguage == SupportedLanguage.english) {
      return data;
    }

    final translatedData = <String, String>{};
    
    for (final entry in data.entries) {
      translatedData[entry.key] = await translate(entry.value);
    }
    
    return translatedData;
  }

  void dispose() {
    for (final translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }
}