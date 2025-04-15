import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/product_model.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

class WishlistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Product> items = <Product>[].obs;
  final RxBool isLoading = false.obs;

  // Get auth controller
  final AuthController _authController = Get.find<AuthController>();
  late CartController _cartController;

  // Stream subscription for real-time wishlist updates
  StreamSubscription<DocumentSnapshot>? _wishlistSubscription;
  // Document ID for the user's wishlist
  String? _wishlistDocId;

  @override
  void onInit() {
    super.onInit();
    _cartController = Get.find<CartController>();

    // Listen for user changes
    ever(_authController.firebaseUser, (_) {
      _fetchOrCreateWishlist();
    });
  }

  @override
  void onClose() {
    try {
      if (_wishlistSubscription != null) {
        _wishlistSubscription!.cancel().then((_) {
          print('Wishlist subscription cancelled successfully');
        }).catchError((error) {
          print('Error cancelling wishlist subscription: $error');
        });
      }
    } catch (e) {
      print('Error during wishlist controller cleanup: $e');
    } finally {
      _wishlistSubscription = null;
    }
    super.onClose();
  }

  // Fetch existing wishlist or create a new one
  Future<void> _fetchOrCreateWishlist() async {
    // Cancel any existing subscription
    _wishlistSubscription?.cancel();

    final user = _authController.firebaseUser.value;
    if (user == null) {
      print('Cannot fetch wishlist: User not logged in');
      items.clear();
      _wishlistDocId = null;
      return;
    }

    isLoading.value = true;
    String userId = user.uid;
    print('Fetching wishlist for user: $userId');

    try {
      // Try to find an existing wishlist for this user
      QuerySnapshot wishlistQuery = await _firestore
          .collection('Wishlist')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (wishlistQuery.docs.isNotEmpty) {
        // Existing wishlist found
        _wishlistDocId = wishlistQuery.docs.first.id;
        print('Found existing wishlist: $_wishlistDocId');
      } else {
        // Create a new wishlist for this user
        print('Creating new wishlist for user: $userId');

        // Use a document ID that includes the user ID to help with security rules
        String docId = 'wishlist_${userId}';
        _wishlistDocId = docId;

        await _firestore.collection('Wishlist').doc(docId).set({
          'userId': userId,
          'items': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Created new wishlist: $_wishlistDocId');
      }

      // Set up real-time listener for the wishlist
      _setupWishlistListener();
    } catch (e) {
      print('Error fetching/creating wishlist: $e');
      isLoading.value = false;
    }
  }

  // Set up real-time listener for wishlist updates
  void _setupWishlistListener() {
    if (_wishlistDocId == null) return;

    try {
      _wishlistSubscription = _firestore
          .collection('Wishlist')
          .doc(_wishlistDocId)
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
          List<Product> updatedItems = [];

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

              updatedItems.add(product);
            }
          }

          // Update items list with new data
          items.assignAll(updatedItems);
        } catch (e) {
          print('Error processing wishlist update: $e');
        } finally {
          isLoading.value = false;
        }
      }, onError: (error) {
        print('Error listening to wishlist changes: $error');
        isLoading.value = false;
      });
    } catch (e) {
      print('Error setting up wishlist listener: $e');
      isLoading.value = false;
    }
  }

  // Save wishlist to Firebase
  Future<void> _saveWishlistToFirebase() async {
    if (_authController.firebaseUser.value == null) {
      print('Cannot save wishlist: User not logged in');
      return;
    }

    if (_wishlistDocId == null) {
      print('Cannot save wishlist: No wishlist document ID');
      _fetchOrCreateWishlist().then((_) {
        _saveWishlistToFirebase();
      });
      return;
    }

    try {
      print(
          'Saving wishlist to Firebase: $_wishlistDocId with ${items.length} items');

      List<Map<String, dynamic>> itemsData = items
          .map((product) => {
                'productId': product.id,
              })
          .toList();

      await _firestore.collection('Wishlist').doc(_wishlistDocId).update({
        'items': itemsData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully saved wishlist to Firebase');
    } catch (e) {
      print('Error saving wishlist to Firebase: $e');

      // If the document doesn't exist, try to create it
      if (e is FirebaseException && e.code == 'not-found') {
        try {
          print('Attempting to create new wishlist document');
          String userId = _authController.firebaseUser.value!.uid;

          List<Map<String, dynamic>> itemsData = items
              .map((product) => {
                    'productId': product.id,
                  })
              .toList();

          await _firestore.collection('Wishlist').doc(_wishlistDocId).set({
            'userId': userId,
            'items': itemsData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print('Created new wishlist document successfully');
        } catch (innerError) {
          print('Error creating new wishlist document: $innerError');
        }
      }
    }
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return items.any((product) => product.id == productId);
  }

  // Make addToWishlist and removeFromWishlist return Future<void>
  Future<void> addToWishlist(Product product) async {
    if (!isInWishlist(product.id)) {
      items.add(product);
      await _saveWishlistToFirebase();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    items.removeWhere((product) => product.id == productId);
    await _saveWishlistToFirebase();
  }

  // Update toggleWishlist too
  Future<void> toggleWishlist(Product product) async {
    try {
      if (isInWishlist(product.id)) {
        await removeFromWishlist(product.id);
      } else {
        await addToWishlist(product);
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
    }
  }

  // Clear wishlist
  void clearWishlist() {
    items.clear();
    _saveWishlistToFirebase();
  }

  // Add all wishlist items to cart
  void addAllToCart() {
    for (var product in items) {
      _cartController.addToCart(product);
    }
  }
}
