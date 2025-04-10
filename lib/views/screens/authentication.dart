import 'package:battleships/views/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  static const route = '/authentication';

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    // capture context‑bound objects synchronously
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    final username = _usernameController.text;
    final password = _passwordController.text;
    String? error;
    if (username.length < 3) {
      error = 'Username must be at least 3 characters long';
    } else if (password.length < 3) {
      error = 'Password must be at least 3 characters long';
    } else if (username.contains(' ')) {
      error = 'Username cannot contain spaces';
    } else if (password.contains(' ')) {
      error = 'Password cannot contain spaces';
    }
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService().loginUser(username, password);
      if (!mounted) return;

      authProv.updateToken(response.accessToken);
      authProv.updateUsername(username);
      authProv.updateShowCompletedGames(true);

      setState(() => _isLoading = false);
      navigator.pushNamedAndRemoveUntil(HomePage.route, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      var msg = e.toString();
      if (msg.startsWith('Exception:')) {
        msg = msg.substring('Exception:'.length).trim();
      }
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> register() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    final username = _usernameController.text;
    final password = _passwordController.text;
    String? error;
    if (username.length < 3) {
      error = 'Username must be at least 3 characters long';
    } else if (password.length < 3) {
      error = 'Password must be at least 3 characters long';
    } else if (username.contains(' ')) {
      error = 'Username cannot contain spaces';
    } else if (password.contains(' ')) {
      error = 'Password cannot contain spaces';
    }
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService().registerUser(username, password);
      if (!mounted) return;

      authProv.updateToken(response.accessToken);
      authProv.updateUsername(username);

      setState(() => _isLoading = false);
      navigator.pushNamedAndRemoveUntil(HomePage.route, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      var msg = e.toString();
      if (msg.startsWith('Exception:')) {
        msg = msg.substring('Exception:'.length).trim();
      }
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  DateTime? _lastBackPress;
  Future<bool> onWillPop() {
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: MediaQuery.sizeOf(context).width * 0.5,
          backgroundColor: Colors.grey[100],
          behavior: SnackBarBehavior.floating,
          content: Container(
            alignment: Alignment.center,
            height: 20,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Press again to exit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Center(child: Text('Login'))),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                        controller: _usernameController,
                        decoration:
                            const InputDecoration(labelText: 'Username')),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password')),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: login, child: const Text('Log In')),
                        TextButton(
                            onPressed: register, child: const Text('Register')),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
