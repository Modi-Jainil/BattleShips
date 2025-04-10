import 'package:battleships/views/screens/authentication.dart';
import 'package:battleships/views/screens/home_page.dart';
import 'package:battleships/views/screens/place_ships.dart';
import 'package:battleships/views/screens/play_game.dart';
import 'package:flutter/material.dart';

/// This class contains all the routes used in the app.
class Routes {
  static Map<String, WidgetBuilder> getRoutes() => routes;

  static Map<String, WidgetBuilder> get routes => {
        AuthenticationPage.route: (_) => const AuthenticationPage(),
        HomePage.route: (_) => const HomePage(),
        PlaceShips.route: (_) => const PlaceShips(),
        PlayGame.route: (_) => const PlayGame(),
      };
}
