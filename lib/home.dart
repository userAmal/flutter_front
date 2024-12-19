import 'package:flutter/material.dart';
import 'package:flutter_shop/CartPage.dart';
import 'package:flutter_shop/ProductDetailsPage.dart';
import 'package:flutter_shop/Profile.dart';
import 'package:flutter_shop/SearchPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> cart = [];
  int currentIndex = 0;

  Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.3:5000/products'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['products'];
    } else {
      throw Exception('Failed to load products');
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingProduct = cart.firstWhere(
        (item) => item['id'] == product['id'],
        orElse: () => {'id': -1},
      );

      if (existingProduct['id'] != -1) {
        existingProduct['quantity'] += 1;
      } else {
        cart.add({...product, 'quantity': 1});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: HomeContent(
          userId: widget.userId,
          cart: cart,
          fetchProducts: fetchProducts,
          addToCart: addToCart,
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

          Widget page;
          if (index == 1) {
            page = CartPage(cart: cart, userId: widget.userId);
          } else if (index == 2) {
            page = ProfilePage(userId: widget.userId, cart: cart);
          } else if (index == 3) {
            page = SearchPage(cart: cart, userId: widget.userId);
          } else {
            page = HomePage(userId: widget.userId);
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        selectedItemColor: const Color(0xFF800020),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final int userId;
  final List<Map<String, dynamic>> cart;
  final Future<List<dynamic>> Function() fetchProducts;
  final Function(Map<String, dynamic>) addToCart;

  const HomeContent({
    Key? key,
    required this.userId,
    required this.cart,
    required this.fetchProducts,
    required this.addToCart,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.userId).then((profile) {
      setState(() {
        userProfile = profile;
      });
    }).catchError((error) {
      print("Error loading user profile: $error");
    });
  }

  Future<Map<String, dynamic>> fetchUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:5000/profile/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Partie supérieure avec arrière-plan coloré et contenu
        Container(
          height: 250, // Taille fixe pour la partie supérieure
          decoration: const BoxDecoration(
            color: Color(0xFF800020),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('images/1.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Welcome",
                            style: TextStyle(color: Colors.white)),
                        Text(
                          userProfile?['username'] ?? "Loading...",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
              ),
              // Champ de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  onTap: () {
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
                  decoration: InputDecoration(
                    hintText: "Search anything...",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Contenu défilable : uniquement les produits
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Bannière (fixe mais incluse dans le scroll view)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 160,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('images/1.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Discount 20% for clothing",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Titre "Popular Products" (fixe)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Popular Products",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Grille des produits (défilable)
              FutureBuilder<List<dynamic>>(
                future: widget.fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    return const SliverToBoxAdapter(
                        child: Center(child: Text('Error loading products')));
                  } else {
                    final products = snapshot.data ?? [];
                    return SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                  product: product,
                                  onAddToCart: widget.addToCart,
                                  cart: widget.cart,
                                  userId: widget.userId,
                                ),
                              ),
                            ),
                            child: Card(
                              elevation: 6.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15.0)),
                                    child: Image.network(
                                      'http://192.168.1.3:5000/imagesProduit/${product['id']}.jpg',
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      '${product['price']} DT',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: products.length,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
