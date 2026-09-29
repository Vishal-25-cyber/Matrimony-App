import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MatrimonyApp());
}

class MatrimonyApp extends StatelessWidget {
  const MatrimonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'பண்டாரத்தார் மண மாலை - Pandarathar Mana Maalai',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // When viewed on desktop, web browser or wide monitor, wrap inside a smartphone frame
            if (constraints.maxWidth > 500) {
              final frameHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight.clamp(680.0, 932.0)
                  : 844.0;
              return Scaffold(
                backgroundColor: const Color(0xFF1E0E14),
                body: Center(
                  child: Container(
                    width: 420,
                    height: frameHeight,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x8C000000),
                          blurRadius: 36,
                          spreadRadius: 8,
                          offset: Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF3B1822),
                        width: 8,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(420, frameHeight),
                      ),
                      child: child ?? const SplashScreen(),
                    ),
                  ),
                ),
              );
            }
            // On mobile devices (width <= 500), fill native viewport
            return child ?? const SplashScreen();
          },
        );
      },
      home: const SplashScreen(),
    );
  }
}
