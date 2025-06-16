import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/l10n.dart';
import '../providers/language_provider.dart';
import 'word_list_screen.dart';
import 'flashcard_selection_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Uygulama İkonu
            Image.asset(
              'assets/flash_cards.png',
              height: 80, // Görsel yüksekliği ayarlandı
            ),
            const SizedBox(height: 20),

            // Başlık ve Açıklama
            Text(
              L10n.translate('app_title'),
              style: TextStyle(
                fontSize: 36, // Başlık fontu büyütüldü
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              L10n.translate('app_subtitle'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Butonlar (Daha Büyük Hale Getirildi)
            _buildMenuButton(
              context,
              icon: Icons.school,
              text: L10n.translate('flashcard_study'),
              page: const FlashcardSelectionScreen(),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              icon: Icons.list_alt,
              text: L10n.translate('word_lists'),
              page: const WordListScreen(),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              icon: Icons.settings,
              text: L10n.translate('settings'),
              page: const SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String text, required Widget page}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), // Buton yüksekliği artırıldı
        textStyle: const TextStyle(fontSize: 20), // Yazı boyutu büyütüldü
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Köşeler yuvarlatıldı
      ),
      icon: Icon(icon, size: 28),
      label: Text(text),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
