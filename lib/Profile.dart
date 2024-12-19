import 'package:flutter/material.dart';
import 'package:flutter_shop/CartPage.dart';
import 'package:flutter_shop/SearchPage.dart';
import 'package:flutter_shop/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;
  final List<Map<String, dynamic>> cart;

  ProfilePage({required this.userId, required this.cart});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int currentIndex = 2;

  Future<void> loadUserProfile() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:5000/profile/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        usernameController.text = data['username'];
        emailController.text = data['email'];
        addressController.text = data['address'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erreur de chargement du profil'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  // Fonction pour effectuer la déconnexion
  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.3:5000/logout'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Si déconnexion réussie, redirigez vers la page d'accueil ou la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(userId: widget.userId)),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Déconnexion réussie'),
        backgroundColor: Colors.green,
      ));
    } else {
      // Si la déconnexion échoue, affichez un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erreur de déconnexion'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Empêche l'affichage de la flèche de retour
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('images/1.jpg'),
            ),
            SizedBox(width: 10),
            Text(
              'Mon Profil',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF800020), Color(0xFFB22222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: logout, // Appel de la fonction logout
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Informations du profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF800020),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'utilisateur',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Changer le mot de passe (optionnel)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF800020),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // Récupérer les données modifiées
                final updatedUsername = usernameController.text;
                final updatedEmail = emailController.text;
                final updatedAddress = addressController.text;
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                // Validation des champs
                if (updatedEmail.isEmpty ||
                    !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                        .hasMatch(updatedEmail)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Email invalide'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                if (currentPassword.isNotEmpty &&
                    (newPassword.isEmpty || confirmPassword.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Veuillez remplir le nouveau mot de passe et sa confirmation'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                // Préparer les données à envoyer au serveur
                Map<String, dynamic> data = {
                  'username': updatedUsername,
                  'email': updatedEmail,
                  'address': updatedAddress,
                };

                if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                  data['current_password'] = currentPassword;
                  data['new_password'] = newPassword;
                }

                // Envoi des données au serveur pour la mise à jour du profil
                final response = await http.put(
                  Uri.parse('http://192.168.1.3:5000/profile/${widget.userId}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(data),
                );

                if (response.statusCode == 200) {
                  // Effacer les champs de mot de passe après la mise à jour
                  currentPasswordController.clear();
                  newPasswordController.clear();
                  confirmPasswordController.clear();

                  // Affichage du message de succès
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  // Affichage du message d'erreur
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Erreur lors de la mise à jour du profil'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Enregistrer toutes les modifications',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userId: widget.userId),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(
                  cart: widget.cart,
                  userId: widget.userId,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userId: widget.userId,
                  cart: widget.cart,
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                  cart: widget.cart,
                  userId: widget.userId,
                ),
              ),
            );
          }
        },
        selectedItemColor: const Color(0xFF800020),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(color: Color(0xFF800020), fontSize: 14),
        unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}
