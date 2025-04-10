class ShotResponse {
  final String responseMessage;
  final bool isShipSunk;
  final bool isGameWon;

  ShotResponse({
    required this.responseMessage,
    required this.isShipSunk,
    required this.isGameWon,
  });

  factory ShotResponse.fromJson(Map<String, dynamic> json) {
    return ShotResponse(
      responseMessage: json['message'],
      isShipSunk: json['sunk_ship'],
      isGameWon: json['won'],
    );
  }
}
