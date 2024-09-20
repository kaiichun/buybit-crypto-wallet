import 'package:buybit/data/modal/user.dart';
import 'package:buybit/data/modal/wallet.dart';
import 'package:buybit/data/repository/auth_repository.dart';
import 'package:buybit/data/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();
  bool _showPassword = true;
  bool _showConfirmPassword = true;
  String? _passwordStrength;
  void _passwordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
  void _confirmPasswordVisibility() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }
  bool _passwordChecker(String password) {
    final RegExp upper = RegExp(r'[A-Z]');
    final RegExp lower = RegExp(r'[a-z]');
    final RegExp number = RegExp(r'[0-9]');
    final RegExp special = RegExp(r'[!@#$%^&*()_]');
    return upper.hasMatch(password) &&
        lower.hasMatch(password) &&
        number.hasMatch(password) &&
        special.hasMatch(password);
  }
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = null;
      });
    } else if (password.length < 6 ||
        !RegExp(r'[a-zA-Z0-9!@#$%^&*()_]').hasMatch(password)) {
      setState(() {
        _passwordStrength = "Weak";
      });
    } else if (password.length >= 6 && password.length <= 8) {
      setState(() {
        _passwordStrength = "Moderate";
      });
    } else if (password.length > 8 && _passwordChecker(password)) {
      setState(() {
        _passwordStrength = "Strong";
      });
    } else {
      setState(() {
        _passwordStrength = "Moderate";
      });
    }
  }
  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    try {
      User? firebaseUser = await _authService.createUserWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (firebaseUser != null) {
        List<Wallet> wallets = [];
        BuyBitUser newUser = BuyBitUser(
          id: firebaseUser.uid,
          name: _nameController.text,
          email: firebaseUser.email!,
          wallets: wallets,
        );
        await _authRepository.createUser(newUser);
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: _showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _passwordVisibility,
                ),
              ),
              onChanged: (password) {
                _checkPasswordStrength(password);
              },
            ),
            if (_passwordStrength != null) ...[
              const SizedBox(height: 5),
              Text(
                'Password Strength: $_passwordStrength',
                style: TextStyle(
                  color: _passwordStrength == "Strong"
                      ? Colors.green
                      : _passwordStrength == "Moderate"
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: _confirmPasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
