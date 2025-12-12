import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum GameState { landing, playing, victory, ended, lost, loading }

class AppState {
  static ValueNotifier<int> temp = ValueNotifier<int>(10);

  static ValueNotifier<GameState> currentGameState = ValueNotifier(GameState.loading);
  static ValueNotifier<double> altitude = ValueNotifier<double>(0.0);
  static ValueNotifier<double> latitude = ValueNotifier<double>(0.0);
  static ValueNotifier<double> longitude = ValueNotifier<double>(0.0);
  static ValueNotifier<double> distance = ValueNotifier<double>(0.0);
  static ValueNotifier<double> trapRadius = ValueNotifier<double>(0.0);
  static ValueNotifier<double> warnStartRadius = ValueNotifier<double>(0.0);
  static ValueNotifier<double> redIntensity = ValueNotifier<double>(0.0);
  static ValueNotifier<GeoPoint> trapCoordinates = ValueNotifier<GeoPoint>(GeoPoint(0, 0));
  static ValueNotifier<bool> isOutside = ValueNotifier(false);
  static ValueNotifier<bool> isOutsideWarning = ValueNotifier(false);
  static ValueNotifier<Map> PositionData = ValueNotifier<Map>({'latitude':0.0,'longitude':0.0});

  static ValueNotifier<String> userId = ValueNotifier("");
  static ValueNotifier<String> name = ValueNotifier("");
  static ValueNotifier<String> email = ValueNotifier("");
  static ValueNotifier<String> phoneNo = ValueNotifier("");
  static ValueNotifier<String> paymentId = ValueNotifier("");
  static ValueNotifier<int> triesLeft = ValueNotifier(0);
  static ValueNotifier<bool> hasWon = ValueNotifier(false);
  static ValueNotifier<bool> isGamePassEnable = ValueNotifier(false);

  static ValueNotifier<Map> riddlesData = ValueNotifier({});
  static ValueNotifier<String> currentRiddle = ValueNotifier("");
  static ValueNotifier<int> completedRiddles= ValueNotifier(0);
  static ValueNotifier<int> totalRiddles = ValueNotifier(0);
  static ValueNotifier<int> totalIndex = ValueNotifier(0);
  static ValueNotifier<int> currentRiddleIndex = ValueNotifier(1);
  static ValueNotifier<String> riddleAnswer = ValueNotifier("");
  static ValueNotifier<Map> questionOptions = ValueNotifier({'option1':'','option2':''});
  static ValueNotifier<String> questionAnswer = ValueNotifier("null");
  static ValueNotifier<bool> isQrEnabled = ValueNotifier(false);
  static ValueNotifier<bool> isQuestion = ValueNotifier(false);

  static ValueNotifier<Timestamp> gamePassBuyEndTime = ValueNotifier(Timestamp(0,0));
  static ValueNotifier<Timestamp> gamePassBuyStartTime = ValueNotifier(Timestamp(0,0));
  static ValueNotifier<Timestamp> gameStartTime = ValueNotifier(Timestamp(0,0));
  static ValueNotifier<Timestamp> gameEndTime = ValueNotifier(Timestamp(0,0));
  static ValueNotifier<String> remainingTime = ValueNotifier("");

  static ValueNotifier<String> timerLable = ValueNotifier("STARTS IN");
  static ValueNotifier<String> playersLable = ValueNotifier("PLAYERS");
  static ValueNotifier<String> prizeLable = ValueNotifier("PRIZE");
  static ValueNotifier<String> timerValue = ValueNotifier("00:00:00");
  static ValueNotifier<String> gameTimerValue = ValueNotifier("");
  static ValueNotifier<int> players = ValueNotifier(14390);
  static ValueNotifier<int> prize = ValueNotifier(50000);
  
  static ValueNotifier<String> storedGamePass = ValueNotifier("");
  static ValueNotifier<bool> isBuyingEnable = ValueNotifier(false);
  static ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  static ValueNotifier<bool> isPaymentVerified = ValueNotifier(false);
  static ValueNotifier<String> paymentStatus = ValueNotifier("");
  static ValueNotifier<bool> isGameStarted = ValueNotifier(false);
  static ValueNotifier<bool> isGameEnded = ValueNotifier(false);
  static ValueNotifier<String> winnerName = ValueNotifier("");
  static ValueNotifier<String> winnerId = ValueNotifier("");
  static ValueNotifier<bool> isGameLost = ValueNotifier(false);
  static ValueNotifier<bool> isConnectedToInternet = ValueNotifier(false);
  static ValueNotifier<bool> cameraPermission = ValueNotifier(false);
  static ValueNotifier<String> qrScanResult = ValueNotifier("");
  static ValueNotifier<bool> isDataLoaded = ValueNotifier(false);
  static ValueNotifier<bool> isTimerEnded = ValueNotifier(false);
}

