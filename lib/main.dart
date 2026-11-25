import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'utils/notification_service.dart'; // Add this import

// Stage 5 Track C: initialize notifications before the app starts.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async setup
  await NotificationService.instance.init();
  runApp(const MemoryCardsApp());
}

class MemoryCardsApp extends StatelessWidget {
  const MemoryCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // soft purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
