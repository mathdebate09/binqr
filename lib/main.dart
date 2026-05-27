import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BinQRApp());
}

class BinQRApp extends StatefulWidget {
  const BinQRApp({super.key});

  @override
  State<BinQRApp> createState() => _BinQRAppState();
}

class _BinQRAppState extends State<BinQRApp> {
  final _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'BinQR',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: HomeScreen(themeModeNotifier: _themeModeNotifier),
      ),
    );
  }
}
