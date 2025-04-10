import 'package:battleships/providers/game_provider.dart';
import 'package:battleships/views/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/game_over_dialog.dart';

class PlayGame extends StatefulWidget {
  const PlayGame({super.key});
  static const route = '/play-game';

  @override
  State<PlayGame> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> {
  bool isLoading = false;
  bool refresh = false;
  List<List<bool>> isSelected =
      List.generate(5, (_) => List<bool>.filled(5, false));
  List<List<bool>> isAttacked =
      List.generate(5, (_) => List<bool>.filled(5, false));
  List<List<bool>> isSunk =
      List.generate(5, (_) => List<bool>.filled(5, false));
  List<List<bool>> isWrecks =
      List.generate(5, (_) => List<bool>.filled(5, false));
  List<List<bool>> isBomb =
      List.generate(5, (_) => List<bool>.filled(5, false));
  int selectedCount = 0;

  Future<void> submit(int id) async {
    final gameStartProvider = Provider.of<GameProvider>(context, listen: false);
    // List<String> selectedShips = [];

    if (countTrueValues() < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must place one ship',
          ),
        ),
      );
      return;
    }
    String? shipLocation;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (isAttacked[row][col]) {
          shipLocation = String.fromCharCode('A'.codeUnitAt(0) + col) +
              (row + 1).toString();
          shipLocation;
        }
      }
    }

    setState(() {
      isLoading = true;
    });
    try {
      final response = await gameStartProvider.playShot(
        id,
        shipLocation.toString(),
        context,
      );
      await gameStartProvider.getGameDetails(
        id,
        context,
      );
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.isShipSunk ? 'Ship sunk!' : 'No enemy ship hit',
            ),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });

      refresh = true;

      if (response != null && response.isGameWon) {
        GameOverDialog.show(context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception:')) {
        errorMessage = errorMessage.substring('Exception:'.length).trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    }
    isAttacked = List.generate(5, (_) => List<bool>.filled(5, false));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var gameId = ModalRoute.of(context)!.settings.arguments as int;
      Provider.of<GameProvider>(context, listen: false).getGameDetails(
        gameId,
        context,
      );
    });
  }

  Future<bool> onWillPop() {
    if (refresh) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(HomePage.route, (route) => false);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Play Game'),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              if (refresh) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(HomePage.route, (route) => false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<GameProvider>(
                builder: (context, gameProvider, _) {
                  if (gameProvider.isLoading) {
                    isSelected =
                        List.generate(5, (_) => List<bool>.filled(5, false));
                    isSunk =
                        List.generate(5, (_) => List<bool>.filled(5, false));
                    isWrecks =
                        List.generate(5, (_) => List<bool>.filled(5, false));
                    isBomb =
                        List.generate(5, (_) => List<bool>.filled(5, false));
                    isAttacked =
                        List.generate(5, (_) => List<bool>.filled(5, false));
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    for (String shipLocation
                        in gameProvider.gameDetails!.shipPositions) {
                      int col = shipLocation.codeUnitAt(0) - 'A'.codeUnitAt(0);
                      int row = int.parse(shipLocation.substring(1)) - 1;

                      isSelected[row][col] = true;
                    }
                    for (String sunk
                        in gameProvider.gameDetails!.sunkPositions) {
                      int col = sunk.codeUnitAt(0) - 'A'.codeUnitAt(0);
                      int row = int.parse(sunk.substring(1)) - 1;

                      isSunk[row][col] = true;
                    }
                    for (String wrecks
                        in gameProvider.gameDetails!.wreckPositions) {
                      int col = wrecks.codeUnitAt(0) - 'A'.codeUnitAt(0);
                      int row = int.parse(wrecks.substring(1)) - 1;

                      isWrecks[row][col] = true;
                    }
                    for (String bomb
                        in gameProvider.gameDetails!.shotPositions) {
                      int col = bomb.codeUnitAt(0) - 'A'.codeUnitAt(0);
                      int row = int.parse(bomb.substring(1)) - 1;

                      isBomb[row][col] = true;
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: size.height * 0.07,
                                  ),
                                  _buildRowIndicator('A', size),
                                  _buildRowIndicator('B', size),
                                  _buildRowIndicator('C', size),
                                  _buildRowIndicator('D', size),
                                  _buildRowIndicator('E', size),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildIndicator('1', size),
                                        _buildIndicator('2', size),
                                        _buildIndicator('3', size),
                                        _buildIndicator('4', size),
                                        _buildIndicator('5', size),
                                      ],
                                    ),
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          crossAxisSpacing: 0.0,
                                          mainAxisSpacing: 0.0,
                                        ),
                                        itemBuilder: (context, index) {
                                          int row = index % 5;
                                          int col = index ~/ 5;

                                          return GestureDetector(
                                            onTap: () {
                                              if (gameProvider.gameDetails
                                                          ?.currentTurn !=
                                                      gameProvider.gameDetails
                                                          ?.playerPosition ||
                                                  gameProvider.gameDetails
                                                          ?.gameStatus ==
                                                      1 ||
                                                  gameProvider.gameDetails
                                                          ?.gameStatus ==
                                                      2 ||
                                                  gameProvider.gameDetails
                                                          ?.gameStatus ==
                                                      0) {
                                                return;
                                              }
                                              _selectBox(row, col);
                                            },
                                            child: Container(
                                              color: isAttacked[row][col]
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                              child: isSelected[row][col] ||
                                                      isSunk[row][col] ||
                                                      isWrecks[row][col] |
                                                          isBomb[row][col]
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        if (isSelected[row]
                                                                [col] &&
                                                            !isWrecks[row][col])
                                                          Image.asset(
                                                            'assets/images/ship.png',
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          ),
                                                        if (isSunk[row][col])
                                                          Image.asset(
                                                            'assets/images/explosion.ico',
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          )
                                                        else if (isBomb[row]
                                                            [col])
                                                          Image.asset(
                                                            'assets/images/bomb.png',
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          ),
                                                        if (isWrecks[row][col])
                                                          Image.asset(
                                                            'assets/images/wrecks.png',
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          ),
                                                      ],
                                                    )
                                                  : Container(),
                                            ),
                                          );
                                        },
                                        itemCount: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: gameProvider.gameDetails?.currentTurn !=
                                        gameProvider
                                            .gameDetails?.playerPosition ||
                                    gameProvider.gameDetails?.gameStatus == 1 ||
                                    gameProvider.gameDetails?.gameStatus == 2 ||
                                    gameProvider.gameDetails?.gameStatus == 0
                                ? null
                                : () =>
                                    submit(gameProvider.gameDetails!.gameId),
                            child: const Text('Submit'),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildIndicator(String text, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      alignment: Alignment.center,
      child: Text(text),
    );
  }

  Widget _buildRowIndicator(String text, Size size) {
    return Container(
      padding: EdgeInsets.only(
        left: size.width * 0.05,
        right: size.width * 0.06,
        top: size.height * 0.03,
        bottom: size.height * 0.03,
      ),
      alignment: Alignment.center,
      child: Text(text),
    );
  }

  void _selectBox(int row, int col) {
    setState(
      () {
        if (isAttacked[row][col]) {
          isAttacked[row][col] = false;
        } else {
          selectedCount = isAttacked
              .expand((row) => row)
              .where((isSelected) => isSelected)
              .length;
          isAttacked = List.generate(5, (_) => List<bool>.filled(5, false));
          isAttacked[row][col] = true;
        }
      },
    );
  }

  int countTrueValues() {
    int count = 0;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (isAttacked[row][col]) {
          count++;
        }
      }
    }
    return count;
  }
}
