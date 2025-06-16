import 'package:flutter/material.dart';
import '../helpers/l10n.dart';
import '../helpers/database_helper.dart';
import 'flashcard_screen.dart';

class FlashcardSelectionScreen extends StatefulWidget {
  const FlashcardSelectionScreen({Key? key}) : super(key: key);

  @override
  _FlashcardSelectionScreenState createState() =>
      _FlashcardSelectionScreenState();
}

class _FlashcardSelectionScreenState extends State<FlashcardSelectionScreen> {
  List<Map<String, dynamic>> wordSets = [];
  Map<String, int> wordCounts = {};

  @override
  void initState() {
    super.initState();
    _loadWordSets();
  }

  void _loadWordSets() async {
    final sets = await DatabaseHelper.instance.readSets();
    final counts = <String, int>{};

    for (var set in sets) {
      final count = await DatabaseHelper.instance.countWordsInSet(set['name']);
      counts[set['name']] = count;
    }

    setState(() {
      wordSets = sets;
      wordCounts = counts;
    });
  }

  void _openFlashcardScreen(String setName) async {
    final flashcards = await DatabaseHelper.instance.readFlashcardsBySet(setName);
    final convertedFlashcards = flashcards.map((card) {
      return {
        "front": card["front"].toString(),
        "back": card["back"].toString(),
      };
    }).toList();

    if (convertedFlashcards.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FlashcardScreen(setName: setName, flashcards: convertedFlashcards),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.translate('no_flashcards'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
        child: Column(
          children: [
            Text(
              L10n.translate('select_list'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: wordSets.isEmpty
                  ? Center(child: Text(L10n.translate('no_word_lists')))
                  : ListView.builder(
                      itemCount: wordSets.length,
                      itemBuilder: (context, index) {
                        final setName = wordSets[index]['name'];
                        final wordCount = wordCounts[setName] ?? 0;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(setName),
                            subtitle: Text(
                              '$wordCount ${L10n.translate(wordCount == 1 ? "word" : "words")}',
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () => _openFlashcardScreen(setName),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
