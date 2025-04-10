import 'package:battleships/providers/auth_provider.dart';
import 'package:battleships/views/screens/authentication.dart';
import 'package:battleships/views/screens/place_ships.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showCompletedGamesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.05),
          title: const Text(
            'Which AI do you want to play against?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAIOption('Random', context),
              _buildAIOption('Perfect', context),
              _buildAIOption('One ship (A1)', context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIOption(String option, context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        option,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(
          PlaceShips.route,
          arguments: option.toLowerCase(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Battleships',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                Text(
                  'Login as ${auth.userName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New game'),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(PlaceShips.route, arguments: null);
            },
          ),
          ListTile(
            leading: const Icon(Icons.android),
            title: const Text('New game (AI)'),
            onTap: () {
              Navigator.of(context).pop();
              _showCompletedGamesDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(
              auth.isShowingCompletedGames
                  ? 'Show completed games'
                  : 'Show active games',
            ),
            onTap: () {
              auth.toggleShowCompletedGames();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(HomePage.route, (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AuthenticationPage.route,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
