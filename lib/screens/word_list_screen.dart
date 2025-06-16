import 'package:flutter/material.dart';
import 'package:flashcards/helpers/database_helper.dart';
import 'set_detail_screen.dart';
import 'package:flashcards/helpers/l10n.dart';
import 'package:flashcards/helpers/file_helper.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({Key? key}) : super(key: key);

  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Map<String, dynamic>> wordSets = [];
  Map<String, int> wordCounts = {};
  final List<String> flagOptions = ['🇬🇧', '🇹🇷', '🇩🇪', '🇫🇷', '🇪🇸', '❌'];

  bool isEditing = false;
  String selectedSet = "";
  String selectedFlag = "";
  final TextEditingController setController = TextEditingController();

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

  void _deleteSet(String setName) async {
    await DatabaseHelper.instance.deleteSet(setName); // ✅ Veritabanından sil

    setState(() {
      wordSets = List.from(wordSets)..removeWhere((set) => set['name'] == setName); // ✅ Read-only hatasını çözüyor
      wordCounts.remove(setName);
    });

    _loadWordSets(); // ✅ Listeyi tekrar yükle
  }

  void _exportList() async {
  final selectedSet = await _selectList();
  if (selectedSet != null) {
    final words = await DatabaseHelper.instance.readFlashcardsBySet(selectedSet);
    final exportData = {
      "listName": selectedSet,
      "words": words,
    };
    await FileHelper.exportWordList('$selectedSet.json', exportData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.translate('list_exported'))),
    );
  }
}

void _importList() async {
  final importData = await FileHelper.importWordList();
  if (importData != null) {
    final listName = importData['listName'] as String;
    final words = importData['words'] as List<dynamic>;

    final existingSet = await DatabaseHelper.instance.readFlashcardsBySet(listName);
    
    if (existingSet.isNotEmpty) {
      // Kullanıcıya soralım
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(L10n.translate('overwrite_list')),
            content: Text(L10n.translate('overwrite_list_confirmation')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(L10n.translate('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(L10n.translate('overwrite')),
              ),
            ],
          );
        },
      );

      if (shouldReplace == true) {
        await DatabaseHelper.instance.deleteSet(listName);
        await DatabaseHelper.instance.createSet(listName);
      }
    } else {
      await DatabaseHelper.instance.createSet(listName);
    }

    for (var word in words) {
      await DatabaseHelper.instance.createFlashcard({
        "setName": listName,
        "front": word['front'],
        "back": word['back'],
      });
    }

    _loadWordSets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.translate('list_imported'))),
    );
  }
}

Future<String?> _selectList() async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(L10n.translate('select_list')),
        children: wordSets.map((set) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, set['name']);
            },
            child: Text(set['name']),
          );
        }).toList(),
      );
    },
  );
}

  void _editWordSet(String setName) {
    setState(() {
      isEditing = true;
      selectedSet = setName;
      selectedFlag = setName.split(" ").first.contains(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true))
          ? setName.split(" ").first
          : '';
      setController.text = setName.replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true), '');
    });

    _showEditDialog();
  }

  void _updateSet(String oldName, String newName) async {
    if (newName.trim().isNotEmpty) {
      final updatedName = selectedFlag.isNotEmpty ? "$selectedFlag $newName" : newName;

      await DatabaseHelper.instance.updateSet(
          wordSets.firstWhere((set) => set['name'] == oldName)['id'],
          updatedName,
          oldName // Eksik parametre eklendi
      );

      _loadWordSets();
      setState(() {
        isEditing = false;
        selectedSet = "";
        setController.clear();
      });
    }
  }

  void _addSet() async {
    if (setController.text.trim().isNotEmpty) {
      final setName = selectedFlag.isNotEmpty ? "$selectedFlag ${setController.text.trim()}" : setController.text.trim();
      await DatabaseHelper.instance.createSet(setName);
      setController.clear();
      _loadWordSets();
    }
  }

  void _showNewListDialog() {
    setState(() {
      isEditing = false;
      setController.clear();
      selectedFlag = "";
    });

    _showDialog(L10n.translate('add_new_list'), L10n.translate('add_word_list'), _addSet);
  }

  void _showEditDialog() {
    _showDialog(L10n.translate('edit_list'), L10n.translate('save_edit'), () {
      _updateSet(selectedSet, setController.text.trim());
    });
  }

  void _showDialog(String title, String actionText, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Theme(
          data: theme.copyWith(
            dialogBackgroundColor: isDark ? theme.colorScheme.surface : theme.dialogBackgroundColor,
          ),
          child: AlertDialog(
            backgroundColor: isDark ? theme.colorScheme.surface : theme.dialogBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? theme.colorScheme.outline : Colors.transparent,
                width: 1,
              ),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? theme.colorScheme.onSurface : null,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: setController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: L10n.translate('list_name'),
                    labelStyle: MaterialStateTextStyle.resolveWith((states) {
                      if (states.contains(MaterialState.focused)) {
                        return TextStyle(color: theme.colorScheme.primary);
                      }
                      return TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7));
                    }),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setModalState) {
                    return Wrap(
                      spacing: 8.0,
                      children: flagOptions.map((flag) {
                        final isSelected = selectedFlag == flag;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedFlag = flag == '❌' ? '' : flag;
                            });
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? theme.colorScheme.primaryContainer 
                                : isDark ? theme.colorScheme.surfaceVariant : theme.colorScheme.surface,
                              border: Border.all(
                                color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.outline,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              flag,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                  ? theme.colorScheme.onPrimaryContainer 
                                  : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                ),
                child: Text(L10n.translate('cancel')),
              ),
              FilledButton(
                onPressed: () {
                  onConfirm();
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Text(actionText),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Column(
        children: [
          // ✅ BAŞLIK
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
            child: Column(
              children: [
                Text(
                  L10n.translate('word_lists'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // ✅ "Add New List" Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showNewListDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,  
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    L10n.translate('add_new_list'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16), // Butonlar arasında boşluk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _exportList,
                      icon: const Icon(Icons.upload_file),
                      label: Text(L10n.translate('export_list')),
                    ),
                    ElevatedButton.icon(
                      onPressed: _importList,
                      icon: const Icon(Icons.file_download),
                      label: Text(L10n.translate('import_list')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: wordSets.length,
              itemBuilder: (context, index) {
                final setName = wordSets[index]['name'] ?? 'Unknown';
                final wordCount = wordCounts.containsKey(setName) ? wordCounts[setName]! : 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: setName.contains(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true))
                        ? Text(setName.split(" ").first, style: const TextStyle(fontSize: 24))
                        : null,
                    title: Text(setName.replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true), '')),
                    subtitle: Text('$wordCount ${L10n.translate(wordCount == 1 ? "word" : "words")}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            _editWordSet(setName);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                          onPressed: () {
                            _deleteSet(setName);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetDetailScreen(setName: setName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}