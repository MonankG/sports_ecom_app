import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/product_model.dart';
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

  // Stream subscription for real-time cart updates
  StreamSubscription<DocumentSnapshot>? _cartSubscription;
  // Document ID for the user's cart
  String? _cartDocId;

  @override
  void onInit() {
    super.onInit();
    // Listen for user changes
    ever(_authController.firebaseUser, (_) {
      _fetchOrCreateCart();
    });
  }

  @override
  void onClose() {
    // Cancel subscription when controller is closed
    _cartSubscription?.cancel();
    super.onClose();
  }

  // Fetch existing cart or create a new one
  Future<void> _fetchOrCreateCart() async {
    // Cancel any existing subscription
    _cartSubscription?.cancel();

    final user = _authController.firebaseUser.value;
    if (user == null) {
      print('Cannot fetch cart: User not logged in');
      items.clear();
      _cartDocId = null;
      return;
    }

    isLoading.value = true;
    String userId = user.uid;
    print('Fetching cart for user: $userId');

    try {
      // Try to find an existing cart for this user
      QuerySnapshot cartQuery = await _firestore
          .collection('Cart')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (cartQuery.docs.isNotEmpty) {
        // Existing cart found
        _cartDocId = cartQuery.docs.first.id;
        print('Found existing cart: $_cartDocId');
      } else {
        // Create a new cart for this user
        print('Creating new cart for user: $userId');

        // First, create a document with a generated ID, which should be allowed
        // since it's a transaction with no document yet to check against
        DocumentReference docRef = _firestore.collection('Cart').doc();
        _cartDocId = docRef.id;

        // Then set the data with the document ID we now know
        await docRef.set({
          'userId': userId,
          'items': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Created new cart: $_cartDocId');
      }

      // Set up real-time listener for the cart
      _setupCartListener();
    } catch (e) {
      print('Error fetching/creating cart: $e');
      isLoading.value = false;
    }
  }

  // Set up real-time listener for cart updates
  void _setupCartListener() {
    if (_cartDocId == null) return;

    _cartSubscription = _firestore
        .collection('Cart')
        .doc(_cartDocId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        items.clear();
        isLoading.value = false;
        return;
      }

      try {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> itemsData = data['items'] ?? [];

        // Create a temporary list to hold updated items
        List<CartItem> updatedItems = [];

        for (var item in itemsData) {
          // Get product details
          DocumentSnapshot productDoc = await _firestore
              .collection('Products')
              .doc(item['productId'])
              .get();

          if (productDoc.exists) {
            Product product = Product.fromFirestore(
              productDoc.data() as Map<String, dynamic>,
              productDoc.id,
            );

            updatedItems.add(CartItem(
              product: product,
              quantity: item['quantity'] ?? 1,
            ));
          }
        }

        // Update items list with new data
        items.assignAll(updatedItems);
      } catch (e) {
        print('Error processing cart update: $e');
      } finally {
        isLoading.value = false;
      }
    }, onError: (error) {
      print('Error listening to cart changes: $error');
      isLoading.value = false;
    });
  }

  // Save cart to Firebase
  Future<void> _saveCartToFirebase() async {
    if (_authController.firebaseUser.value == null) {
      print('Cannot save cart: User not logged in');
      return;
    }

    print('Current user: ${_authController.firebaseUser.value!.uid}');

    try {
      print('Saving cart to Firebase: $_cartDocId with ${items.length} items');

      List<Map<String, dynamic>> itemsData = items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity.value,
              })
          .toList();

      await _firestore.collection('Cart').doc(_cartDocId).update({
        'items': itemsData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully saved cart to Firebase');
    } catch (e) {
      print('Error saving cart to Firebase: $e');

      // If the document doesn't exist, try to create it
      if (e is FirebaseException && e.code == 'not-found') {
        try {
          print('Attempting to create new cart document');
          String userId = _authController.firebaseUser.value!.uid;

          List<Map<String, dynamic>> itemsData = items
              .map((item) => {
                    'productId': item.product.id,
                    'quantity': item.quantity.value,
                  })
              .toList();

          await _firestore.collection('Cart').doc(_cartDocId).set({
            'userId': userId,
            'items': itemsData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print('Created new cart document successfully');
        } catch (innerError) {
          print('Error creating new cart document: $innerError');
        }
      }
    }
  }

  // Add item to cart
  void addToCart(Product product) {
    int index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Product already in cart, increase quantity
      items[index].quantity.value++;
    } else {
      // Add new product to cart
      items.add(CartItem(product: product));
    }

    // Ensure we have a cart document ID before saving
    if (_cartDocId == null) {
      // Create a cart first, then save
      _fetchOrCreateCart().then((_) {
        _saveCartToFirebase();
      });
    } else {
      // Save to Firebase directly
      _saveCartToFirebase();
    }

    // Print for debugging
    print(
        'Added ${product.name} to cart. Cart has ${items.length} items. CartID: $_cartDocId');
  }

  // Remove item from cart
  void removeFromCart(String productId) {
    items.removeWhere((item) => item.product.id == productId);
    _saveCartToFirebase();
  }

  // Decrease quantity
  void decreaseQuantity(String productId) {
    int index = items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      if (items[index].quantity.value > 1) {
        items[index].quantity.value--;
      } else {
        items.removeAt(index);
      }
      _saveCartToFirebase();
    }
  }

  // Clear cart
  void clearCart() {
    items.clear();
    _saveCartToFirebase();
  }

  // Calculate subtotal
  double get subtotal {
    return items.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity.value));
  }

  // Calculate tax
  double get tax {
    return subtotal * taxRate.value;
  }

  // Calculate total
  double get total {
    return subtotal + tax + shippingCost.value;
  }

  // Get total items count
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity.value);
  }

  // Add this method to your CartController class
  int getQuantity(String productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return 0;
    return items[index].quantity.value;
  }

  // Add this getter to your CartController class
  double get taxAmount {
    return subtotal * taxRate.value;
  }

  // Add this method to your CartController class
  bool isInCart(String productId) {
    return items.any((item) => item.product.id == productId);
  }
}
