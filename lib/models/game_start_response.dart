class GameStartResponse {
  final int gameId;
  final int playerId;
  final bool isMatched;

  const GameStartResponse({
    required this.gameId,
    required this.playerId,
    required this.isMatched,
  });

  factory GameStartResponse.fromJson(Map<String, dynamic> json) {
    return GameStartResponse(
      gameId: json['id'] as int,
      playerId: json['player'] as int,
      isMatched: json['matched'] as bool,
    );
  }
}
