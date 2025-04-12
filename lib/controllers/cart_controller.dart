import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/cart_item.dart';
import 'auth_controller.dart';

class CartItem {
  final Product product;
  final RxInt quantity;

  CartItem({
    required this.product,
    int quantity = 1,
  }) : quantity = quantity.obs;
}

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CartItem> items = <CartItem>[].obs;
  final RxBool isLoading = false.obs;

  // Get auth controller
  final AuthController _authController = Get.find<AuthController>();

  // Shipping options
  final RxDouble shippingCost = 5.99.obs;
  final RxDouble taxRate = 0.08.obs; // 8% tax rate

  @override
  void onInit() {
    super.onInit();
    // Load cart when user changes
    ever(_authController.firebaseUser, (_) {
      _loadCartFromFirebase();
    });
  }

  // Load cart from Firebase
  Future<void> _loadCartFromFirebase() async {
    if (_authController.firebaseUser.value == null) {
      items.clear();
      return;
    }

    try {
      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      DocumentSnapshot cartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('items')
          .get();

      if (!cartDoc.exists) {
        items.clear();
        return;
      }

      Map<String, dynamic> data = cartDoc.data() as Map<String, dynamic>;
      List<dynamic> itemsData = data['items'] ?? [];

      items.clear();

      for (var item in itemsData) {
        DocumentSnapshot productDoc = await _firestore
            .collection('Products')
            .doc(item['productId'])
            .get();

        if (productDoc.exists) {
          Product product = Product.fromFirestore(
            productDoc.data() as Map<String, dynamic>,
            productDoc.id,
          );

          items.add(CartItem(
            product: product,
            quantity: item['quantity'] ?? 1,
          ));
        }
      }
    } catch (e) {
      print('Error loading cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save cart to Firebase
  Future<void> _saveCartToFirebase() async {
    if (_authController.firebaseUser.value == null) return;

    try {
      String userId = _authController.firebaseUser.value!.uid;

      List<Map<String, dynamic>> itemsData = items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity.value,
              })
          .toList();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('items')
          .set({
        'items': itemsData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Add a product to cart
  void addToCart(Product product) {
    // Check if product exists in cart
    final existingIndex =
        items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in cart, increase quantity
      final currentQuantity = items[existingIndex].quantity.value;
      if (currentQuantity < product.stockQuantity) {
        items[existingIndex].quantity.value++;
      }
    } else {
      // Add new product to cart
      items.add(CartItem(product: product));
    }

    _saveCartToFirebase();

    Get.snackbar(
      'Added to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Remove a product from cart
  void removeFromCart(String productId) {
    items.removeWhere((item) => item.product.id == productId);
    _saveCartToFirebase();
  }

  // Decrease quantity of a product
  void decreaseQuantity(String productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (items[index].quantity.value > 1) {
        items[index].quantity.value--;
        _saveCartToFirebase();
      } else {
        // Remove if quantity becomes 0
        removeFromCart(productId);
      }
    }
  }

  // Get quantity of a product
  int getQuantity(String productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? items[index].quantity.value : 0;
  }

  // Clear the entire cart
  void clearCart() {
    items.clear();
    _saveCartToFirebase();
  }

  // Calculate subtotal (before shipping and tax)
  double get subtotal {
    double total = 0;
    for (var item in items) {
      total += item.product.price * item.quantity.value;
    }
    return total;
  }

  // Calculate tax amount
  double get taxAmount {
    return subtotal * taxRate.value;
  }

  // Calculate total (including shipping and tax)
  double get total {
    return subtotal + shippingCost.value + taxAmount;
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  // Get total number of items in cart
  int get itemCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity.value;
    }
    return count;
  }
}
