class AuthResponse {
  final String statusMessage;
  final String accessToken;

  const AuthResponse({
    required this.statusMessage,
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        statusMessage: json['message'] ?? '',
        accessToken: json['access_token'] ?? '',
      );
}
