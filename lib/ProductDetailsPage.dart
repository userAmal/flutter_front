import 'package:flutter/material.dart';
import 'package:flutter_shop/CartPage.dart';
import 'package:flutter_shop/Profile.dart';
import 'package:flutter_shop/home.dart';
import 'package:flutter_shop/SearchPage.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onAddToCart;
  final List<Map<String, dynamic>> cart;
  final int userId;

  ProductDetailsPage({
    required this.product,
    required this.onAddToCart,
    required this.cart,
    required this.userId,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF800020),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    cart: widget.cart,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produit
            Stack(
              children: [
                Image.network(
                  'http://192.168.1.3:5000/imagesProduit/${widget.product['id']}.jpg',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.black.withOpacity(0.6),
                    child: Text(
                      "\$${widget.product['price'].toString()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Détails du produit
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ??
                        'Pas de description disponible.',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                ],
              ),
            ),

            // Bouton "Ajouter au panier"
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onAddToCart(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      '${widget.product['name']} a été ajouté au panier !',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ));
                },
                icon: const Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                ),
                label: const Text(
                  'Ajouter au panier',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Color(0xFF800020),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const [
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
                  builder: (context) => HomePage(userId: widget.userId)),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CartPage(cart: widget.cart, userId: widget.userId),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfilePage(userId: widget.userId, cart: widget.cart),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SearchPage(cart: widget.cart, userId: widget.userId),
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
      ),
    );
  }
}
