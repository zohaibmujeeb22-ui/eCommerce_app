import 'package:ecommerce_app/Screens/categories_screen.dart';
import 'package:ecommerce_app/Screens/product_detail_screen.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/services/api_service.dart';
import 'package:ecommerce_app/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final Function(Product) onProductSelected;

  ProductSearchDelegate({
    required this.products,
    required this.categories,
    required this.onCategorySelected,
    required this.onProductSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _getSearchResults();

    return Container(
      color: Colors.grey[50],
      child: results.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return result is Product
                    ? _buildProductResult(context, result)
                    : _buildCategoryResult(context, result as String);
              },
            ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _getSuggestions();

    return Container(
      color: Colors.grey[50],
      child: ListView(
        children: [
          if (query.isEmpty) ...[
            _buildSuggestionHeader('Popular Categories'),
            ...categories
                .take(6)
                .map((category) => _buildCategorySuggestion(context, category)),
            const SizedBox(height: 20),
            _buildSuggestionHeader('Recent Searches'),
            _buildRecentSearchItem(context, 'beauty'),
            _buildRecentSearchItem(context, 'electronics'),
            _buildRecentSearchItem(context, 'fashion'),
          ] else ...[
            ...suggestions.map((suggestion) {
              return suggestion is Product
                  ? _buildProductSuggestion(context, suggestion)
                  : _buildCategorySuggestion(context, suggestion as String);
            }),
          ],
        ],
      ),
    );
  }

  List<dynamic> _getSuggestions() {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final categorySuggestions = categories
        .where((cat) => categoryLabel(cat).toLowerCase().contains(queryLower))
        .toList();

    final productSuggestions = products
        .where((product) => product.title.toLowerCase().contains(queryLower))
        .take(5)
        .toList();

    return [...categorySuggestions, ...productSuggestions];
  }

  List<dynamic> _getSearchResults() {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final categoryResults = categories
        .where((cat) => categoryLabel(cat).toLowerCase().contains(queryLower))
        .toList();

    final productResults = products
        .where((product) => product.title.toLowerCase().contains(queryLower))
        .toList();

    return [...categoryResults, ...productResults];
  }

  Widget _buildSuggestionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildCategorySuggestion(BuildContext context, String category) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(category),
          color: _getCategoryColor(category),
        ),
      ),
      title: Text(
        categoryLabel(category),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Browse category'),
      onTap: () {
        query = categoryLabel(category);
        onCategorySelected(category);
        close(context, category);
      },
    );
  }

  Widget _buildProductSuggestion(BuildContext context, Product product) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.image,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 40),
        ),
      ),
      title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${product.price}'),
      onTap: () {
        query = product.title;
        onProductSelected(product);
        close(context, product.title);
      },
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, String searchTerm) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(searchTerm),
      onTap: () {
        query = searchTerm;
        showResults(context);
      },
    );
  }

  Widget _buildCategoryResult(BuildContext context, String category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getCategoryColor(category).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(category),
            color: _getCategoryColor(category),
            size: 24,
          ),
        ),
        title: Text(
          categoryLabel(category),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('${_getCategoryProductCount(category)} products'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          onCategorySelected(category);
          close(context, category);
        },
      ),
    );
  }

  Widget _buildProductResult(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
          ),
        ),
        title: Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.price}',
              style: const TextStyle(
                color: Color.fromARGB(255, 249, 109, 67),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              categoryLabel(product.category),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          onProductSelected(product);
          close(context, product.title);
        },
      ),
    );
  }

  int _getCategoryProductCount(String category) {
    return products.where((p) => p.category == category).length;
  }

  IconData _getCategoryIcon(String categoryName) {
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

  Color _getCategoryColor(String categoryName) {
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
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ApiService apiService = ApiService();

  List<Product> products = [];
  List<String> categories = [];

  bool isLoading = true;
  bool isCategoryLoading = true;
  bool isLoadingBannerProducts = true;
  String? errorMessage;

  List<Product> bannerProducts = [];

  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        isCategoryLoading = true;
        isLoadingBannerProducts = true;
        errorMessage = null;
      });
    }

    final categoriesFuture = loadCategories();
    final bannerFuture = _loadBannerProducts();

    try {
      await loadProducts();
    } catch (e) {
      debugPrint('HomeScreen loadProducts error: $e');
      if (mounted) {
        setState(() {
          products = [];
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
    await bannerFuture;
  }

  Future<void> _loadBannerProducts() async {
    try {
      final data = await apiService.fetchProducts();
      if (mounted) {
        setState(() {
          final techProducts = data.where((p) {
            final category = p.category.toLowerCase();
            final title = p.title.toLowerCase();
            return category == 'electronics' ||
                title.contains('watch') ||
                title.contains('mobile') ||
                title.contains('laptop');
          }).toList();

          if (techProducts.isNotEmpty) {
            bannerProducts = techProducts.take(5).toList();
          } else {
            bannerProducts = data.take(5).toList();
          }

          isLoadingBannerProducts = false;
        });
      }
    } catch (e) {
      debugPrint('Banner Products API Error: $e');
      if (mounted) {
        setState(() {
          isLoadingBannerProducts = false;
          bannerProducts = [];
        });
      }
    }
  }

  Future<void> loadProducts() async {
    try {
      final data = await apiService.fetchProducts();
      if (mounted) {
        setState(() {
          products = data;
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

  void _onSearchPressed() async {
    final result = await showSearch(
      context: context,
      delegate: ProductSearchDelegate(
        products: products,
        categories: categories,
        onCategorySelected: _navigateToCategory,
        onProductSelected: _navigateToProduct,
      ),
    );

    if (result != null && result.isNotEmpty) {}
  }

  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoriesScreen(category: category)),
    );
  }

  void _navigateToProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
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
    final hasProducts = products.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: Colors.deepOrange,
        child: CustomScrollView(
          primary: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _onSearchPressed,
                          borderRadius: BorderRadius.circular(25),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.black54),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Search products, categories...',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withAlpha(26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.deepOrange,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoadingBannerProducts)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (bannerProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bannerProducts.length,
                    onPageChanged: (i) => setState(() => currentPage = i),
                    itemBuilder: (context, index) {
                      final product = bannerProducts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // 1. IMAGE WITH WHITE BACKGROUND
                                Container(
                                  color: Colors.white,
                                  child: Hero(
                                    tag: 'banner_${product.id}',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 40.0,
                                      ), // Room for text
                                      child: Image.network(
                                        product.image,
                                        fit: BoxFit
                                            .contain, // Best for electronics
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[100],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                // 2. PREMIUM DARK GRADIENT OVERLAY
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      stops: [0.0, 0.6],
                                      colors: [
                                        Color.fromRGBO(0, 0, 0, 0.85),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // 3. AGENCY BADGE (TOP LEFT)
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.bolt,
                                          color: Colors.deepOrange,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "PREMIUM TECH",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Exclusive Drop',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '\$${product.price}',
                                                style: const TextStyle(
                                                  color: Colors.deepOrange,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              context
                                                  .read<AppState>()
                                                  .addToCart(product, 1);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.title.length > 20 ? "${product.title.substring(0, 20)}..." : product.title} added to cart',
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFF1A1A1A,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProductDetailScreen(
                                                        product: product,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            icon: const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Buy Now',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (bannerProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(bannerProducts.length, (index) {
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
                    final product = products[index];
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
                  }, childCount: products.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}
