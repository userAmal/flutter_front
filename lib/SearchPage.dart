import 'package:flutter/material.dart';
import 'package:flutter_shop/CartPage.dart';
import 'package:flutter_shop/ProductDetailsPage.dart';
import 'package:flutter_shop/Profile.dart';
import 'package:flutter_shop/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int userId;

  SearchPage({required this.cart, required this.userId});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> searchResults = [];
  int currentIndex = 3;

  Future<void> searchProduct(String query) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:5000/products/search?name=$query'),
    );

    if (response.statusCode == 200) {
      setState(() {
        searchResults = List<Map<String, dynamic>>.from(
            jsonDecode(response.body)['products']);
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingProduct = widget.cart.firstWhere(
        (item) => item['id'] == product['id'],
        orElse: () => {'id': -1},
      );

      if (existingProduct['id'] != -1) {
        existingProduct['quantity'] += 1;
      } else {
        widget.cart.add({...product, 'quantity': 1});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            onChanged: searchProduct,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF800020),
        elevation: 0,
      ),
      body: searchResults.isEmpty
          ? const Center(
              child: Text(
                'Aucun produit trouvé.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final product = searchResults[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'http://192.168.1.3:5000/imagesProduit/${product['id']}.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '\$${product['price']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF800020),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF800020),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            product: product,
                            onAddToCart: addToCart,
                            cart: widget.cart,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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
