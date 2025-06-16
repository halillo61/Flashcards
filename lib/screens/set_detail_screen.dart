import 'package:flutter/material.dart';
import '../helpers/l10n.dart';
import '../helpers/database_helper.dart';

class SetDetailScreen extends StatefulWidget {
  final String setName;

  const SetDetailScreen({Key? key, required this.setName}) : super(key: key);

  @override
  _SetDetailScreenState createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> {
  List<Map<String, dynamic>> flashcards = [];
  final TextEditingController frontController = TextEditingController();
  final TextEditingController backController = TextEditingController();
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _loadFlashcards() async {
    final cards = await DatabaseHelper.instance.readFlashcardsBySet(widget.setName);
    setState(() {
      flashcards = cards;
    });
  }

  void _saveFlashcard() async {
    final db = await DatabaseHelper.instance.database;

    final card = {
      'setName': widget.setName,
      'front': frontController.text,
      'back': backController.text,
    };

    if (editingIndex != null) {
      final id = flashcards[editingIndex!]['id'];
      await db.update('flashcards', card, where: 'id = ?', whereArgs: [id]);
      editingIndex = null;
    } else {
      await db.insert('flashcards', card);
    }
    _loadFlashcards();
    frontController.clear();
    backController.clear();
  }

  void _editFlashcard(int index) {
    final card = flashcards[index];
    frontController.text = card['front'];
    backController.text = card['back'];
    setState(() {
      editingIndex = index;
    });
  }

  void _deleteFlashcard(int id) async {
    await DatabaseHelper.instance.deleteFlashcard(id);
    _loadFlashcards();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
        child: Column(
          children: [
            Text(
              widget.setName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: frontController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: L10n.translate('front'),
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: isDark ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: backController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: L10n.translate('back'),
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: isDark ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _saveFlashcard,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                editingIndex == null ? L10n.translate('add_word') : L10n.translate('update_word'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  final card = flashcards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: isDark ? 2 : 1,
                    color: isDark ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? theme.colorScheme.outline : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card['front'],
                                  style: TextStyle(
                                    fontSize: 20, // ✅ Word List Screen ile aynı
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8), // ✅ Daha iyi aralık
                                Text(
                                  card['back'],
                                  style: TextStyle(
                                    fontSize: 20, // ✅ Aynı font boyutu
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, 
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => _editFlashcard(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, 
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _deleteFlashcard(card['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
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
