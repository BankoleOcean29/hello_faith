import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:http/http.dart' as http;

void main() {
  runApp(const ValentineApp());
}

class ValentineApp extends StatelessWidget {
  const ValentineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be My Valentine',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'serif',
      ),
      debugShowCheckedModeBanner: false,
      home: const ValentineQuestionPage(),
    );
  }
}

class ValentineQuestionPage extends StatefulWidget {
  const ValentineQuestionPage({Key? key}) : super(key: key);

  @override
  State<ValentineQuestionPage> createState() => _ValentineQuestionPageState();
}

class _ValentineQuestionPageState extends State<ValentineQuestionPage> {
  double noButtonTop = 0.6;
  double noButtonLeft = 0.6;
  final Random random = Random();
  html.AudioElement? _audioElement;
  bool _musicStarted = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  @override
  void dispose() {
    _audioElement?.pause();
    _audioElement = null;
    super.dispose();
  }

  void _initAudio() {
    _audioElement = html.AudioElement()
      ..src = 'assets/assets/secondhand.mp3' // Flutter web serves assets at this path
      ..loop = true
      ..volume = 0.5;

    // Try autoplay first
    _audioElement!.play().then((_) {
      setState(() => _musicStarted = true);
    }).catchError((_) {
      // Autoplay was blocked by browser — will start on first user tap
      setState(() => _musicStarted = false);
    });
  }

  void _startMusicOnGesture() {
    if (!_musicStarted) {
      _audioElement?.play().then((_) {
        setState(() => _musicStarted = true);
      });
    }
  }

  void moveNoButton() {
    _startMusicOnGesture();
    setState(() {
      noButtonTop = 0.2 + random.nextDouble() * 0.6;
      noButtonLeft = 0.1 + random.nextDouble() * 0.7;
    });
  }

  void onYesPressed() {
    _startMusicOnGesture();
    _sendTelegramNotification();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const YesResponsePage(),
      ),
    );
  }

  Future<void> _sendTelegramNotification() async {
    const String workerUrl = 'https://hellofaith.bankolescripted.workers.dev';

    try {
      await http.post(
        Uri.parse(workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notify': true}),
      );
    } catch (e) {
      // Fail silently — don't interrupt her experience
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on mobile or web
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          // Responsive sizing
          final cardMaxWidth = isMobile ? constraints.maxWidth * 0.9 : (isTablet ? 500.0 : 600.0);
          final cardPadding = isMobile ? 24.0 : 40.0;
          final cardMargin = isMobile ? 16.0 : 20.0;
          final heartSize = isMobile ? 60.0 : 80.0;
          final questionFontSize = isMobile ? 24.0 : 32.0;
          final buttonFontSize = isMobile ? 20.0 : 24.0;
          final yesButtonPaddingH = isMobile ? 40.0 : 60.0;
          final yesButtonPaddingV = isMobile ? 16.0 : 20.0;
          final noButtonPaddingH = isMobile ? 30.0 : 40.0;
          final noButtonPaddingV = isMobile ? 12.0 : 15.0;
          final noButtonFontSize = isMobile ? 18.0 : 20.0;
          final spacing = isMobile ? 30.0 : 50.0;

          return Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/girlfriend_photo.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Dark overlay for better text visibility
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),

              // Main content
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: cardMaxWidth),
                  margin: EdgeInsets.all(cardMargin),
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: heartSize,
                      ),
                      SizedBox(height: isMobile ? 20 : 30),
                      Text(
                        'Will you please be my valentine?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: questionFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: spacing),
                      ElevatedButton(
                        onPressed: onYesPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: yesButtonPaddingH,
                            vertical: yesButtonPaddingV,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Yes! 💕',
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // No button (moves around)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: MediaQuery.of(context).size.height * noButtonTop,
                left: MediaQuery.of(context).size.width * noButtonLeft,
                child: MouseRegion(
                  onEnter: (_) => moveNoButton(),
                  child: GestureDetector(
                    onTap: moveNoButton,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black54,
                        padding: EdgeInsets.symmetric(
                          horizontal: noButtonPaddingH,
                          vertical: noButtonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontSize: noButtonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle music hint if autoplay was blocked
              if (!_musicStarted)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_note, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Tap anywhere to play music 🎵',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Placeholder for the Yes response page
class YesResponsePage extends StatefulWidget {
  const YesResponsePage({Key? key}) : super(key: key);

  @override
  State<YesResponsePage> createState() => _YesResponsePageState();
}

class _YesResponsePageState extends State<YesResponsePage>
    with TickerProviderStateMixin {
  final Random random = Random();
  final List<EmojiParticle> _particles = [];
  late AnimationController _spawnController;

  final List<String> _emojis = ['❤️', '💕', '💖', '💗', '💓', '💝', '😍', '🥰'];

  @override
  void initState() {
    super.initState();

    // Spawn a new emoji every 300ms
    _spawnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spawnParticle();
        _spawnController.reset();
        _spawnController.forward();
      }
    });

    _spawnController.forward();
  }

  void _spawnParticle() {
    if (!mounted) return;
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500 + random.nextInt(2000)),
    );

    final particle = EmojiParticle(
      emoji: _emojis[random.nextInt(_emojis.length)],
      startX: random.nextDouble(),
      size: 24 + random.nextDouble() * 32,
      swayAmount: 0.05 + random.nextDouble() * 0.08,
      swayOffset: random.nextDouble() * 2 * pi,
      controller: controller,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _particles.remove(particle));
        }
        controller.dispose();
      }
    });

    setState(() => _particles.add(particle));
    controller.forward();
  }

  @override
  void dispose() {
    _spawnController.dispose();
    for (final p in _particles) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink.shade200,
                  Colors.red.shade300,
                  Colors.pink.shade400,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating emoji particles
                ..._particles.map((particle) {
                  return AnimatedBuilder(
                    animation: particle.controller,
                    builder: (context, child) {
                      final progress = particle.controller.value;
                      // Sway left and right as it rises
                      final sway = sin(progress * 4 * pi + particle.swayOffset) *
                          particle.swayAmount;
                      final x = (particle.startX + sway)
                          .clamp(0.0, 1.0) *
                          constraints.maxWidth;
                      // Start from bottom, float to top
                      final y = constraints.maxHeight * (1.0 - progress) -
                          particle.size;
                      // Fade out near the top
                      final opacity = progress < 0.8
                          ? 1.0
                          : 1.0 - ((progress - 0.8) / 0.2);

                      return Positioned(
                        left: x,
                        top: y,
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Text(
                            particle.emoji,
                            style: TextStyle(fontSize: particle.size),
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🥰',
                        style: TextStyle(
                          fontSize: isMobile ? 80 : 100,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Yayyyyyyyyy!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 30 : 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.pink.shade900.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'I understand why God created the concept \n'
                            'of a treasure because you exist 💕',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 24,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EmojiParticle {
  final String emoji;
  final double startX;
  final double size;
  final double swayAmount;
  final double swayOffset;
  final AnimationController controller;

  EmojiParticle({
    required this.emoji,
    required this.startX,
    required this.size,
    required this.swayAmount,
    required this.swayOffset,
    required this.controller,
  });
}
