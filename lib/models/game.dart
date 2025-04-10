class Game {
  final int gameId;
  final String player1;
  final String? player2;
  final int playerPosition;
  final int gameStatus;
  final int currentTurn;

  Game({
    required this.gameId,
    required this.player1,
    this.player2,
    required this.playerPosition,
    required this.gameStatus,
    required this.currentTurn,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameId: json['id'] as int,
      player1: json['player1'] as String,
      player2: json['player2'] as String?,
      playerPosition: json['position'] as int,
      gameStatus: json['status'] as int,
      currentTurn: json['turn'] as int,
    );
  }
}
