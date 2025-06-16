import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/l10n.dart';
import 'screens/menu_screen.dart';
import 'utils/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/theme_provider.dart';

String languageCode = 'en';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await L10n.load(languageCode);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Koyu mod desteği eklendi
      ],
      child: const FlashcardApp(),
    ),
  );
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/menu',
      routes: {
        '/menu': (context) => const MenuScreen(),
      }
    );
  }
}
