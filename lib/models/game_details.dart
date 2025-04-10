class GameDetails {
  final int gameId;
  final int gameStatus;
  final int playerPosition;
  final int currentTurn;
  final String primaryPlayer;
  final String? secondaryPlayer;
  final List<String> shipPositions;
  final List<String> wreckPositions;
  final List<String> shotPositions;
  final List<String> sunkPositions;

  GameDetails({
    required this.gameId,
    required this.gameStatus,
    required this.playerPosition,
    required this.currentTurn,
    required this.primaryPlayer,
    this.secondaryPlayer,
    required this.shipPositions,
    required this.wreckPositions,
    required this.shotPositions,
    required this.sunkPositions,
  });

  factory GameDetails.fromJson(Map<String, dynamic> json) {
    return GameDetails(
      gameId: json['id'] as int,
      gameStatus: json['status'] as int,
      playerPosition: json['position'] as int,
      currentTurn: json['turn'] as int,
      primaryPlayer: json['player1'] as String,
      secondaryPlayer: json['player2'] as String?,
      shipPositions: List<String>.from(json['ships'] ?? []),
      wreckPositions: List<String>.from(json['wrecks'] ?? []),
      shotPositions: List<String>.from(json['shots'] ?? []),
      sunkPositions: List<String>.from(json['sunk'] ?? []),
    );
  }
}
