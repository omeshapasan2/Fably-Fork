import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../shop/product.dart';
import '../shop/cart.dart';
import '../../utils/requests.dart';
import '../../utils/prefs.dart';
import 'widgets/common_drawer.dart';
import 'widgets/bottom_nav_bar.dart';

class ProductService {
  final requests = BackendRequests();
  
   static String _baseUrl = 'http://192.168.1.7:5000/products';

  Future<List<Product>> fetchProducts() async {
    _baseUrl = '${requests.getUrl()}/products';
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // If the server returns a successful response, parse the JSON
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.images.isNotEmpty
                  ? product.images[0]
                  : '', // Show the first image
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '\$${product.price}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;


  // Refresh method to reload data from API

  Future<void> _refreshProducts() async {
    setState(() {
      futureProducts =
          ProductService().fetchProducts(); // Trigger a fresh fetch
    });
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signOut() async {
    final requests = BackendRequests();
    final prefs = Prefs();

    try{
      final response = await requests.getRequest('logout');
      if (response.statusCode==200){
          await prefs.clearPrefs();
        _showMessage('Logged out successfully');
      }
    }catch (e) {
      _showMessage('Error Loging out: $e');
    }

  }

  @override
  void initState() {
    super.initState();
    final requests = BackendRequests();
    final prefs = Prefs();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(!await requests.isLoggedIn()){
          print('User not logged in');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    futureProducts = ProductService().fetchProducts();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'FABLY',
        style: TextStyle(
          letterSpacing: 3,
          fontFamily: 'Italiana',
          fontSize: 32,
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            signOut().then((o){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            });
          },
        ),
      ],
    ),
    drawer: CommonDrawer(),
    body: LiquidPullToRefresh(
      color: const Color.fromARGB(255, 255, 255, 255),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      height: 60.0,
      showChildOpacityTransition: false,
      onRefresh: _refreshProducts,
      child: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          product: products[index],
                        ),
                      ),
                    );
                  },
                  child: ProductCard(product: products[index]),
                );
              },
            );
          } else {
            return const Center(child: Text('No products available.'));
          }
        },
      ),
    ),
    bottomNavigationBar: CommonBottomNavBar(
      currentIndex: 0,
    ),
  );
}
}
