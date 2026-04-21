import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'game/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  unawaited(MobileAds.instance.initialize());
  runApp(const TapBirdApp());
}

class TapBirdApp extends StatelessWidget {
  const TapBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Bird to Fly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
