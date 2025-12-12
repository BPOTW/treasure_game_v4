
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_game_v4/screens/loading_screen.dart';
import 'package:treasure_game_v4/utils/functions.dart';
import 'models/game_state.dart';
import 'screens/index.dart';
import 'components/index.dart';
import 'utils/vignette_overlay.dart';
import 'utils/map_element_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  runApp(const TreasureHuntApp());

  await initSoundResources();
}

class TreasureHuntApp extends StatelessWidget {
  const TreasureHuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treasure Hunt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE8DCC5),
        primaryColor: const Color(0xFF3E2723),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetUtils.initialize(context);
    });
    AppState.currentGameState.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFE8DCC5)),
          const Positioned.fill(child: NoiseOverlay()),
          const VignetteOverlay(),
          const MapElementOverlay(),

          SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                child: _buildScreen(AppState.currentGameState.value),
              ),
            ),
          ),

          const Positioned(
            top: 100,
            left: 50,
            child: Particle(color: Colors.amber),
          ),
          const Positioned(
            bottom: 200,
            right: 80,
            child: Particle(color: Colors.yellow),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(GameState state) {
    switch (state) {
      case GameState.loading:
        return const LoadingScreen();

      case GameState.landing:
        return LandingScreen(
          onEnter: () => AppState.currentGameState.value = GameState.playing,
        );

      case GameState.playing:
        return GameScreen(
          onWin: () => AppState.currentGameState.value = GameState.victory,
        );

      case GameState.victory:
        return VictoryScreen(
          onRestart: () => AppState.currentGameState.value = GameState.landing,
        );

      case GameState.ended:
        return GameEndedScreen(
          onContinue: () => AppState.currentGameState.value = GameState.landing,
        );

      case GameState.lost:
        return GameLostScreen(
          onContinue: () => AppState.currentGameState.value = GameState.landing,
        );
    }
  }
}
