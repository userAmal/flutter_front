import 'package:flutter/material.dart';
import 'package:flutter_shop/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Fonction de vérification d'email
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Fonction de vérification de mot de passe (doit contenir au moins 8 caractères, 1 chiffre, 1 lettre majuscule)
  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[A-Z]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez remplir tous les champs'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez entrer un email valide'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Le mot de passe doit contenir au moins 8 caractères, une lettre majuscule et un chiffre'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:5000/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'address': _addressController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Succès
        Navigator.pushReplacementNamed(context, '/');
      } else if (response.statusCode == 400) {
        // Parsez le message d'erreur renvoyé par le backend
        final responseBody = jsonDecode(response.body);

        if (responseBody['error'] == 'email_exists') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cet email est déjà utilisé'),
            backgroundColor: Colors.red,
          ));
        } else if (responseBody['error'] == 'username_exists') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ce nom d\'utilisateur est déjà utilisé'),
            backgroundColor: Colors.red,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erreur lors de l\'inscription'),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'inscription'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur réseau : $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8), // Arrière-plan doux burgundy
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800020), // Couleur Burgundy
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _usernameController,
                label: 'Nom d\'utilisateur',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.home,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF800020), // Burgundy
                ),
                child: const Text(
                  'S\'inscrire',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  MaterialPageRoute(builder: (context) => LoginPage());
                },
                child: const Text(
                  'Déjà un compte? Se connecter',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF800020),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF800020)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF800020)),
        ),
      ),
      obscureText: obscureText,
    );
  }
}
