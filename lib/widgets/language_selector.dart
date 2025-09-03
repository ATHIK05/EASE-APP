import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';

class LanguageSelector extends StatelessWidget {
  final Color? iconColor;
  final Color? backgroundColor;

  const LanguageSelector({
    super.key,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<SupportedLanguage>(
          icon: Icon(
            Icons.language,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          color: backgroundColor ?? Theme.of(context).cardColor,
          onSelected: (language) async {
            await languageProvider.changeLanguage(language);
            
            // Show confirmation
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to ${languageProvider.currentLanguageName}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Theme.of(context).primaryColor,
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
                      Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      languageName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
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