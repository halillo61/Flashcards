import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../helpers/l10n.dart';
import '../screens/menu_screen.dart';

class FlashcardScreen extends StatefulWidget {
  final String setName;
  final List<Map<String, String>> flashcards;

  const FlashcardScreen({Key? key, required this.setName, required this.flashcards}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentIndex = 0;
  bool showBack = false;
  bool isAnimating = false;
  bool canSwipe = true;
  bool isDraggingForward = true; // Kullanıcının kaydırma yönünü belirlemek için
  double textSize = 24.0;
  double cardWidth = 240.0;
  double cardHeight = 180.0;
  Color cardColor = Colors.blue[100]!;
  int animationType = 0;
  double animationSpeed = 500.0;

  // Kaydırma kontrolü için değişkenler
  double dragStartX = 0.0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          isAnimating = false;
        }
      });

    _loadPreferences();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        textSize = prefs.getDouble('textSize') ?? 24.0;
        cardWidth = prefs.getDouble('cardWidth') ?? 240.0;
        cardHeight = prefs.getDouble('cardHeight') ?? 180.0;
        int colorValue = prefs.getInt('cardColor') ?? Colors.blue[100]!.value;
        cardColor = Color(colorValue);
        animationType = prefs.getInt('animationType') ?? 0;
        animationSpeed = prefs.getDouble('animationSpeed') ?? 500.0; // ✅ Yeni hız alınıyor
                
      });

      _controller.duration = Duration(milliseconds: animationSpeed.toInt()); // ✅ Animasyon süresi güncelleniyor
    }
  }

  void flipCard() {
    if (isAnimating) return;
    
    isAnimating = true;
    setState(() {
      if (showBack) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      showBack = !showBack;
    });
  }

  void _nextCard(bool isNext) {
    if (!mounted || isAnimating || !canSwipe) return;

    isAnimating = true;
    canSwipe = false;

    setState(() {
      if (isNext) {
        currentIndex = (currentIndex + 1) % widget.flashcards.length;
      } else {
        currentIndex = (currentIndex - 1 + widget.flashcards.length) % widget.flashcards.length;
      }
      showBack = false;
    });

    _controller.reset();
    
    Future.delayed(const Duration(milliseconds: 30), () {
      if (mounted) {
        isAnimating = false;
        canSwipe = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MenuScreen()),
            (Route<dynamic> route) => false,
          );
          return false;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: flipCard,
          onHorizontalDragStart: (details) {
            if (!isDragging && canSwipe) {
              isDragging = true;
              dragStartX = details.globalPosition.dx;
            }
          },
          onHorizontalDragUpdate: (details) {
            if (!isDragging || !canSwipe) return;

            setState(() {
              isDraggingForward = details.delta.dx < 0; // ✅ Eğer x değeri azalıyor (kaydırma sola) ise ileri gidiyor
            });
          },
          onHorizontalDragEnd: (details) {
            if (!isDragging || !canSwipe) return;

            final dragEndX = details.primaryVelocity ?? 0;
            final dragDistance = dragEndX.abs();
            
            if (dragDistance > 50) { // Minimum kaydırma hızı
              if (dragEndX < 0) {
                _nextCard(true);
              } else {
                _nextCard(false);
              }
            }

            isDragging = false;
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
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
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: animationSpeed.toInt()),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      int listLength = widget.flashcards.length;

                      final offsetAnimation = Tween<Offset>(
                        begin: isDraggingForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0), // Kullanıcının yönüne göre belirleme
                        end: Offset.zero,
                      ).animate(animation);

                      switch (animationType) {
                        case 1:
                          return FadeTransition(opacity: animation, child: child);
                        case 2:
                          return ScaleTransition(scale: animation, child: child);
                        case 3:
                          final rotateAnimation = Tween<double>(
                            begin: isDraggingForward ? -0.4 : 0.4, // ✅ Kullanıcının yönüne göre belirleme
                            end: 0.0,
                          ).animate(animation);
                          return RotationTransition(turns: rotateAnimation, child: child);
                        default:
                          return SlideTransition(position: offsetAnimation, child: child);
                      }
                    },
                    child: AnimatedBuilder(
                      key: ValueKey<int>(currentIndex),
                      animation: _animation,
                      builder: (context, child) {
                        final isFront = _animation.value < 0.5;
                        final rotation = _animation.value * 3.14159;

                        return Center(
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(rotation),
                            alignment: Alignment.center,
                            child: isFront
                                ? _buildCard(widget.flashcards[currentIndex]['front']!)
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(3.14159),
                                    child: _buildCard(widget.flashcards[currentIndex]['back']!),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.flashcards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "${currentIndex + 1} / ${widget.flashcards.length}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}