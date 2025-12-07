import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:treasure_game_v4/utils/functions.dart';

class FirestoreListener {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static bool _initialized = false;
  static bool _riddlesInitialized = false;
  static bool _userInitialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _listenToGameStates();
  }

  static void listenToRiddles() {
    if (_riddlesInitialized) return;
    _riddlesInitialized = true;
    _listenToRiddlesData();
  }
  
  static void listenToUser() {
    if (_userInitialized) return;
    _userInitialized = true;
    _listenToUserData();
  }

  static void _listenToGameStates() {
    _db.collection("gameData").doc("gameStates").snapshots().listen((snapshot) {
      print('data updated on the server GameStates');
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      AppState.gameStartTime.value = data['gameStartTime'];
      AppState.gameEndTime.value = data['gameEndTime'];
      AppState.gamePassBuyStartTime.value = data['gamePassBuyStartTime'];
      AppState.gamePassBuyEndTime.value = data['gamePassBuyEndTime'];
      AppState.players.value = data['players'];
      AppState.prize.value = data['prize'];
      AppState.isBuyingEnable.value = data['isBuyingEnable'];
      AppState.isGameStarted.value = data['isGameStarted'];
      AppState.isGameEnded.value = data['isGameEnded'];
      AppState.playersLable.value = data['playersLable'];
      AppState.timerLable.value = data['timerLable'];
      AppState.winnerName.value = data['winnerName'];

      bool isBuyingEnable_T = data['isBuyingEnable'];

      DynamicTimer.startTimer(
        startTime: isBuyingEnable_T
            ? AppState.gamePassBuyStartTime.value.toDate()
            : AppState.gameStartTime.value.toDate(),
        endTime: isBuyingEnable_T
            ? AppState.gamePassBuyEndTime.value.toDate()
            : AppState.gameEndTime.value.toDate(),
      );
    });
  }

  static void _listenToRiddlesData() {
    _db.collection("gameData").doc("riddleData").snapshots().listen((snapshot) {
      print('data updated on the server RiddlesData');
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      AppState.riddlesData.value = data;
    });
  }

  static void _listenToUserData() {
    _db.collection("users").doc("users").snapshots().listen((snapshot) {
      print('data updated on the server UserData');
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      AppState.completedRiddles.value = data['completedRiddles'];
      AppState.currentRiddleIndex.value = data['currentRiddleIndex'];
      AppState.hasWon.value = data['hasWon'];
      AppState.isGamePassEnable.value = data['isGamePassEnable'];
      AppState.isGameLost.value = data['isLost'];
      AppState.isPaymentVerified.value = data['isPaymentVerified'];
      AppState.paymentStatus.value = data['paymentStatus'];
      AppState.totalRiddles.value = data['totalRiddles'];

    });
  }
}
