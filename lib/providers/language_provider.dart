import 'package:flutter/material.dart';
import '../helpers/l10n.dart';

class LanguageProvider with ChangeNotifier {
  String _languageCode = 'en';

  String get languageCode => _languageCode;

  Future<void> changeLanguage(String newLanguageCode) async {
    _languageCode = newLanguageCode;
    await L10n.load(newLanguageCode);
    notifyListeners();
  }
}