import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  final TranslationService _translationService = TranslationService();
  
  SupportedLanguage get currentLanguage => _translationService.currentLanguage;
  
  String get currentLanguageName => _translationService.getLanguageName(currentLanguage);

  LanguageProvider() {
    initializeLanguage();
  }

  Future<void> initializeLanguage() async {
    await _translationService.initializeTranslation();
    notifyListeners();
  }

  Future<void> changeLanguage(SupportedLanguage language) async {
    await _translationService.setLanguage(language);
    notifyListeners();
  }

  String translate(String text) {
    return _translationService.translate(text);
  }

  List<SupportedLanguage> get supportedLanguages => SupportedLanguage.values;
}