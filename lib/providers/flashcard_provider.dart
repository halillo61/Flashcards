import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class FlashcardProvider with ChangeNotifier {
  List<Map<String, String>> _flashcards = [];

  List<Map<String, String>> get flashcards => _flashcards;

  FlashcardProvider();

  Future<void> loadFlashcards(String setName) async {
    final prefs = await SharedPreferences.getInstance();
    final savedWords = prefs.getStringList(setName) ?? [];

    List<Map<String, String>> loadedFlashcards = [];
    for (var word in savedWords) {
      List<String> parts = word.split('|');
      if (parts.length == 2) {
        loadedFlashcards.add({"front": parts[0], "back": parts[1]});
      }
    }

    _flashcards = _shuffleList(loadedFlashcards);
    notifyListeners();
  }

  List<Map<String, String>> _shuffleList(List<Map<String, String>> list) {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    List<Map<String, String>> shuffledList = List.from(list);

    for (int i = shuffledList.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      var temp = shuffledList[i];
      shuffledList[i] = shuffledList[j];
      shuffledList[j] = temp;
    }

    return shuffledList;
  }
}
