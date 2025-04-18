import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:sample_app/views/home/homepage.dart';

class MyOrders extends StatelessWidget {
  const MyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "My Orders",
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: _buildOrdersList(),
    );
  }

  Widget _buildOrdersList() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24),
            Text(
              'Please login to view orders',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to login page
                Get.toNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Try to fetch orders from both locations
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchOrdersFromBothLocations(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading orders',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: GoogleFonts.lexend(
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 24),
                Text(
                  'No orders yet',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your order history will appear here',
                  style: GoogleFonts.lexend(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Try to find home controller and navigate to home tab
                    try {
                      final controller = Get.find<
                          Homepage>(); // Replace with your controller name
                      controller.changeIndex(0); // Navigate to home tab
                      Navigator.pop(context);
                    } catch (e) {
                      // Fallback navigation
                      Get.offAllNamed('/');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Shopping',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Sort orders by date, newest first
        orders.sort((a, b) {
          final aDate =
              (a.data() as Map<String, dynamic>)['orderDate'] as Timestamp;
          final bDate =
              (b.data() as Map<String, dynamic>)['orderDate'] as Timestamp;
          return bDate.compareTo(aDate);
        });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            return _buildOrderCard(context, order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final orderDate = (order['orderDate'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(orderDate);

    final orderItems = (order['orderItems'] as List<dynamic>);
    final itemCount = orderItems.length;
    final total = order['total']?.toString() ?? '0.00';
    final status = order['status'] ?? 'pending';
    final orderId = order['orderId'] ?? '';

    // Determine status color
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'processing':
      case 'shipped':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to order details screen
          Get.to(() => OrderDetailScreen(order: order));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${orderId.substring(4, 12)}',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.lexend(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                formattedDate,
                style: GoogleFonts.lexend(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  if (orderItems.isNotEmpty && orderItems[0]['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        orderItems[0]['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, _) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemCount == 1
                              ? orderItems[0]['productName']
                              : '${orderItems[0]['productName']} + ${itemCount - 1} more',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$itemCount item${itemCount > 1 ? 's' : ''}',
                          style: GoogleFonts.lexend(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹$total',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        order['paymentMethod'] ?? 'Cash on Delivery',
                        style: GoogleFonts.lexend(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _fetchOrdersFromBothLocations(
      String userId) async {
    List<QueryDocumentSnapshot> allOrders = [];

    // Try to fetch from user's Orders subcollection
    try {
      final userOrdersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .get();

      allOrders.addAll(userOrdersSnapshot.docs);
    } catch (e) {
      print('Error fetching from user Orders: $e');
    }

    // Also try to fetch from main Orders collection where userId matches
    try {
      final mainOrdersSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: userId)
          .get();

      // Check for duplicates before adding
      for (final doc in mainOrdersSnapshot.docs) {
        if (!allOrders.any((existing) => existing.id == doc.id)) {
          allOrders.add(doc);
        }
      }
    } catch (e) {
      print('Error fetching from main Orders: $e');
    }

    return allOrders;
  }
}

// Order Detail Screen
class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderDate = (order['orderDate'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(orderDate);
    final orderItems = order['orderItems'] as List<dynamic>;
    final shippingAddress = order['shippingAddress'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "Order Details",
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID:',
                        style: GoogleFonts.lexend(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        order['orderId'] ?? '',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order['status'] ?? 'pending'),
              ],
            ),

            SizedBox(height: 24),

            // Order Date
            Text(
              'Ordered on:',
              style: GoogleFonts.lexend(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: GoogleFonts.lexend(
                fontSize: 16,
              ),
            ),

            SizedBox(height: 24),

            // Shipping Address
            Text(
              'Shipping Address:',
              style: GoogleFonts.lexend(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: _buildAddressText(shippingAddress),
              ),
            ),

            SizedBox(height: 24),

            // Order Items
            Text(
              'Order Items:',
              style: GoogleFonts.lexend(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: orderItems.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final item = orderItems[index] as Map<String, dynamic>;
                return _buildOrderItemRow(item);
              },
            ),

            SizedBox(height: 24),

            // Order Summary
            Text(
              'Order Summary:',
              style: GoogleFonts.lexend(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', '₹${order['subtotal']}'),
                    SizedBox(height: 8),
                    _buildSummaryRow('Shipping', '₹${order['shipping']}'),
                    SizedBox(height: 8),
                    _buildSummaryRow('Tax', '₹${order['tax']}'),
                    Divider(height: 24),
                    _buildSummaryRow('Total', '₹${order['total']}',
                        isTotal: true),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            size: 18, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Payment Method: ${order['paymentMethod'] ?? 'Cash on Delivery'}',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Support section
            Center(
              child: Column(
                children: [
                  Text(
                    'Need help with your order?',
                    style: GoogleFonts.lexend(
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton.icon(
                    icon: Icon(Icons.support_agent, color: Colors.blue[800]),
                    label: Text(
                      'Contact Support',
                      style: GoogleFonts.lexend(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Implement contact support functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Support contact feature coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'processing':
      case 'shipped':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.lexend(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAddressText(Map<String, dynamic>? address) {
    if (address == null || address.isEmpty || address.containsKey('note')) {
      return Text(
        'No address provided',
        style: GoogleFonts.lexend(
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      );
    }

    // Extract address components
    final name = address['name'] ?? '';
    final line1 = address['addressLine1'] ?? address['line1'] ?? '';
    final line2 = address['addressLine2'] ?? address['line2'] ?? '';
    final city = address['city'] ?? '';
    final state = address['state'] ?? '';
    final pincode = address['pincode'] ?? address['zipCode'] ?? '';
    final phone = address['phone'] ?? address['phoneNumber'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(
            name,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: 4),
        Text(
          line1,
          style: GoogleFonts.lexend(),
        ),
        if (line2.isNotEmpty)
          Text(
            line2,
            style: GoogleFonts.lexend(),
          ),
        Text(
          '$city, $state $pincode',
          style: GoogleFonts.lexend(),
        ),
        SizedBox(height: 4),
        if (phone.isNotEmpty)
          Text(
            'Phone: $phone',
            style: GoogleFonts.lexend(
              color: Colors.grey[700],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 1;
    final price = item['price'] ?? 0.0;
    final totalPrice = item['totalPrice'] ?? (price * quantity);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item['image'] != null
              ? Image.network(
                  item['image'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, _) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),
        SizedBox(width: 16),

        // Product details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['productName'] ?? 'Product',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Price: ₹$price',
                style: GoogleFonts.lexend(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Quantity: $quantity',
                style: GoogleFonts.lexend(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Total price
        Text(
          '₹$totalPrice',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            color: isTotal ? Colors.black : Colors.grey[700],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.blue[800] : Colors.black,
          ),
        ),
      ],
    );
  }
}
