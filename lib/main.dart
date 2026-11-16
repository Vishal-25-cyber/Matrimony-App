import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 150 << 20; // 150 MB
  // Support both portrait and landscape across tablets and foldable devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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
      home: const SplashScreen(),
    );
  }
}
