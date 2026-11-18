import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/smartroute_app.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native splash visible until we explicitly dismiss it.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const SmartRouteApp());
}
