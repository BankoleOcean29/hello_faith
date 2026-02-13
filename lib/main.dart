import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:web/web.dart' as web;
import 'dart:convert';
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
        textTheme: GoogleFonts.playfairDisplayTextTheme(
          Theme.of(context).textTheme,
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// SPLASH SCREEN — with Pre-loading logic
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  web.HTMLAudioElement? _audioElement;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    // Pulsing heart animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Prepare audio
    _audioElement = web.HTMLAudioElement()
      ..src = 'assets/assets/secondhand.mp3'
      ..loop = true
      ..volume = 0.5;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the background image before moving to the next page
    precacheImage(const AssetImage('assets/girlfriend_photo.jpg'), context)
        .then((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_isLoaded) return; // Ignore taps if image isn't ready

    _audioElement?.play();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ValentineQuestionPage(audioElement: _audioElement),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pink.shade900,
                Colors.pink.shade600,
                Colors.red.shade400,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing heart
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'Hello Brown Sugar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60),

              // Switch between Loader and Button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isLoaded ? _buildOpenButton() : _buildLoadingState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      key: const ValueKey('loading'),
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'just a second...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenButton() {
    return Container(
      key: const ValueKey('open_button'),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white54, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Tap to open',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUESTION PAGE
// ─────────────────────────────────────────────
class ValentineQuestionPage extends StatefulWidget {
  final web.HTMLAudioElement? audioElement;
  const ValentineQuestionPage({Key? key, this.audioElement}) : super(key: key);

  @override
  State<ValentineQuestionPage> createState() => _ValentineQuestionPageState();
}

class _ValentineQuestionPageState extends State<ValentineQuestionPage> {
  double noButtonTop = 0.65;
  double noButtonLeft = 0.55;
  final Random random = Random();

  void moveNoButton() {
    setState(() {
      noButtonTop = 0.15 + random.nextDouble() * 0.65;
      noButtonLeft = 0.05 + random.nextDouble() * 0.65;
    });
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
      // Fail silently
    }
  }

  void onYesPressed() {
    _sendTelegramNotification();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const YesResponsePage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          final cardMaxWidth = isMobile
              ? constraints.maxWidth * 0.88
              : (isTablet ? 500.0 : 600.0);
          final cardPadding = isMobile ? 20.0 : 40.0;
          final heartSize = isMobile ? 48.0 : 80.0;
          final questionFontSize = isMobile ? 20.0 : 32.0;
          final buttonFontSize = isMobile ? 15.0 : 24.0;
          final yesButtonPaddingH = isMobile ? 28.0 : 60.0;
          final yesButtonPaddingV = isMobile ? 12.0 : 20.0;
          final noButtonPaddingH = isMobile ? 20.0 : 40.0;
          final noButtonPaddingV = isMobile ? 10.0 : 15.0;
          final noButtonFontSize = isMobile ? 13.0 : 20.0;
          final spacing = isMobile ? 20.0 : 50.0;

          return Stack(
            children: [
              // Background image - now cached
              Positioned.fill(
                child: Image.asset(
                  'assets/girlfriend_photo.jpg',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),

              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                ),
              ),

              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: cardMaxWidth),
                  margin: EdgeInsets.all(isMobile ? 16.0 : 20.0),
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
                      Icon(Icons.favorite, color: Colors.pink, size: heartSize),
                      SizedBox(height: isMobile ? 16 : 30),
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

              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                top: constraints.maxHeight * noButtonTop,
                left: constraints.maxWidth * noButtonLeft,
                child: MouseRegion(
                  onEnter: (_) => moveNoButton(),
                  child: ElevatedButton(
                    onPressed: moveNoButton,
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
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YES RESPONSE PAGE
// ─────────────────────────────────────────────
class YesResponsePage extends StatefulWidget {
  const YesResponsePage({Key? key}) : super(key: key);

  @override
  State<YesResponsePage> createState() => _YesResponsePageState();
}

class _YesResponsePageState extends State<YesResponsePage> with TickerProviderStateMixin {
  final Random random = Random();
  final List<EmojiParticle> _particles = [];
  late AnimationController _spawnController;
  final List<String> _emojis = ['❤️', '💕', '💖', '💗', '💓', '💝', '😍', '🥰'];

  @override
  void initState() {
    super.initState();
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
      size: 16 + random.nextDouble() * 24, // Slightly smaller for mobile
      swayAmount: 0.05 + random.nextDouble() * 0.08,
      swayOffset: random.nextDouble() * 2 * pi,
      controller: controller,
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _particles.remove(particle));
        controller.dispose();
      }
    });
    setState(() => _particles.add(particle));
    controller.forward();
  }

  @override
  void dispose() {
    _spawnController.dispose();
    for (final p in _particles) { p.controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffFBF5F3),
                  Color(0xffCE4760),
                  Color(0xffDB5461)
                ],
              ),
            ),
            child: Stack(
              children: [
                // Particle layer
                ..._particles.map((particle) =>
                    _buildParticle(particle, constraints)),

                // Content layer
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '❤️',
                            style: TextStyle(fontSize: isMobile ? 60 : 100),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'If love were noise,\nyou’d be the quiet that makes it music.\n\n'
                                'If time were heavy,\nyou’d be the reason I don’t feel the weight.\n\n'
                                'Of all the lives I could have lived,\nall the rooms I could have walked into,\n\n'
                                'I’m grateful\nthe universe let me walk into you.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts
                                .parisienne( // Using the romantic font we discussed
                              fontSize: isMobile ? 24 : 36,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }}


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