import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_app/controllers/cart_controller.dart';
import 'package:sample_app/controllers/wishlist_controller.dart';
import 'package:sample_app/models/product_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductDetails extends StatelessWidget {
  final Product product;
  final CartController cartController = Get.find<CartController>();
  final WishlistController wishlistController = Get.find<WishlistController>();

  ProductDetails({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      // Safety check for product
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Product Not Found')),
        body: Center(child: Text('The product details could not be loaded.')),
      );
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Share Button
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {
              _shareProduct(context);
            },
          ),
          // Wishlist Button
          Obx(() {
            final isInWishlist = wishlistController.isInWishlist(product.id);
            return IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? Colors.red : Colors.black,
              ),
              onPressed: () {
                wishlistController.toggleWishlist(product);
                // Optional: Show a snackbar for feedback
                Get.snackbar(
                  isInWishlist ? 'Removed from Wishlist' : 'Added to Wishlist',
                  isInWishlist
                      ? '${product.name} removed from your wishlist'
                      : '${product.name} added to your wishlist',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: Duration(seconds: 2),
                );
              },
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Section
                  Stack(
                    children: [
                      // Image
                      Container(
                        height: screenHeight * 0.45,
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: _buildProductImage(),
                      ),

                      // Stock indicator
                      if (product.stockQuantity <= 5)
                        Positioned(
                          top: 16,
                          left:
                              16 + 50, // Offset to not overlap with back button
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: product.stockQuantity > 0
                                  ? Colors.orange
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              product.stockQuantity > 0
                                  ? 'Low Stock'
                                  : 'Out of Stock',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Product Info Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.lexend(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Product Name
                        Text(
                          product.name,
                          style: GoogleFonts.lexend(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price
                        Row(
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.lexend(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (product.stockQuantity > 0)
                              Text(
                                'In Stock',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        if (product.rating != null)
                          Row(
                            children: [
                              RatingBar.builder(
                                initialRating: product.rating ?? 0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                ignoreGestures: true,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${product.reviewCount ?? 0} reviews)',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Description Title
                        Text(
                          'Description',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          product.description ??
                              'No description available for this product.',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quantity Selector (if already in cart)
                        Obx(() {
                          try {
                            if (product != null &&
                                cartController != null &&
                                cartController.isInCart(product.id)) {
                              return _buildQuantitySelector();
                            }
                          } catch (e) {
                            print('Error checking if product is in cart: $e');
                          }
                          return const SizedBox.shrink();
                        }),

                        const SizedBox(height: 24),

                        // Specifications
                        Text(
                          'Specifications',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Specifications List
                        _buildSpecificationsItem('Category', product.category),
                        _buildSpecificationsItem(
                            'Stock', '${product.stockQuantity} units'),
                        if (product.dateAdded != null)
                          _buildSpecificationsItem(
                              'Added On', _formatDate(product.dateAdded!)),

                        const SizedBox(height: 24),

                        // Related Products would go here

                        // Bottom padding to ensure content isn't hidden behind action buttons
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Add to Cart / Buy Now Buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.stockQuantity > 0
                            ? () {
                                cartController.addToCart(product);
                                Get.snackbar(
                                  'Added to Cart',
                                  '${product.name} has been added to your cart',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          product.stockQuantity > 0
                              ? 'Add to Cart'
                              : 'Out of Stock',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Buy Now Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.stockQuantity > 0
                            ? () {
                                cartController.addToCart(product);
                                Get.toNamed(
                                    '/checkout'); // Assuming you have a checkout route
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: Colors.blue.shade800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Buy Now',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build product image with error handling
  Widget _buildProductImage() {
    String imageUrl = product.imageUrl;

    // Check if it's an asset image
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image in details: $error');
          return _buildErrorContainer('Asset not found');
        },
      );
    }

    // Check if it's a base64 image
    if (imageUrl.contains('base64')) {
      try {
        // Get the base64 data portion
        String base64Data;
        if (imageUrl.contains(',')) {
          base64Data = imageUrl.split(',').last;
        } else if (imageUrl.contains('base64,')) {
          base64Data = imageUrl.split('base64,').last;
        } else {
          base64Data = imageUrl;
        }

        // Clean up the base64 string - remove any whitespace or newlines
        base64Data = base64Data.trim().replaceAll('\n', '').replaceAll(' ', '');

        // Now decode and display
        try {
          Uint8List bytes = base64Decode(base64Data);
          return Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error rendering base64 image in details: $error');
              return _buildErrorContainer('Invalid image data');
            },
          );
        } catch (e) {
          print('Base64 decode error in details: $e');
          return _buildErrorContainer('Image decode error');
        }
      } catch (e) {
        print('Base64 handling error in details: $e');
        return _buildErrorContainer('Image format error');
      }
    }

    // Check if it's a valid URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Network image error in details: $error for URL: $imageUrl');
          return _buildErrorContainer('Image not available');
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.blue.shade800,
              ),
            ),
          );
        },
      );
    }

    // If we reach here, the URL is not in a recognized format
    print('Unrecognized image format in details: $imageUrl');
    return _buildErrorContainer('Invalid image format');
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                message,
                style: GoogleFonts.lexend(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build quantity selector
  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onTap: () => cartController.decreaseQuantity(product.id),
            ),
            const SizedBox(width: 16),
            Obx(() => Text(
                  '${cartController.getQuantity(product.id)}',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const SizedBox(width: 16),
            _buildQuantityButton(
              icon: Icons.add,
              onTap: () => cartController.addToCart(product),
              color: Colors.blue.shade800,
              iconColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build quantity buttons
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.black,
          size: 20,
        ),
      ),
    );
  }

  // Helper method to build specifications items
  Widget _buildSpecificationsItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.lexend(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.lexend(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to share product
  void _shareProduct(BuildContext context) {
    // Show a modal bottom sheet with sharing options
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this product',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing via Messages')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing via Email')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('More sharing options')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade800,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
