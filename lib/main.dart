import 'package:battleships/views/screens/authentication.dart';
import 'package:battleships/config/routes.dart';
import 'package:battleships/views/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (context) => GameProvider(),
        ),
      ],
      child: const BattleshipsApp(),
    ),
  );
}

class BattleshipsApp extends StatelessWidget {
  const BattleshipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      routes: Routes.getRoutes(),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            return const HomePage();
          } else {
            return const AuthenticationPage();
          }
        },
      ),
    );
  }
}
