import 'package:flutter/material.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'stat_item.dart';

class LandingStats extends StatefulWidget {
  const LandingStats({super.key});

  @override
  LandingStatsState createState() => LandingStatsState();
}

class LandingStatsState extends State<LandingStats> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItem(
          icon: Icons.people,
          value: AppState.players,
          label: AppState.playersLable,
        ),
        StatItem(
          icon: Icons.hourglass_empty,
          value: AppState.remainingTime,
          label: AppState.timerLable,
        ),
        StatItem(
          icon: Icons.monetization_on,
          value: AppState.prize,
          label: AppState.prizeLable,
          highlight: true,
        ),
      ],
    );
  }
}
