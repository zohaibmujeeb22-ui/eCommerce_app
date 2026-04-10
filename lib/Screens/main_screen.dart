import 'package:ecommerce_app/Screens/cart_screen.dart';
import 'package:ecommerce_app/Screens/category_screen.dart';
import 'package:ecommerce_app/Screens/favorite_screen.dart';
import 'package:ecommerce_app/Screens/home_screen.dart';
import 'package:ecommerce_app/Screens/profile_screen.dart';
import 'package:ecommerce_app/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = "Guest";
  String? userProfilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  String formatUserEmail(String email) {
    if (email.isEmpty) return "Guest";
    if (!email.contains('@')) return email;
    String prefix = email.split('@')[0];
    return prefix.length > 12 ? '${prefix.substring(0, 12)}...' : prefix;
  }

  Future<void> _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName =
          prefs.getString('user_name') ??
          prefs.getString('user_email') ??
          "Guest";
    });
  }

  int currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(),
    const CategoryScreen(category: 'All'),
    const CartScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    "My Cart",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: appState.cartItems.isEmpty
                    ? const Center(child: Text("Cart is empty"))
                    : ListView.builder(
                        itemCount: appState.cartItems.length,
                        itemBuilder: (context, i) {
                          final item = appState.cartItems[i];
                          return ListTile(
                            title: Text(item.product.title),
                            trailing: Text("x${item.quantity}"),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black12,
              child: ClipOval(
                child: Image.network(
                  userProfilePicUrl ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      color: Colors.black45,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hello, ${formatUserEmail(userName)}",
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    "Discover your style",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Stay tuned for new drops!")),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_mall_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (appState.cartItems.isNotEmpty)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4800),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${appState.cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, Icons.home_outlined, 0),
            _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 1),
            _buildNavItem(Icons.shopping_bag, Icons.shopping_bag_outlined, 2),
            _buildNavItem(Icons.favorite, Icons.favorite_outline, 3),
            _buildNavItem(Icons.person, Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? Colors.white : Colors.white60,
          size: 26,
        ),
      ),
    );
  }
}
