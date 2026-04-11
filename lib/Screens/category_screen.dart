import 'package:ecommerce_app/Screens/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/api_service.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService apiService = ApiService();
  List<String> categories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  String _getCategoryDetail(String name) {
    switch (name.toLowerCase()) {
      case 'electronics':
        return 'Latest gadgets & gear';
      case 'smartphones':
        return 'Mobile & accessories';
      case 'laptops':
        return 'High-performance PCs';
      case 'jewelery':
      case 'womens-jewellery':
        return 'Premium ornaments';
      case 'beauty':
        return 'Skincare & makeup';
      case 'mens-watches':
      case 'womens-watches':
        return 'Luxury timepieces';
      case 'mens-shoes':
      case 'womens-shoes':
        return 'Branded footwear';
      default:
        return 'Explore quality products';
    }
  }

  IconData getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
      case 'smartphones':
      case 'mobile-accessories':
        return Icons.smartphone_rounded;
      case 'laptops':
      case 'tablets':
        return Icons.laptop_rounded;
      case 'womens-jewellery':
      case 'jewelery':
        return Icons.diamond_rounded;
      case 'beauty':
      case 'skin-care':
      case 'fragrances':
        return Icons.spa_rounded;
      case 'furniture':
      case 'home-decoration':
        return Icons.chair_rounded;
      case 'groceries':
      case 'kitchen-accessories':
        return Icons.local_grocery_store;
      case 'mens-shirts':
      case 'mens-shoes':
      case 'mens-watches':
      case 'tops':
      case 'womens-dresses':
      case 'womens-bags':
      case 'womens-shoes':
      case 'womens-watches':
        return Icons.checkroom_rounded;
      case 'motorcycle':
      case 'vehicle':
        return Icons.motorcycle;
      case 'sports-accessories':
      case 'sunglasses':
        return Icons.sports_handball_rounded;
      default:
        return Icons.category;
    }
  }

  Color getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
      case 'smartphones':
      case 'mobile-accessories':
        return const Color(0xFF2196F3);
      case 'laptops':
      case 'tablets':
        return const Color(0xFF3F51B5);
      case 'beauty':
      case 'skin-care':
      case 'fragrances':
        return const Color(0xFFE91E63);
      case 'womens-jewellery':
      case 'jewelery':
        return const Color(0xFFFF9800);
      case 'furniture':
      case 'home-decoration':
        return const Color(0xFF795548);
      case 'groceries':
      case 'kitchen-accessories':
        return const Color(0xFF4CAF50);
      case 'mens-shirts':
      case 'mens-shoes':
      case 'mens-watches':
      case 'tops':
      case 'womens-dresses':
      case 'womens-bags':
      case 'womens-shoes':
      case 'womens-watches':
        return const Color(0xFF9C27B0);
      case 'motorcycle':
      case 'vehicle':
        return const Color(0xFF607D8B);
      case 'sports-accessories':
      case 'sunglasses':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF3F51B5);
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await apiService.fetchCategories();
      if (!mounted) return;
      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load categories. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shop by Category',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                ),
              )
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final Color themeColor = getCategoryColor(cat);
                    final IconData themeIcon = getCategoryIcon(cat);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoriesScreen(category: cat),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                themeIcon,
                                color: themeColor,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              cat.toUpperCase().replaceAll('-', ' '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCategoryDetail(cat),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withOpacity(0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 10,
                                  color: themeColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
