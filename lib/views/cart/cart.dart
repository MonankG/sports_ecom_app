import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample_app/views/home/homepage.dart';
import 'package:sample_app/views/orders/my_orders.dart';
import '../../controllers/cart_controller.dart';
import '../cards/product_horizontal_card.dart';
import '../../models/product_model.dart';

class UserCart extends StatelessWidget {
  final HomepageController controller = Get.put(HomepageController());


  Future<void> _processOrder(
      BuildContext context, CartController cartController) async {
    // Check if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Processing your order...',
                  style: GoogleFonts.lexend(),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Check if cart is not empty
      if (cartController.items.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      // Prepare order items - FIX: Extract actual values from Rx objects
      final List<Map<String, dynamic>> orderItems =
          cartController.items.map((item) {
        // Fix the type check and conversion
        int quantity;
        if (item.quantity is RxInt) {
          quantity = (item.quantity as RxInt).value;
        } else if (item.quantity is int) {
          quantity = item.quantity as int;
        } else {
          quantity = 1; // Default fallback
        }

        return {
          'productId': item.product.id,
          'productName': item.product.name,
          'quantity': quantity,
          'price': item.product.price,
          'totalPrice': item.product.price * quantity,
          'image': item.product.imageUrl,
        };
      }).toList();

      // Get user address if available
      DocumentSnapshot? addressDoc;
      try {
        addressDoc = await FirebaseFirestore.instance
            .collection('Addresses')
            .doc(currentUser.uid)
            .get();
      } catch (e) {
        print('Error fetching address: $e');
      }

      // FIX: Don't try to fetch user details that have permission issues
      // Instead use data from Firebase Auth
      final userName = currentUser.displayName ?? 'User';

      // FIX: Convert Rx values to primitives
      double subtotal;
      if (cartController.subtotal is RxDouble) {
        subtotal = (cartController.subtotal as RxDouble).value;
      } else {
        subtotal = cartController.subtotal;
      }

      double shippingCost;
      if (cartController.shippingCost is RxDouble) {
        shippingCost = (cartController.shippingCost as RxDouble).value;
      } else {
        shippingCost = cartController.shippingCost as double;
      }

      double taxAmount;
      if (cartController.taxAmount is RxDouble) {
        taxAmount = (cartController.taxAmount as RxDouble).value;
      } else {
        taxAmount = cartController.taxAmount;
      }

      double total;
      if (cartController.total is RxDouble) {
        total = (cartController.total as RxDouble).value;
      } else {
        total = cartController.total;
      }

      // Create order data
      final Map<String, dynamic> orderData = {
        'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'userId': currentUser.uid,
        'userName': userName,
        'userEmail': currentUser.email,
        'orderItems': orderItems,
        'orderDate': Timestamp.now(),
        'status': 'pending',
        'subtotal': subtotal,
        'shipping': shippingCost,
        'tax': taxAmount,
        'total': total,
        'paymentMethod': 'Cash on Delivery',
        'paymentStatus': 'pending',
      };

      // Add shipping address safely
      if (addressDoc != null && addressDoc.exists) {
        final addressData = addressDoc.data() as Map<String, dynamic>;
        if (addressData.containsKey('addressList') &&
            addressData['addressList'] is List &&
            (addressData['addressList'] as List).isNotEmpty) {
          orderData['shippingAddress'] = addressData['addressList'][0];
        } else {
          orderData['shippingAddress'] = {'note': 'No address provided'};
        }
      } else {
        orderData['shippingAddress'] = {'note': 'No address provided'};
      }

      // FIX: Save directly to Orders collection first (which should have permissive rules)
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderData['orderId'])
          .set(orderData);

      // Then try to save to user's collection, but don't fail if it doesn't work
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Orders')
            .doc(orderData['orderId'])
            .set(orderData);
      } catch (e) {
        // Just log this error but continue - the order is still saved in Orders collection
        print('Error saving to user Orders: $e');
      }

      // Clear cart after successful order
      cartController.clearCart();

      // Close loading dialog if context is still valid
      if (context.mounted) {
        Navigator.pop(context);

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Order Placed Successfully',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Thank you for your order!',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your order ID is: ${orderData['orderId']}',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We will process it soon.',
                    style: GoogleFonts.lexend(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.to(() => MyOrders()); // Navigate to My Orders page
                  },
                  child: Text(
                    'View My Orders',
                    style: GoogleFonts.lexend(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.changeIndex(1); // Navigate to Shop page
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error processing order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make sure CartController is registered
    final CartController cartController;
    if (Get.isRegistered<CartController>()) {
      cartController = Get.find<CartController>();
    } else {
      cartController = Get.put(CartController());
    }

    final HomepageController controller = Get.put(HomepageController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "Cart",
          style: GoogleFonts.lexend(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Clear Cart'),
                        onTap: () {
                          cartController.clearCart();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.bookmark_border),
                        title: Text('Save for Later'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Items saved for later')));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: Obx(() {
        if (cartController.items.isEmpty) {
          // Empty cart state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 24),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add items to get started',
                  style: GoogleFonts.lexend(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    controller.changeIndex(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Cart with items
        return Column(
          children: [
            // Cart items list
            Expanded(
              child: ListView.builder(
                itemCount: cartController.items.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final cartItem = cartController.items[index];
                  return ProductHorizontalCard(
                    product: cartItem.product,
                    showRemoveButton: true,
                    onRemove: () {
                      cartController.removeFromCart(cartItem.product.id);
                    },
                  );
                },
              ),
            ),

            // Order summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: GoogleFonts.lexend(),
                      ),
                      Text(
                        '\₹${cartController.subtotal.toStringAsFixed(2)}',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Shipping
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping:',
                        style: GoogleFonts.lexend(),
                      ),
                      Text(
                        '\₹${cartController.shippingCost.toStringAsFixed(2)}',
                        style: GoogleFonts.lexend(),
                      ),
                    ],
                  ),

                  // Tax (optional)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tax:',
                        style: GoogleFonts.lexend(),
                      ),
                      Text(
                        '\₹${cartController.taxAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.lexend(),
                      ),
                    ],
                  ),

                  Divider(height: 24),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\₹${cartController.total.toStringAsFixed(2)}',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _processOrder(context, cartController);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
