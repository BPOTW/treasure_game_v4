import 'package:flutter/material.dart';
import 'package:treasure_game_v4/utils/firebase_listner.dart';
import 'package:treasure_game_v4/utils/functions.dart';
import 'models/game_state.dart';
import 'screens/index.dart';
import 'components/index.dart';
import 'utils/vignette_overlay.dart';
import 'utils/map_element_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  FirestoreListener.init();
  checkIfLoggedIn();
  runApp(const TreasureHuntApp());
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
  GameState _currentState = GameState.landing;

  void _navigateTo(GameState state) {
    setState(() {
      _currentState = state;
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
                child: _buildScreen(),
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

  Widget _buildScreen() {
    switch (_currentState) {
      case GameState.landing:
        return LandingScreen(onEnter: () => _navigateTo(GameState.playing));
      case GameState.playing:
        return GameScreen(onWin: () => _navigateTo(GameState.victory));
      case GameState.victory:
        return VictoryScreen(onRestart: () => _navigateTo(GameState.landing));
    }
  }
}