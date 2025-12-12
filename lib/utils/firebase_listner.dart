import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:treasure_game_v4/utils/functions.dart';

class FirestoreListener {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static StreamSubscription? gameStatesSub;
  static StreamSubscription? riddlesSub;
  static StreamSubscription? userSub;

  // Call once at app launch
  static void init() {
    _listenToGameStates();
  }

  // Call when user logs in or changes
  static void listenToUser(String userId) {
    if (userSub != null) userSub!.cancel();

    userSub = _db.collection("users").doc(userId).snapshots().listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      
      AppState.completedRiddles.value = data['completedRiddles'];
      AppState.currentRiddleIndex.value = data['currentRiddleIndex'];
      AppState.hasWon.value = data['hasWon'];
      AppState.isGamePassEnable.value = data['isGamePassEnable'];
      AppState.isGameLost.value = data['isLost'];
      AppState.isPaymentVerified.value = data['isPaymentVerified'];
      AppState.paymentStatus.value = data['paymentStatus'];
      AppState.triesLeft.value = data['triesLeft'];
    });
  }

  static void listenToRiddles() {
    if (riddlesSub != null) riddlesSub!.cancel();

    riddlesSub = _db.collection("gameData").doc("riddleData")
        .snapshots().listen((snapshot) {

      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      AppState.riddlesData.value = data;
      AppState.totalRiddles.value = data['totalRiddles'];
      AppState.totalIndex.value = data['totalIndex'];
    });
  }

  static void _listenToGameStates() {
    if (gameStatesSub != null) gameStatesSub!.cancel();

    gameStatesSub = _db.collection("gameData").doc("gameStates")
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {

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
      AppState.winnerId.value = data['winnerId'];
      AppState.trapRadius.value = data['trapRadius'].toDouble();
      AppState.trapCoordinates.value = data['trapCoordinates'];
      AppState.warnStartRadius.value = data['warnStartRadius'].toDouble();

      bool isBuying = data['isBuyingEnable'];
      if(AppState.isGameEnded.value && AppState.winnerId.value != AppState.userId.value){
        setLoggedOut();
        AppState.currentGameState.value = GameState.ended;
      }

      DynamicTimer.startTimer(
        startTime: isBuying
            ? AppState.gamePassBuyStartTime.value.toDate()
            : AppState.gameStartTime.value.toDate(),
        endTime: isBuying
            ? AppState.gamePassBuyEndTime.value.toDate()
            : AppState.gameEndTime.value.toDate(),
      );
    });
  }
}
