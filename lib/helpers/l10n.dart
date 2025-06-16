import 'dart:convert';
import 'package:flutter/services.dart';

class L10n {
  static Map<String, String> _localizedStrings = {};

  static Future<void> load(String languageCode) async {
    String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
