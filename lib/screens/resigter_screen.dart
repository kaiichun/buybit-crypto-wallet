import 'package:buybit/data/api/auth_service.dart';
import 'package:buybit/data/modal/user.dart';
import 'package:buybit/data/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        BuyBitUser newUser = BuyBitUser(
          id: firebaseUser.uid,
          name: _nameController.text,
          email: firebaseUser.email!,
        );
        await _authRepository.createUser(newUser);
        // Navigate to VerifyScreen
        Navigator.pushNamed(context, '/verify');
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0093E9), Color(0xFF80D0C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: const TextStyle(
                          fontSize: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          fontSize: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: _showPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _passwordVisibility,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _checkPasswordStrength,
                    ),
                    const SizedBox(height: 10),
                    if (_passwordStrength != null)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _passwordStrength == 'Weak'
                                ? 0.33
                                : _passwordStrength == 'Moderate'
                                    ? 0.66
                                    : 1.0,
                            backgroundColor: Colors.grey[300],
                            color: _passwordStrength == 'Strong'
                                ? Colors.green
                                : _passwordStrength == 'Moderate'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Password Strength: $_passwordStrength',
                            style: TextStyle(
                              color: _passwordStrength == 'Strong'
                                  ? Colors.green
                                  : _passwordStrength == 'Moderate'
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _showConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _confirmPasswordVisibility,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 64.0),
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
