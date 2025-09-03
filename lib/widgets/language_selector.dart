import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<SupportedLanguage>(
          icon: const Icon(Icons.language),
          iconColor: Colors.white,
          color: Colors.white,
          onSelected: (language) async {
            await languageProvider.changeLanguage(language);
            
            // Show confirmation
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to ${languageProvider.currentLanguageName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          itemBuilder: (context) {
            return languageProvider.supportedLanguages.map((language) {
              final isSelected = language == languageProvider.currentLanguage;
              final languageName = TranslationService().getLanguageName(language);
              
              return PopupMenuItem<SupportedLanguage>(
                value: language,
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 16,
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      languageName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.green : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}