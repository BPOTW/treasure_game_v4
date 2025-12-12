import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_game_v4/components/progress_bar.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:treasure_game_v4/utils/functions.dart';
import '../components/index.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback onWin;

  const GameScreen({super.key, required this.onWin});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    DynamicTimer.startTimer(
      startTime: AppState.gameStartTime.value.toDate(),
      endTime: AppState.gameEndTime.value.toDate(),
    );
    loadRiddle(context);
    AppState.isQuestion.addListener(() {
      setState(() {});
    });
    AppState.isQrEnabled.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    DynamicTimer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main game UI
        Column(
          children: [
            // Top Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  bottom: const BorderSide(color: Color(0xFF251510), width: 4),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder(
                    valueListenable: AppState.players,
                    builder: (context, value, child) {
                      return StatMini(
                        label: 'PLAYERS',
                        value: value.toString(),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 197, 52),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFFB8860B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder(
                          valueListenable: AppState.completedRiddles,
                          builder: (context, value, child) {
                            return Text(
                              '$value/',
                              style: GoogleFonts.cinzelDecorative(
                                color: const Color(0xFFB8860B),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: AppState.totalRiddles,
                          builder: (context, value, child) {
                            return Text(
                              '$value SOLVED',
                              style: GoogleFonts.cinzelDecorative(
                                color: const Color(0xFFB8860B),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: AppState.remainingTime,
                    builder: (context, value, child) {
                      return StatMini(
                        label: 'TIME LEFT',
                        value: value,
                        isDanger: true,
                      );
                    },
                  ),
                ],
              ),
            ),

            ValueListenableBuilder(
              valueListenable: AppState.distance,
              builder: (context, value, child) {
                return AppState.isQuestion.value
                    ? FillProgressBar(
                        progress:
                            (AppState.distance.value /
                            ((AppState.trapRadius.value)-10)),
                        fillColor: Colors.red,
                        borderColor: Colors.brown,
                        height: 12,
                      )
                    : Container();
              },
            ),

            ValueListenableBuilder(
              valueListenable: AppState.isOutsideWarning,
              builder: (context, value, child) {
                return value
                    ? Container(
                        margin: EdgeInsets.only(top: 10),
                        child: ParchmentContainer(
                          child: Text(
                            "Warning! If you want to win don't go any further",
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 14,
                              color: const Color(0xFF8D6E63),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      )
                    : Container();
              },
            ),

            Expanded(
              child: Center(
                child: ParchmentContainer(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 32,
                        color: Color(0xFF3E2723),
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder(
                        valueListenable: AppState.currentRiddle,
                        builder: (context, value, child) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              value.toString().replaceAll('\\n', '\n'),
                              key: ValueKey<String>(value),
                              style: GoogleFonts.imFellEnglish(
                                fontSize: 22,
                                color: const Color(0xFF4E342E),
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      Container(
                        height: 4,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8D6E63).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppState.isQuestion.value
                          ? Column(
                              children: [
                                Text(
                                  'SOLVE THE RIDDLE AND CHOOSE ONE OPTION. IF YOU CHOOSE THE WRONG OPTION YOU WILL LOOSE.',
                                  style: GoogleFonts.cinzelDecorative(
                                    fontSize: 10,
                                    color: const Color(0xFF8D6E63),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 30),
                              ],
                            )
                          : Column(
                              children: [
                                Text(
                                  'SOLVE THE RIDDLES TO FIND THE LOCATION',
                                  style: GoogleFonts.cinzelDecorative(
                                    fontSize: 10,
                                    color: const Color(0xFF8D6E63),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                      AppState.isQuestion.value
                          ? ValueListenableBuilder(
                              valueListenable: AppState.questionOptions,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => checkQuestionAnswer(
                                        widget.onWin,
                                        context,
                                        value['option1'],
                                      ),
                                      child: Text(
                                        value['option1'],
                                        style: GoogleFonts.cinzelDecorative(
                                          fontSize: 14,
                                          color: const Color(0xFF8D6E63),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () => checkQuestionAnswer(
                                        widget.onWin,
                                        context,
                                        value['option2'],
                                      ),
                                      child: Text(
                                        value['option2'],
                                        style: GoogleFonts.cinzelDecorative(
                                          fontSize: 14,
                                          color: const Color(0xFF8D6E63),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Container(),

                      !AppState.isQuestion.value && !AppState.isQrEnabled.value
                          ? GestureDetector(
                              onTap: () => continueNext(widget.onWin, context),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Continue',
                                  style: GoogleFonts.cinzelDecorative(
                                    fontSize: 16,
                                    color: const Color(0xFF8D6E63),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            // Scanner Medallion
            AppState.isQrEnabled.value
                ? GestureDetector(
                    onTap: () => checkAnswer(widget.onWin, context),
                    child: Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFB300), Color(0xFFB8860B)],
                        ),
                        border: Border.all(
                          color: const Color(0xFF5D4037),
                          width: 4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code,
                          size: 40,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),

        // Red overlay
        // ValueListenableBuilder(
        //   valueListenable: AppState.redIntensity,
        //   builder: (context, value, child) {
        //     return Positioned.fill(
        //       child: IgnorePointer(
        //         child: Container(color: Colors.red.withOpacity(value)),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}
