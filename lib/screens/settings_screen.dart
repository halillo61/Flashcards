import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../helpers/l10n.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double textSize = 24.0;
  double cardWidth = 200.0;
  double cardHeight = 150.0;
  Color cardColor = Colors.blue[100]!;
  bool showColorOptions = false;
  double animationSpeed = 500.0;
  double previewOpacity = 0.0;
  int animationType = 0; // Seçilen animasyon tipi

  final List<String> animationOptions = [
    'Slide', 'Fade', 'Scale', 'Rotate'
  ]; // Kullanıcıya gösterilecek seçenekler

  final List<Color> cardColors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.red[200]!,
    Colors.yellow[100]!,
    Colors.orange[100]!,
    Colors.purple[300]!,
    Colors.pink[300]!,
    Colors.cyan[100]!,
    Colors.teal[100]!,
    Colors.lime[100]!,
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      textSize = prefs.getDouble('textSize') ?? 24.0;
      cardWidth = prefs.getDouble('cardWidth') ?? 200.0;
      cardHeight = prefs.getDouble('cardHeight') ?? 150.0;
      int colorValue = prefs.getInt('cardColor') ?? Colors.blue[100]!.value;
      cardColor = Color(colorValue);
      animationType = prefs.getInt('animationType') ?? 0;
      animationSpeed = prefs.getDouble('animationSpeed') ?? 500.0; 
    });
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('textSize', textSize);
    prefs.setDouble('cardWidth', cardWidth);
    prefs.setDouble('cardHeight', cardHeight);
    prefs.setInt('cardColor', cardColor.value);
    prefs.setInt('animationType', animationType);
    prefs.setDouble('animationSpeed', animationSpeed);
  }

  void _triggerPreview() {
    setState(() {
      previewOpacity = 1.0;
      animationType = animationType; // ✅ Flutter'a animasyon tipinin değiştiğini bildir
    });

    Future.delayed(Duration(milliseconds: (animationSpeed * 1.5).toInt()), () {
      setState(() {
        previewOpacity = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // **Başlık ve Dark Mode Butonu**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      L10n.translate('settings'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        themeProvider.toggleTheme();
                        _triggerPreview();
                      },
                      child: Text(
                        themeProvider.isDarkMode ? '🌙' : '☀️',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // **Dil Seçimi Butonları**
                Row(
                  children: [
                    Text(
                      L10n.translate('language'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildLanguageButton('🇬🇧', 'en', languageProvider),
                    _buildLanguageButton('🇹🇷', 'tr', languageProvider),
                    _buildLanguageButton('🇩🇪', 'de', languageProvider),
                  ],
                ),
                const SizedBox(height: 20),

                // **Yazı Boyutu Ayarı**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    L10n.translate('text_size'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                Slider(
                  value: textSize,
                  min: 16,
                  max: 40,
                  divisions: 8,
                  label: textSize.toString(),
                  onChanged: (newSize) {
                    setState(() {
                      textSize = newSize;
                    });
                    _savePreferences();
                    _triggerPreview();
                  },
                ),

                // **Kart Boyutu Ayarları (Tamamen Eklendi)**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    L10n.translate('card_size'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                Slider(
                  value: cardWidth,
                  min: 180,
                  max: 330,
                  divisions: 10,
                  label: "Width: ${cardWidth.toStringAsFixed(0)}",
                  onChanged: (newWidth) {
                    setState(() {
                      cardWidth = newWidth;
                    });
                    _savePreferences();
                    _triggerPreview();
                  },
                ),
                Slider(
                  value: cardHeight,
                  min: 100,
                  max: 600,
                  divisions: 10,
                  label: "Height: ${cardHeight.toStringAsFixed(0)}",
                  onChanged: (newHeight) {
                    setState(() {
                      cardHeight = newHeight;
                    });
                    _savePreferences();
                    _triggerPreview();
                  },
                ),

                // **Kart Animasyon Hızı**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    L10n.translate('animation_speed'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                Slider(
                  value: animationSpeed,
                  min: 100,
                  max: 1000,
                  divisions: 9,
                  label: "${animationSpeed.toInt()} ms",
                  onChanged: (newSpeed) {
                    setState(() {
                      animationSpeed = newSpeed;
                    });

                    _savePreferences();
                    _triggerPreview();
                  },
                ),

                // **Kart Animasyon Ayarı**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    L10n.translate('animation_type'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(animationOptions.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            animationType = index;
                          });
                          _savePreferences();
                          _triggerPreview();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: animationType == index ? Colors.blueAccent : Colors.grey[300],
                          foregroundColor: animationType == index ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(animationOptions[index]),
                      ),
                    );
                  }),
                ),
            
                // **Kart Rengi Ayarı**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    L10n.translate('card_color'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showColorOptions = !showColorOptions;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                if (showColorOptions)
                  Wrap(
                    children: cardColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            cardColor = color;
                            showColorOptions = false;
                          });
                          _savePreferences();
                          _triggerPreview();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26, width: 1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),

        // **Her Şeyin Üstünde Görünen Transparan Önizleme**
        IgnorePointer(
          child: Center( // ✅ Ön izleme ekranı ortalandı
            child: AnimatedOpacity(
              opacity: previewOpacity,
              duration: Duration(milliseconds: (animationSpeed * 1.5).toInt()), // ✅ Süreyi dinamik hale getirdik
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: animationSpeed.toInt()), // ✅ Seçilen hız uygulanıyor
                switchInCurve: Curves.easeInOut, // ✅ Daha yumuşak geçiş sağlıyor
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  switch (animationType) {
                    case 1:
                      return FadeTransition(opacity: animation, child: child); // ✅ Fade Animasyonu
                    case 2:
                      return ScaleTransition(scale: animation, child: child); // ✅ Scale Animasyonu
                    case 3:
                      final rotateAnimation = Tween<double>(
                        begin: -0.4,
                        end: 0.0,
                      ).animate(animation);
                      return RotationTransition(turns: rotateAnimation, child: child);
                    default:
                      final offsetAnimation = Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(position: offsetAnimation, child: child);
                  }
                },
                child: Container(
                  key: ValueKey<String>("$animationType-$animationSpeed"),
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    L10n.translate('example_card'),
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // **Eksik Olan Fonksiyon Eklendi!**
  Widget _buildLanguageButton(String flag, String langCode, LanguageProvider languageProvider) {
    return GestureDetector(
      onTap: () {
        languageProvider.changeLanguage(langCode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          flag,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
