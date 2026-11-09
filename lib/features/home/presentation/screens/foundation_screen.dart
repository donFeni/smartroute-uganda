
import 'package:flutter/material.dart';

class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.route_rounded,
                  size: 76,
                  color: Color(0xFF176B3A),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SmartRoute Uganda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B29),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Beyond Navigation.\nTowards Smarter Mobility.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.5,
                    color: Color(0xFF52645A),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Project foundation established.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

