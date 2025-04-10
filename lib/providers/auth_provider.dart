import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _userName;
  bool _showCompletedGames = true;

  String? get accessToken => _accessToken;
  String? get userName => _userName;
  bool get isShowingCompletedGames => _showCompletedGames;

  bool get isLoggedIn => _accessToken?.isNotEmpty ?? false;

  void updateToken(String? newToken) {
    _accessToken = newToken;
    notifyListeners();
  }

  void updateUsername(String newUsername) {
    _userName = newUsername;
    notifyListeners();
  }

  void updateShowCompletedGames(bool shouldShow) {
    _showCompletedGames = shouldShow;
    notifyListeners();
  }

  void toggleShowCompletedGames() {
    _showCompletedGames = !_showCompletedGames;
    notifyListeners();
  }

  void logout() {
    _accessToken = null;
    _userName = null;
    _showCompletedGames = true;
    notifyListeners();
  }
}
