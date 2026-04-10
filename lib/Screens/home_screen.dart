import 'package:ecommerce_app/Screens/categories_screen.dart';
import 'package:ecommerce_app/Screens/product_detail_screen.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/services/api_service.dart';
import 'package:ecommerce_app/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService apiService = ApiService();

  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<String> categories = [];

  bool isLoading = true;
  bool isCategoryLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> bannerImages = [
    'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=1200',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
    'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=1200',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        isCategoryLoading = true;
        errorMessage = null;
      });
    }

    final categoriesFuture = loadCategories();

    try {
      await loadProducts();
    } catch (e) {
      debugPrint('HomeScreen loadProducts error: $e');
      if (mounted) {
        setState(() {
          products = [];
          filteredProducts = [];
          errorMessage =
              'Unable to load products. Please check your connection and retry.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    await categoriesFuture;
  }

  Future<void> loadProducts() async {
    try {
      final data = await apiService.fetchProducts();
      if (mounted) {
        setState(() {
          products = data;
          filteredProducts = data;
        });
      }
    } catch (e) {
      debugPrint('Product API Error: $e');
      rethrow;
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await apiService.fetchCategories();
      if (mounted) {
        setState(() {
          categories = data;
          isCategoryLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Category API Error: $e');
      if (mounted) setState(() => isCategoryLoading = false);
    }
  }

  void searchProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final hasProducts = filteredProducts.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: Colors.deepOrange,
        child: CustomScrollView(
          primary: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop the Best',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse over 100 real products from top categories.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: searchProducts,
                              decoration: const InputDecoration(
                                hintText: 'Search the collection',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                searchController.clear();
                                searchProducts('');
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: bannerImages.length,
                  onPageChanged: (i) => setState(() => currentPage = i),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              bannerImages[index],
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    const Color.fromRGBO(0, 0, 0, 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Best Sellers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'New arrivals for your wardrobe',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bannerImages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: currentPage == index ? 28 : 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Colors.deepOrange
                            : Colors.black12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(top: 28, left: 16, right: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Explore Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: isCategoryLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoriesScreen(category: cat),
                              ),
                            ),
                            child: Container(
                              width: 115,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: getCategoryColor(
                                        cat,
                                      ).withAlpha(31),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      getCategoryIcon(cat),
                                      color: getCategoryColor(cat),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Text(
                                      categoryLabel(cat),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(top: 20, left: 16, right: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Featured Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                ),
              )
            else if (errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      Text(errorMessage!),
                      TextButton(
                        onPressed: _loadAllData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (!hasProducts)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No products matched your search.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                                child: Hero(
                                  tag: 'product_${product.id}',
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(Icons.broken_image),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getCategoryColor(
                                        product.category,
                                      ).withAlpha(31),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      categoryLabel(product.category),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: getCategoryColor(
                                          product.category,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${product.price}',
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<AppState>().addToCart(
                                            product,
                                            1,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product.title} added to cart',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: filteredProducts.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}
