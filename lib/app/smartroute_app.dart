
import 'package:flutter/material.dart';
import '../features/home/presentation/screens/foundation_screen.dart';

class SmartRouteApp extends StatelessWidget {
  const SmartRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRoute Uganda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B3A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F7),
      ),
      home: const FoundationScreen(),
    );
  }
}

