import 'package:battleships/providers/game_provider.dart';
import 'package:battleships/views/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class PlaceShips extends StatefulWidget {
  const PlaceShips({super.key});
  static const route = '/place-ships';

  @override
  State<PlaceShips> createState() => _PlaceShipsState();
}

class _PlaceShipsState extends State<PlaceShips> {
  bool _isLoading = false;
  late List<List<bool>> _isSelected;
  int _selectedCount = 0;
  String? _aiType;

  @override
  void initState() {
    super.initState();
    _isSelected = List.generate(5, (_) => List<bool>.filled(5, false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture the AI argument once
    _aiType = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _submit() async {
    // Capture context‐bound objects before any async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final gameProv = Provider.of<GameProvider>(context, listen: false);

    if (_selectedCount < 5) {
      messenger.showSnackBar(const SnackBar(
        content: Text('You must place five ships'),
      ));
      return;
    }

    // Build the list of ship positions
    final positions = <String>[];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (_isSelected[row][col]) {
          // Row labels A–E (col) and column numbers 1–5 (row)
          final label = String.fromCharCode(65 + col) + (row + 1).toString();
          positions.add(label);
        }
      }
    }

    // Normalize AI argument
    var ai = _aiType;
    if (ai?.toLowerCase().contains('one') == true) {
      ai = 'oneship';
    }

    setState(() => _isLoading = true);
    try {
      await gameProv.startGame(positions, context, ai: ai);
    } catch (e) {
      // Show error
      var msg = e.toString();
      if (msg.startsWith('Exception:')) {
        msg = msg.substring('Exception:'.length).trim();
      }
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    authProv.updateShowCompletedGames(true);
    navigator.pushNamedAndRemoveUntil(HomePage.route, (_) => false);
  }

  void _toggleBox(int row, int col) {
    setState(() {
      if (_isSelected[row][col]) {
        _isSelected[row][col] = false;
        _selectedCount--;
      } else if (_selectedCount < 5) {
        _isSelected[row][col] = true;
        _selectedCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Place Ships')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Row labels A–E
                        Column(
                          children: ['A', 'B', 'C', 'D', 'E']
                              .map((label) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.02,
                                    ),
                                    child: Text(label),
                                  ))
                              .toList(),
                        ),
                        // Grid with column indicators and tappable boxes
                        Expanded(
                          child: Column(
                            children: [
                              // Column labels 1–5
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:
                                    List.generate(5, (i) => Text('${i + 1}')),
                              ),
                              // Ship placement grid
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                  ),
                                  itemCount: 25,
                                  itemBuilder: (context, index) {
                                    final row = index ~/ 5;
                                    final col = index % 5;
                                    return GestureDetector(
                                      onTap: () => _toggleBox(row, col),
                                      child: Container(
                                        margin: const EdgeInsets.all(2),
                                        color: _isSelected[row][col]
                                            ? Colors.blue[300]
                                            : Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}
