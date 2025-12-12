import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treasure_game_v4/components/qr_scanner.dart';
import 'package:treasure_game_v4/components/loading_box.dart';
import 'package:treasure_game_v4/utils/firebase_listner.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> initAppResources() async {
  FirestoreListener.init();
  await InternetUtils.startListening();
  FirestoreListener.listenToRiddles();
  await GeoServices().start();
  checkIfLoggedIn();
  await Future.delayed(Duration(seconds: 3));

  AppState.isGamePassEnable.value && AppState.isGameStarted.value
      ? AppState.currentGameState.value = GameState.playing
      : AppState.currentGameState.value = GameState.landing;
}

Future<void> initSoundResources() async {
  await AudioService().initialize();
  AudioService().setMusicVolume(0.07);
  AudioService().setSfxVolume(0.8);
  AudioService().playBackgroundMusic('sfx/background.ogg');
}

Future<void> enterGame(VoidCallback onEnter, BuildContext context) async {
  showLoader(context);
  await InternetUtils.isInternetAvailable(context);
  if (AppState.isConnectedToInternet.value) {
    bool res = await checkID(AppState.storedGamePass.value);
    if (!res) {
      hideLoader(context);
      if (AppState.isGamePassEnable.value) {
        onEnter();
      } else {
        String message = "There is a problem with GamePass";
        if (!AppState.isGameEnded.value && AppState.isGameLost.value) {
          message = "You've Lost this game. Can't play again.";
        } else if (!AppState.isPaymentVerified.value) {
          message = AppState.paymentStatus.value;
        } else if (AppState.isGameEnded.value) {
          message = "The game has already ended.";
        } else if (!AppState.isGameStarted.value) {
          message = "The game has not started yet.";
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF3E2723),
              content: Text(
                message,
                style: GoogleFonts.cinzelDecorative(
                  color: const Color(0xFFE8DCC5),
                ),
              ),
            ),
          );
        }
      }
    } else {
      String message = 'GamePass Not Found. Check spellinngs and try again.';
      hideLoader(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF3E2723),
          content: Text(
            message,
            style: GoogleFonts.cinzelDecorative(color: const Color(0xFFE8DCC5)),
          ),
        ),
      );
    }
  }
}

Future<String> generateGamePass() async {
  String gamePass = generateUniqueId();
  bool isGamePassAvailable = await checkID(gamePass);
  do {
    gamePass = generateUniqueId();
    isGamePassAvailable = await checkID(gamePass);
  } while (!isGamePassAvailable);
  return gamePass;
}

String generateUniqueId() {
  const String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String numbers = '0123456789';
  Random random = Random();

  String randomLetters = List.generate(
    3,
    (index) => letters[random.nextInt(letters.length)],
  ).join();
  String randomNumbers = List.generate(
    3,
    (index) => numbers[random.nextInt(numbers.length)],
  ).join();
  String id = randomLetters + randomNumbers;

  return id;
}

Future<bool> checkID(String gamePass) async {
  bool value = false;
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where("gamePass", isEqualTo: gamePass)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    value = false;
    var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
    AppState.name.value = data['name'] ?? '';
    AppState.phoneNo.value = data['phoneNo'] ?? '';
    AppState.email.value = data['email'] ?? '';
    AppState.isPaymentVerified.value = data['isPaymentVerified'] ?? false;
    AppState.paymentStatus.value = data['paymentStatus'] ?? 'Not Verified';
    AppState.isGamePassEnable.value = data['isGamePassEnable'] ?? false;
    AppState.completedRiddles.value = data['completedRiddles'] ?? 0;
    AppState.currentRiddleIndex.value = data['currentRiddleIndex'] ?? 1;
    AppState.hasWon.value = data['hasWon'] ?? false;
    AppState.triesLeft.value = data['triesLeft'] ?? 0;
    AppState.isGameLost.value = data['isLost'] ?? false;
    AppState.userId.value = querySnapshot.docs.first.id;
    FirestoreListener.listenToUser(AppState.userId.value);
    if (!AppState.isGameLost.value) {
      saveGamePassInStorage();
    }
  } else {
    value = true;
  }
  return value;
}

bool checkGamePass(String gamePass) {
  if (gamePass == AppState.storedGamePass.value) {
    return true;
  } else {
    return false;
  }
}

void saveGamePassInStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final String gamePass = AppState.storedGamePass.value;
  prefs.setString('gamePass', gamePass);
  prefs.setBool('isLoggedIn', true);
  prefs.setString('userId', AppState.userId.value);
  AppState.isLoggedIn.value = true;
}

void checkIfLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String userId = prefs.getString('userId') ?? "";
  AppState.isLoggedIn.value = isLoggedIn;
  if (isLoggedIn) {
    AppState.userId.value = userId;
    FirestoreListener.listenToUser(AppState.userId.value);
    String gamePass = prefs.getString('gamePass') ?? '';
    AppState.storedGamePass.value = gamePass;
  }
}

class DynamicTimer {
  static Timer? _timer;
  static Duration remainingTime = Duration();

  static void startTimer({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    stop();

    remainingTime = endTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateRemainingTime(endTime);
      if (remainingTime.isNegative || remainingTime.inSeconds == 0) {
        stop();
      }
    });
  }

  static void updateRemainingTime(DateTime endTime) {
    remainingTime = endTime.difference(DateTime.now());
    if (remainingTime.inSeconds > 0) {
      AppState.remainingTime.value = formatDuration(remainingTime);
    }
  }

  static String formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);

    return "${twoDigits(days)}:${twoDigits(hours)}:${twoDigits(minutes)}";
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> addUser() async {
    try {
      Map<String, dynamic> userData = {
        'name': AppState.name.value,
        'phoneNo': AppState.phoneNo.value,
        'email': AppState.email.value,
        'gamePass': AppState.storedGamePass.value,
        'isPaymentVerified': false,
        'paymentStatus': "Payment Verification in Progress",
        'transactionId': AppState.paymentId.value,
        'isGamePassEnable': false,
        'totalRiddles': 9,
        'completedRiddles': 0,
        'currentRiddleIndex': 1,
        'hasWon': false,
        'isLost': false,
        'triesLeft': 4,
      };
      final docref = _db.collection('users').doc();
      await docref.set(userData);
      AppState.userId.value = docref.id;
      print("data updated");
      return true;
    } catch (e) {
      print("Error updating Firestore: $e");
      return false;
    }
  }

  static Future<bool> updateUser() async {
    try {
      Map<String, dynamic> userData = {
        'name': AppState.name.value,
        'phoneNo': AppState.phoneNo.value,
        'email': AppState.email.value,
        'gamePass': AppState.storedGamePass.value,
        'isPaymentVerified': AppState.isPaymentVerified.value,
        'paymentStatus': AppState.paymentStatus.value,
        'transactionId': AppState.paymentId.value,
        'isGamePassEnable': AppState.isGamePassEnable.value,
        'totalRiddles': AppState.totalRiddles.value,
        'completedRiddles': AppState.completedRiddles.value,
        'currentRiddleIndex': AppState.currentRiddleIndex.value,
        'hasWon': AppState.hasWon.value,
        'isLost': AppState.isGameLost.value,
        'triesLeft': AppState.triesLeft.value,
      };
      final docref = _db.collection('users').doc(AppState.userId.value);
      await docref.update(userData);
      print("data updated");
      return true;
    } catch (e) {
      print("Error updating Firestore: $e");
      return false;
    }
  }

  static Future<bool> updateGameState() async {
    try {
      Map<String, dynamic> gameData = {
        'isBuyingEnable': AppState.isBuyingEnable.value,
        'isGameEnded': AppState.isGameEnded.value,
        'winnerName': AppState.winnerName.value,
        'winnerPhone': AppState.phoneNo.value,
        'winnerGamePass': AppState.storedGamePass.value,
        'winnerId': AppState.userId.value,
      };
      final docref = _db.collection('gameData').doc('gameStates');
      await docref.update(gameData);
      print("data updated");
      return true;
    } catch (e) {
      print("Error updating Firestore: $e");
      return false;
    }
  }

  static Future<bool> updateUserAndGameState() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // User update
      final userRef = _db.collection('users').doc(AppState.userId.value);
      batch.update(userRef, {
        'isPaymentVerified': AppState.isPaymentVerified.value,
        'isGamePassEnable': AppState.isGamePassEnable.value,
        'totalRiddles': AppState.totalRiddles.value,
        'currentRiddleIndex': AppState.currentRiddleIndex.value,
        'hasWon': AppState.hasWon.value,
        'isLost': AppState.isGameLost.value,
        'paymentStatus': AppState.paymentStatus.value,
      });

      // Game state update
      final gameRef = _db.collection('gameData').doc('gameStates');
      batch.update(gameRef, {
        'isBuyingEnable': AppState.isBuyingEnable.value,
        'isGameEnded': AppState.isGameEnded.value,
        'isGameStarted': AppState.isGameStarted.value,
        'winnerName': AppState.winnerName.value,
        'winnerPhone': AppState.phoneNo.value,
        'winnerGamePass': AppState.storedGamePass.value,
        'winnerId': AppState.userId.value,
      });

      // Commit the batch
      await batch.commit();
      print("Batch update successful");
      return true;
    } catch (e) {
      print("Error updating Firestore batch: $e");
      return false;
    }
  }

  static Future<bool> addRiddle() async {
    try {
      Map<String, dynamic> riddleData = {
        AppState.temp.value.toString(): {
          'riddle': '1nd riddle',
          'ans': '',
          'isQrEnable': true,
          'isQuestion': false,
          'question': {
            'question': '1nd question',
            'answer': '1nd question ans',
          },
        },
      };
      final docref = _db.collection('gameData').doc('riddleData');
      await docref.update(riddleData);
      print("data updated");
      AppState.temp.value++;
      return true;
    } catch (e) {
      print("Error updating Firestore: $e");
      return false;
    }
  }

  static Future<void> getFirestoreData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('gameData')
          .doc('gameStates')
          .get();

      if (doc.exists) {
        print(doc.data());
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Error getting document: $e");
    }
  }
}

void loadRiddle(BuildContext context) async {
  await InternetUtils.isInternetAvailable(context);
  if (AppState.isConnectedToInternet.value) {
    String riddleIndex = AppState.currentRiddleIndex.value.toString();
    Map riddleData = AppState.riddlesData.value[riddleIndex];
    AppState.currentRiddle.value = riddleData['riddle'];
    AppState.riddleAnswer.value = riddleData['ans'];
    AppState.isQrEnabled.value = riddleData['isQrEnable'];
    AppState.isQuestion.value = riddleData['isQuestion'];
    AppState.questionOptions.value = {
      'option1': riddleData['question']['option1'],
      'option2': riddleData['question']['option2'],
    };
    AppState.questionAnswer.value = riddleData['question']['answer'];
  }
  // saveRiddleData();
}

void nextRiddle(VoidCallback onWin, BuildContext context) {
  // Increment both counters
  if (AppState.completedRiddles.value < AppState.totalIndex.value) {
    AppState.completedRiddles.value++;

    // Ensure currentRiddleIndex starts at 1
    if (AppState.currentRiddleIndex.value < AppState.totalIndex.value) {
      AppState.currentRiddleIndex.value++;
      loadRiddle(context);
    }

    // Save progress
    FirestoreService.updateUser();

    if (AppState.completedRiddles.value == AppState.totalRiddles.value) {
      AudioService().playSoundEffect('sfx/winning-sound.ogg');
      updateWinner(onWin, context);
    }
  }
}

void continueNext(VoidCallback onWin, BuildContext context) async {
  AudioService().playSoundEffect('sfx/button-tap.ogg');
  showLoader(context);
  await InternetUtils.isInternetAvailable(context);
  if (context.mounted) {
    hideLoader(context);
  }
  if (AppState.isConnectedToInternet.value) {
    if (AppState.currentRiddleIndex.value < AppState.totalIndex.value) {
      AppState.currentRiddleIndex.value++;
      loadRiddle(context);
      FirestoreService.updateUser();
    }
  }
}

void checkAnswer(VoidCallback onWin, BuildContext context) async {
  showLoader(context);
  await InternetUtils.isInternetAvailable(context);
  if (context.mounted) {
    hideLoader(context);
  }
  if (AppState.isConnectedToInternet.value) {
    final qr = await QRScanner.scan(context);
    if (qr != null) {
      if (qr == AppState.riddleAnswer.value) {
        AudioService().playSoundEffect('sfx/level-win.ogg');
        nextRiddle(onWin, context);
      } else {
        AppState.triesLeft.value--;
        if (AppState.triesLeft.value == 0) {
          AudioService().playSoundEffect('sfx/game-over.ogg');
          clearUserData();
          FirestoreService.updateUser();
          AppState.currentGameState.value = GameState.lost;
        } else {
          FirestoreService.updateUser();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF3E2723),
              duration: Duration(seconds: 5),
              content: Text(
                "That's Wrong! Only ${AppState.triesLeft.value} ${AppState.triesLeft.value == 1 ? 'try' : 'tries'} left — maybe using Brain for once can help!",
                style: GoogleFonts.cinzelDecorative(
                  color: const Color(0xFFE8DCC5),
                ),
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF3E2723),
          content: Text(
            'Something went wrong! Try Again.',
            style: GoogleFonts.cinzelDecorative(color: const Color(0xFFE8DCC5)),
          ),
        ),
      );
    }
  }
}

void checkQuestionAnswer(
  VoidCallback onWin,
  BuildContext context,
  String answer,
) async {
  showLoader(context);
  await InternetUtils.isInternetAvailable(context);
  if (context.mounted) {
    hideLoader(context);
  }
  if (AppState.isConnectedToInternet.value) {
    if (answer.trim() == AppState.questionAnswer.value.trim()) {
      AudioService().playSoundEffect('sfx/level-win.ogg');
      nextRiddle(onWin, context);
    } else {
      AudioService().playSoundEffect('sfx/game-over.ogg');
      clearUserData();
      FirestoreService.updateUser();
      AppState.currentGameState.value = GameState.lost;
    }
  }
}

void saveRiddleData() async {
  final prefs = await SharedPreferences.getInstance();
  final String currentRiddle = AppState.currentRiddle.value;
  final int currentRiddleIndex = AppState.currentRiddleIndex.value;
  final int completedRiddles = AppState.completedRiddles.value;
  prefs.setString('currentRiddle', currentRiddle);
  prefs.setInt('currentRiddleIndex', currentRiddleIndex);
  prefs.setInt('completedRiddles', completedRiddles);
}

void loadRiddleData() async {
  final prefs = await SharedPreferences.getInstance();
  final String currentRiddle = prefs.getString('currentRiddle') ?? '';
  final int currentRiddleIndex = prefs.getInt('currentRiddleIndex') ?? 0;
  final int completedRiddles = prefs.getInt('completedRiddles') ?? 0;
  AppState.currentRiddle.value = currentRiddle;
  AppState.currentRiddleIndex.value = currentRiddleIndex;
  AppState.completedRiddles.value = completedRiddles;
}

void updateWinner(VoidCallback onWin, BuildContext context) async {
  showLoader(context);
  clearData();
  await FirestoreService.updateUserAndGameState();
  setLoggedOut();
  onWin();
  hideLoader(context);
}

void setLoggedOut() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('gamePass', '');
  prefs.setBool('isLoggedIn', false);
  prefs.setString('userId', AppState.userId.value);
  clearData();
}

void clearData() {
  AppState.isBuyingEnable.value = false;
  AppState.isGameStarted.value = false;
  AppState.isGameEnded.value = true;
  AppState.winnerName.value = AppState.name.value;

  AppState.isPaymentVerified.value = false;
  AppState.isGamePassEnable.value = false;
  AppState.currentRiddleIndex.value = 1;
  AppState.hasWon.value = true;
  AppState.isGameLost.value = false;
  AppState.paymentStatus.value = 'Not Verified';

  AppState.isLoggedIn.value = false;
}

void clearUserData() {
  AppState.isPaymentVerified.value = false;
  AppState.isGamePassEnable.value = false;
  AppState.currentRiddleIndex.value = 1;
  AppState.hasWon.value = false;
  AppState.isGameLost.value = true;
  AppState.paymentStatus.value = 'Not Verified';

  AppState.isLoggedIn.value = false;
}

class GeoServices {
  // Singleton
  static final GeoServices _instance = GeoServices._internal();
  factory GeoServices() => _instance;
  GeoServices._internal();

  Timer? _timer;
  bool _isListening = false;

  Future<void> start() async {
    if (_isListening) return;
    _isListening = true;

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        // Permission denied, stop
        _isListening = false;
        return;
      }
    }

    // Poll location every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );

        // Update AppState
        AppState.altitude.value = pos.altitude;
        AppState.PositionData.value = {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
        };

        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          AppState.trapCoordinates.value.latitude,
          AppState.trapCoordinates.value.longitude,
        );
        AppState.distance.value = distance;

        double maxDistance = AppState.trapRadius.value;
        double warnStart = AppState.warnStartRadius.value;
        AppState.redIntensity.value = mapValue(
          distance,
          warnStart,
          maxDistance,
          0.0,
          0.8,
        ).clamp(0.0, 0.8);

        if (distance >= AppState.warnStartRadius.value) {
          AppState.isOutsideWarning.value = true;
        } else {
          AppState.isOutsideWarning.value = false;
        }

        if (distance >= AppState.trapRadius.value) {
          AppState.isOutside.value = true;
        } else {
          AppState.isOutside.value = false;
        }
      } catch (e) {
        print('Error getting location: $e');
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isListening = false;
  }

  void dispose() {
    stop();
    AppState.altitude.dispose();
    AppState.PositionData.dispose();
    AppState.distance.dispose();
    AppState.redIntensity.dispose();
    AppState.isOutside.dispose();
  }
}

double mapValue(
  double value,
  double inMin,
  double inMax,
  double outMin,
  double outMax,
) {
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

class InternetUtils {
  InternetUtils._();

  static bool _isConnected = false;
  static bool _hasInternet = false;
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;
  static Timer? _timer;
  static bool _isDialogShowing = false;
  static BuildContext? _cachedContext;

  static bool get isConnected => _isConnected;
  static bool get hasInternet => _hasInternet;

  static Future<void> startListening() async {
    dispose();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      if (_cachedContext != null && _cachedContext!.mounted) {
        await checkInternetConnection(_cachedContext!);
      }
    });

    // Periodic check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_cachedContext != null && _cachedContext!.mounted) {
        await checkInternetConnection(_cachedContext!);
        debugPrint('Connected: $_isConnected, Internet: $_hasInternet');
      }
    });
  }

  /// Initialize with context - call this in your first widget
  static Future<void> initialize(BuildContext context) async {
    _cachedContext = context;

    // Initial check
    await checkInternetConnection(context);

    // Start listening if not already started
    if (_connectivitySubscription == null) {
      startListening();
    }
  }

  /// Check internet connection
  static Future<bool> checkInternetConnection(BuildContext context) async {
    if (!context.mounted) return false;

    try {
      // FIXED: checkConnectivity() now returns List<ConnectivityResult>
      final List<ConnectivityResult> connectivityResults = await Connectivity()
          .checkConnectivity();

      // Check if any connection type is available (not none)
      final connected = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );

      bool internet = false;

      if (connected) {
        internet = await _hasInternetAccess();
      }

      _isConnected = connected;
      _hasInternet = internet;

      // Update the global ValueNotifier
      AppState.isConnectedToInternet.value = connected && internet;

      if (!_isDialogShowing && context.mounted) {
        if (!connected) {
          _showNoConnectionDialog(context);
        } else if (!internet) {
          _showNoInternetAccessDialog(context);
        }
      } else if (_isDialogShowing && connected && internet && context.mounted) {
        _dismissDialog(context);
      }

      return connected && internet;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }

  /// Check actual internet access
  static Future<bool> _hasInternetAccess() async {
    try {
      // Try multiple endpoints to ensure internet connectivity
      final results = await Future.wait([
        _checkFirestore(),
        _checkGoogle(),
      ], eagerError: false);

      return results.any((success) => success);
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      return false;
    }
  }

  /// Check Firestore connectivity
  static Future<bool> _checkFirestore() async {
    try {
      final client = HttpClient();
      final request = await client
          .getUrl(
            Uri.parse(
              'https://firestore.googleapis.com/v1/projects/treasuregame-2e6d9/databases/(default)/documents/gameData/gameStates',
            ),
          )
          .timeout(const Duration(seconds: 4));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Check Google connectivity
  static Future<bool> _checkGoogle() async {
    try {
      final client = HttpClient();
      final request = await client
          .getUrl(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      await response.drain();
      client.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Show no connection dialog
  static void _showNoConnectionDialog(BuildContext context) {
    if (_isDialogShowing || !context.mounted) return;
    _showDialog(
      context,
      "No Network Connection",
      "You are not connected to any network.",
    );
  }

  /// Show no internet access dialog
  static void _showNoInternetAccessDialog(BuildContext context) {
    if (_isDialogShowing || !context.mounted) return;
    _showDialog(
      context,
      "No Internet Access",
      "You are connected to a network but there is no internet access.",
    );
  }

  /// Show dialog
  static void _showDialog(BuildContext context, String title, String content) {
    _isDialogShowing = true;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(content),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {
                  if (context.mounted) {
                    bool hasConnection = await _recheckConnection(context);
                    if (hasConnection) {
                      _dismissDialog(context);
                    } else {
                      // Show feedback that still no connection
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Still no internet connection'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Recheck connection on retry
  static Future<bool> _recheckConnection(BuildContext context) async {
    final List<ConnectivityResult> connectivityResults = await Connectivity()
        .checkConnectivity();

    final connected = connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );

    bool internet = false;
    if (connected) {
      internet = await _hasInternetAccess();
    }

    _isConnected = connected;
    _hasInternet = internet;

    // Update the global ValueNotifier
    AppState.isConnectedToInternet.value = connected && internet;

    return connected && internet;
  }

  /// Dismiss dialog
  static void _dismissDialog(BuildContext context) {
    if (_isDialogShowing && context.mounted) {
      _isDialogShowing = false;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 10),
              Text('Internet connection restored'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Check if internet is available (can be called anytime)
  static Future<bool> isInternetAvailable(BuildContext context) async {
    if (!context.mounted) return false;

    final List<ConnectivityResult> connectivityResults = await Connectivity()
        .checkConnectivity();

    final connected = connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );

    bool internet = false;

    if (connected) {
      internet = await _hasInternetAccess();
    }

    _isConnected = connected;
    _hasInternet = internet;

    AppState.isConnectedToInternet.value = connected && internet;

    if (!connected && context.mounted) {
      _showNoConnectionDialog(context);
      return false;
    } else if (!internet && context.mounted) {
      _showNoInternetAccessDialog(context);
      return false;
    }

    return true;
  }

  /// Dispose all subscriptions
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _timer?.cancel();
    _timer = null;
  }
}

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  // Remove the single sfx player - we'll create instances per sound

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.6;
  double _sfxVolume = 1.0;
  String? _currentMusicPath;

  Future<void> initialize() async {
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
  }

  // ==================== APP LIFECYCLE HANDLING ====================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      await _musicPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isMusicEnabled) await _musicPlayer.resume();
    }
  }

  // ==================== BACKGROUND MUSIC ====================

  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_isMusicEnabled) return;
    if (_currentMusicPath == assetPath &&
        await _musicPlayer.state == PlayerState.playing) return;

    try {
      _currentMusicPath = assetPath;
      await _musicPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    await _musicPlayer.resume();
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _currentMusicPath = null;
  }

  // ==================== SOUND EFFECTS ====================
  Future<void> playSoundEffect(String assetPath) async {
    if (!_isSfxEnabled) return;
    try {
      // Create a new player for each sound effect
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      await player.setReleaseMode(ReleaseMode.stop);
      
      await player.play(AssetSource(assetPath));
      
      // Dispose the player after the sound finishes
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      print('Error playing sound effect: $e');
    }
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    // Note: This will only affect new sound effects, not currently playing ones
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }

  // ==================== CLEANUP ====================
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _musicPlayer.dispose();
  }
}
