import 'package:battleships/views/widgets/app_drawer.dart';
import 'package:battleships/views/screens/play_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';

/// Displays the list of Battleships games and handles navigation.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GameProvider _gameController;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _gameController = Provider.of<GameProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameController.fetchGames(context);
    });
  }

  /// Prevents accidental exits by requiring a double back-press.
  Future<bool> _onWillPop() {
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: MediaQuery.sizeOf(context).width * 0.5,
          backgroundColor: Colors.grey[100],
          behavior: SnackBarBehavior.floating,
          content: Container(
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Press again to exit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final showCompleted = Provider.of<AuthProvider>(context, listen: false)
        .isShowingCompletedGames;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Battleships')),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _gameController.fetchGames(context),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Consumer<GameProvider>(
          builder: (ctx, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final games = controller.games;
            final messenger = ScaffoldMessenger.of(ctx);
            final navigator = Navigator.of(ctx);

            return ListView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              itemBuilder: (ctx, index) {
                final game = games[index];
                final isActive = game.gameStatus == 3 || game.gameStatus == 0;
                final isCompleted = !isActive;

                // Active vs. completed filtering
                if (isActive && !showCompleted) {
                  return Dismissible(
                    key: Key(game.gameId.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(Icons.delete, color: Colors.black),
                    ),
                    onDismissed: (direction) async {
                      messenger.showSnackBar(const SnackBar(
                        content: Text('Game forfeited'),
                      ));
                      await controller.cancelGame(game.gameId, ctx);
                      games.removeAt(index);
                    },
                    child: ListTile(
                      onTap: () => navigator.pushNamed(
                        PlayGame.route,
                        arguments: game.gameId,
                      ),
                      title: Text(
                        '#${game.gameId} '
                        '${game.gameStatus == 3 ? '${game.player1} vs ${game.player2}' : 'Waiting for opponent'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        game.gameStatus == 3
                            ? (game.playerPosition == game.currentTurn
                                ? 'myTurn'
                                : 'opponentTurn')
                            : 'matchmaking',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }

                if (isCompleted && showCompleted) {
                  return ListTile(
                    onTap: () => Navigator.of(ctx).pushNamed(
                      PlayGame.route,
                      arguments: game.gameId,
                    ),
                    title: Text(
                      '#${game.gameId} ${game.player1} vs ${game.player2}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      game.playerPosition == game.gameStatus
                          ? 'gameWon'
                          : 'gameLost',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
