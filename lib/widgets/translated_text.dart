import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _translatedText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
    setState(() {
      _isLoading = true;
    });

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translatedText = await languageProvider.translate(widget.text);
    
    if (mounted) {
      setState(() {
        _translatedText = translatedText;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        // Re-translate when language changes
        if (languageProvider.currentLanguage != SupportedLanguage.english) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _translateText();
          });
        }

        if (_isLoading && languageProvider.currentLanguage != SupportedLanguage.english) {
          return SizedBox(
            height: 16,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        return Text(
          languageProvider.currentLanguage == SupportedLanguage.english 
              ? widget.text 
              : _translatedText.isEmpty 
                  ? widget.text 
                  : _translatedText,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        );
      },
    );
  }
}