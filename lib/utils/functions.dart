import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void enterGame() async {
  print(AppState.storedGamePass.value);
  bool res = await checkID(AppState.storedGamePass.value);
  print(res);
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
    AppState.totalRiddles.value = data['totalRiddles'] ?? 0;
    AppState.completedRiddles.value = data['completedRiddles'] ?? 0;
    AppState.currentRiddleIndex.value = data['currentRiddleIndex'] ?? '';
    AppState.hasWon.value = data['hasWon'] ?? false;
    AppState.isGameLost.value = data['isLost'] ?? false;
    saveGamePassInStorage();
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
  AppState.isLoggedIn.value = true;
}

void checkIfLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  AppState.isLoggedIn.value = isLoggedIn;
  if (isLoggedIn) {
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
    remainingTime = endTime.difference(DateTime.now());
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateRemainingTime(endTime);
      if (remainingTime.isNegative || remainingTime.inSeconds == 0) {
        _timer?.cancel();
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

  void stop() {
    _timer?.cancel();
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
        'isPaymentVerified': AppState.isPaymentVerified.value,
        'paymentStatus': AppState.paymentStatus.value,
        'transactionId': AppState.paymentId.value,
        'isGamePassEnable': AppState.isGamePassEnable.value,
        'totalRiddles': AppState.totalRiddles.value,
        'completedRiddles': AppState.completedRiddles.value,
        'currentRiddleIndex': AppState.currentRiddleIndex.value,
        'hasWon': AppState.hasWon.value,
        'isLost': AppState.isGameLost.value,
      };
      await _db.collection('users').doc().set(userData);
      print("data updated");
      return true;
    } catch (e) {
      print("Error updating Firestore: $e");
      return false;
    }
  }
}
