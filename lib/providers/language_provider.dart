import 'package:flutter/material.dart';
import '_base.dart';
import '../helpers/sp_helper.dart';

class LanguageProvider extends BaseProvider {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguageFromPrefs();
  }

  Future<void> _loadLanguageFromPrefs() async {
    final langCode = await SpHelper.getLanguage();
    if (langCode != null && langCode.isNotEmpty) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await SpHelper.setLanguage(languageCode);
    notifyListeners();
  }
}
