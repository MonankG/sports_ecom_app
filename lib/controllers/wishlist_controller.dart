import 'package:get/get.dart';
import '../models/product_model.dart';
import '../controllers/cart_controller.dart';

class WishlistController extends GetxController {
  final RxList<Product> items = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    // You could load saved wishlist items from local storage here
    loadWishlist();
  }

  void loadWishlist() {
    // Implement loading from persistent storage if needed
    // For example, if using SharedPreferences:
    // final savedItems = _prefs.getStringList('wishlist') ?? [];
    // items.value = savedItems.map((id) => _getProductById(id)).toList();
  }

  void saveWishlist() {
    // Implement saving to persistent storage if needed
    // For example:
    // _prefs.setStringList('wishlist', items.map((p) => p.id).toList());
  }

  // Add a product to wishlist
  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      items.add(product);
      saveWishlist();
    }
  }

  // Remove a product from wishlist
  void removeFromWishlist(String productId) {
    items.removeWhere((item) => item.id == productId);
    saveWishlist();
  }

  // Toggle wishlist status (add if not in wishlist, remove if it is)
  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  // Check if a product is in the wishlist
  bool isInWishlist(String productId) {
    return items.any((item) => item.id == productId);
  }

  // Clear the entire wishlist
  void clearWishlist() {
    items.clear();
    saveWishlist();
  }

  // Add all wishlist items to cart
  void addAllToCart() {
    try {
      final CartController cartController = Get.find<CartController>();
      for (var product in items) {
        cartController.addToCart(product);
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }
}
