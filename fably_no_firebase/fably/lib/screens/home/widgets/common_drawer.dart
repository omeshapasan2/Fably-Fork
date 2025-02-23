import 'package:fably/screens/auth/login.dart';
import 'package:fably/screens/home/home.dart';
import 'package:fably/screens/scanner/add_images.dart';
import 'package:fably/screens/shop/cart.dart';
import 'package:fably/screens/shop/wishlist.dart';
import 'package:flutter/material.dart';
import '../../gender/gender_selection.dart';
import '../../../utils/requests.dart';
import '../../profile/pofile_page.dart';

class CommonDrawer extends StatelessWidget {

  Future<void> signOut(BuildContext context) async {
    final requests = BackendRequests();

    try{
      final response = await requests.getRequest('logout');
      if (response.statusCode==200){
        _showMessage(context, 'Logged out successfully');
      }
    }catch (e) {
      _showMessage(context, 'Error Loging out: $e');
    }

  }

  void _showMessage(BuildContext context, String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.tealAccent),
              child: Text('Menu',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: const Text('Back to Selection Screen'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AreYouScreen()),
                );
              },
            ),
            Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                )),
            Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'My cart',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                )),
            Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite_border_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Wishlist',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WishlistPage()),
                    );
                  },
                )),
            Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Virtual Try-On',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => UploadImagesPage()),
                    );
                  },
                )),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                )),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 25),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                    await signOut(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                //onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      );
  }
}