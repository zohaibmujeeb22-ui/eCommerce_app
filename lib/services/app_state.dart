import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class AppState extends ChangeNotifier {
  List<Product> favorites = [];
  List<CartItem> cartItems = [];

  AppState() {
    loadData();
  }

  bool isFavorite(Product product) =>
      favorites.any((item) => item.id == product.id);

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      favorites.removeWhere((item) => item.id == product.id);
    } else {
      favorites.add(product);
    }
    saveData();
    notifyListeners();
  }

  void addToCart(Product product, int qty) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      cartItems[index].quantity += qty;
    } else {
      cartItems.add(CartItem(product: product, quantity: qty));
    }

    saveData();
    notifyListeners();
  }

  void increaseQty(CartItem item) {
    item.quantity++;
    saveData();
    notifyListeners();
  }

  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      cartItems.remove(item);
    }
    saveData();
    notifyListeners();
  }

  double get totalPrice {
    return cartItems.fold(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(
      'favorites',
      jsonEncode(favorites.map((e) => e.toJson()).toList()),
    );

    prefs.setString(
      'cart',
      jsonEncode(cartItems.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final favData = prefs.getString('favorites');
    if (favData != null) {
      List decoded = jsonDecode(favData);
      favorites = decoded.map((e) => Product.fromJson(e)).toList();
    }

    final cartData = prefs.getString('cart');
    if (cartData != null) {
      List decoded = jsonDecode(cartData);
      cartItems = decoded.map((e) => CartItem.fromJson(e)).toList();
    }

    notifyListeners();
  }
}
