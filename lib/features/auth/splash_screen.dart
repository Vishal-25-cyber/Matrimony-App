import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isWelcomeMode;

  const SplashScreen({
    super.key,
    this.isWelcomeMode = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Fast, crisp 1.9-second duration for an instant "WOW" experience
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward().then((_) {
      if (mounted && !widget.isWelcomeMode && !_navigated) {
        _goToLogin();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (_navigated) return;
    _navigated = true;

    if (widget.isWelcomeMode) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F4),
      body: SafeArea(
        child: GestureDetector(
          onTap: _goToLogin,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Subtle ambient radial glow behind hero
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFD4AF37).withValues(alpha: 0.12),
                          const Color(0xFF7A132B).withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Centered clean, non-messy content (fits on any screen without scroll)
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Founder Owner Photo (Little Big - Royal Gold Medallion)
                            Container(
                              width: 144,
                              height: 144,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFDF7A),
                                    Color(0xFFD4AF37),
                                    Color(0xFF9E6D18),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7A132B).withValues(alpha: 0.22),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.30),
                                    blurRadius: 14,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(2.5),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/founder_arumugam.jpg',
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -0.2),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 2. Owner Name in Tamil (Bold Size)
                            const Text(
                              AppConstants.founderName, // சென்னிமலை ஆறுமுகம்
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7A132B),
                                letterSpacing: 0.8,
                                height: 1.25,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 3. Pandarathar Mana Maalai under Owner Name
                            const Text(
                              AppConstants.appNameTamil, // பண்டாரத்தார் மண மாலை
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A132B),
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // 4. Pandarathar Mana Maalai English
                            const Text(
                              AppConstants.appNameEnglish, // PANDARATHAR MANA MAALAI
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.8,
                                color: Color(0xFFB8860B),
                              ),
                            ),

                            const SizedBox(height: 36),

                            // 5. Sleek Golden Line Loader
                            Container(
                              width: 140,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEADBCE),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, _) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: _controller.value.clamp(0.05, 1.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF7A132B),
                                              Color(0xFFD4AF37),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Back button if in welcome preview mode
              if (widget.isWelcomeMode)
                Positioned(
                  top: 10,
                  left: 12,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF7A132B)),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
