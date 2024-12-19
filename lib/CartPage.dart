import 'package:flutter/material.dart';
import 'package:flutter_shop/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int userId;

  CartPage({required this.cart, required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  int currentIndex = 1;

  // Calcul du total du panier
  double getTotal() {
    double total = 0;
    for (var product in widget.cart) {
      total += product['price'] * product['quantity'];
    }
    return total;
  }

  void updateQuantity(Map<String, dynamic> product, int delta) async {
    setState(() {
      product['quantity'] += delta;
      if (product['quantity'] <= 0) {
        widget.cart.remove(product);
      }
    });

    // Mise à jour dans la table `products`
    final productUpdateResponse = await http.post(
      Uri.parse('http://192.168.1.3:5000/update_product_quantity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_id': product['id'],
        'quantity': product['quantity'],
      }),
    );

    if (productUpdateResponse.statusCode == 200) {
      print('Quantité du produit mise à jour');
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text('Erreur lors de la mise à jour du produit'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void removeProduct(Map<String, dynamic> product) {
    setState(() {
      widget.cart.remove(product);
    });
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text('${product['name']} a été supprimé du panier !'),
      backgroundColor: Colors.red,
    ));
  }

  Future<bool> placeOrder(int userId) async {
    if (widget.cart.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text('Aucun produit commandé. Votre panier est vide.'),
        backgroundColor: Colors.orange,
      ));
      return false;
    }

    final totalOrder = getTotal(); // Calcul du total de la commande

    final url = Uri.parse('http://192.168.1.3:5000/profile/$userId');
    final orderUrl = Uri.parse(
        'http://192.168.1.3:5000/place_order'); // URL pour l'API de commande
    final emailUrl = Uri.parse('http://192.168.1.3:5000/send_order_email');
    try {
      // Récupérer les informations utilisateur
      final profileResponse = await http.get(url);
      if (profileResponse.statusCode != 200) {
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
          content:
              Text('Erreur lors de la récupération du profil utilisateur.'),
          backgroundColor: Colors.red,
        ));
        return false;
      }

      final profileData = jsonDecode(profileResponse.body);
      final userEmail = profileData['email'];
      final userName = profileData['username'];

      // Construire les données des produits pour l'email
      List<Map<String, dynamic>> products = widget.cart
          .map((product) => {
                'name': product['name'],
                'quantity': product['quantity'],
                'price': product['price'],
              })
          .toList();

      // Définir cartItems
      List<Map<String, dynamic>> cartItems = widget.cart
          .map((product) => {
                'product_id': product['id'],
                'quantity': product['quantity'],
                'total': product['price'] * product['quantity'],
              })
          .toList();

      // Enregistrer la commande dans la base de données
      final orderResponse = await http.post(
        orderUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'total': totalOrder,
          'cart_items': cartItems, // Utilisation de cartItems
        }),
      );

      if (orderResponse.statusCode == 200) {
        // Si la commande a été enregistrée avec succès, envoyer l'email
        final emailResponse = await http.post(
          emailUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': userEmail,
            'name': userName,
            'products': products,
          }),
        );

        if (emailResponse.statusCode == 200) {
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
            content: Text('Commande passée avec succès et email envoyé !'),
            backgroundColor: Colors.green,
          ));
          return true;
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
            content: Text('Erreur lors de l\'envoi de l\'email.'),
            backgroundColor: Colors.red,
          ));
          return false;
        }
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'enregistrement de la commande.'),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Erreur de connexion : $e'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  Future<bool> add(int userId) async {
    if (widget.cart.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text('Aucun produit commandé. Votre panier est vide.'),
        backgroundColor: Colors.orange,
      ));
      return false;
    }

    final totalOrder = getTotal(); // Calcul du total de la commande

    final url = Uri.parse(
        'http://192.168.1.3:5000/add_to_cart'); // URL pour l'API de commande
    try {
      // Construire les données des produits du panier
      List<Map<String, dynamic>> cartItems = widget.cart
          .map((product) => {
                'product_id': product['id'],
                'quantity': product['quantity'],
                'total': product['price'] * product['quantity'],
              })
          .toList();

      // Enregistrer la commande dans la base de données
      final orderResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'total': totalOrder,
          'cart_items': cartItems, // Ajouter les produits du panier
        }),
      );

      if (orderResponse.statusCode == 200) {
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
          content: Text('Commande passée avec succès !'),
          backgroundColor: Colors.green,
        ));
        return true;
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'enregistrement de la commande.'),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Erreur de connexion : $e'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF800020),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.0),
              ),
            ),
            child: const Center(
              child: Text(
                'Votre Panier',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: widget.cart.isEmpty
                ? const Center(
                    child: Text(
                      'Votre panier est vide',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final product = widget.cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12.0),
                              ),
                              child: Image.network(
                                'http://192.168.1.3:5000/imagesProduit/${product['id']}.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${product['price']}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () =>
                                              updateQuantity(product, -1),
                                        ),
                                        Text(
                                          '${product['quantity']}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () =>
                                              updateQuantity(product, 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeProduct(product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${getTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () async {
                final isSuccess = await placeOrder(widget.userId);
                if (isSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(userId: widget.userId)),
                  );
                  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
                    content:
                        Text('Commande passée avec succès et email envoyé !'),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
                    content: Text('Erreur lors de la commande'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text(
                'Commander',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
