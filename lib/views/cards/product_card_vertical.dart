import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Fix this import path
import 'package:sample_app/views/product/product_details.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/product_model.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductVerticalCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onProductTap;

  const ProductVerticalCard({
    Key? key,
    required this.product,
    this.onWishlistTap,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final WishlistController wishlistController =
        Get.find<WishlistController>();

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetails(product: product) ,preventDuplicates: true, transition: Transition.noTransition);
      },
      child: Container(
        width: 160,
        height: 230, // Fixed height to prevent overflow
        margin: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 8), // Reduced vertical margin
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and Wishlist Button (fixed height)
              SizedBox(
                height: 120, // Fixed height for image section
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: _buildProductImage(),
                      ),
                    ),
                    // Wishlist button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: onWishlistTap,
                          child: Obx(() => Icon(
                                wishlistController.isInWishlist(product.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color:
                                    wishlistController.isInWishlist(product.id)
                                        ? Colors.red
                                        : Colors.black,
                              )),
                        ),
                      ),
                    ),
                    // Stock status indicator
                    if (product.stockQuantity <= 5 && product.stockQuantity > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3), // Smaller padding
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Low Stock',
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 9, // Smaller font
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (product.stockQuantity == 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3), // Smaller padding
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 9, // Smaller font
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Details (remaining height)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Smaller font
                        ),
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      // Category
                      Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 11, // Smaller font
                          color: Colors.grey[600],
                        ),
                      ),
                      // Spacer to push price and cart to bottom
                      Spacer(),
                      // Price and cart button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${product.price.toStringAsFixed(2)}",
                            style: GoogleFonts.lexend(
                              fontSize: 14, // Smaller font
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          InkWell(
                            onTap: product.stockQuantity > 0
                                ? () {
                                    cartController.addToCart(product);
                                    Get.snackbar(
                                      'Added to Cart',
                                      '${product.name} added to your cart',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 2),
                                    );
                                  }
                                : null,
                            child: Container(
                              padding:
                                  const EdgeInsets.all(4), // Smaller padding
                              decoration: BoxDecoration(
                                color: product.stockQuantity > 0
                                    ? Colors.blueAccent
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 14, // Smaller icon
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build product image with error handling
  Widget _buildProductImage() {
    // First handle null/empty case
    if (product.imageUrl == null || product.imageUrl.isEmpty) {
      return _buildPlaceholderImage('No image');
    }

    String imageUrl = product.imageUrl;

    try {
      // Handle asset images
      if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, e, __) {
            print('Asset image error: $e for $imageUrl');
            return _buildPlaceholderImage('Asset error');
          },
        );
      }

      // Handle base64 encoded images
      if (imageUrl.contains('base64')) {
        try {
          // Clean the base64 string
          String cleanBase64 = imageUrl;

          // Remove data URI prefix if present
          if (cleanBase64.contains(',')) {
            cleanBase64 = cleanBase64.split(',').last;
          }

          // Remove any prefix with base64
          cleanBase64 = cleanBase64
              .replaceAll('data:image/jpeg;base64,', '')
              .replaceAll('data:image/png;base64,', '')
              .replaceAll('data:image;base64,', '');

          // Remove whitespace
          cleanBase64 = cleanBase64.trim();

          // Decode
          final Uint8List bytes = base64Decode(cleanBase64);

          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, e, __) {
              print('Base64 render error: $e');
              return _buildPlaceholderImage('Format error');
            },
          );
        } catch (e) {
          print('Base64 decode error: $e for $imageUrl');
          return _buildPlaceholderImage('Decode error');
        }
      }

      // Handle network images (http/https URLs)
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, e, __) {
            print('Network image error: $e for $imageUrl');
            return _buildPlaceholderImage('Network error');
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2.0,
              ),
            );
          },
        );
      }

      // Try to construct a URL if not already a valid URL
      if (!imageUrl.startsWith('http')) {
        final fixedUrl = 'https://$imageUrl';
        print('Trying fixed URL: $fixedUrl');

        return Image.network(
          fixedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, e, __) {
            print('Fixed URL image error: $e for $fixedUrl');
            return _buildPlaceholderImage('URL error');
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator(strokeWidth: 2.0));
          },
        );
      }

      // Fallback for any other format
      return _buildPlaceholderImage('Invalid format');
    } catch (e) {
      print('Unexpected image error: $e for $imageUrl');
      return _buildPlaceholderImage('Error');
    }
  }

  // Helper method for placeholder images
  Widget _buildPlaceholderImage(String message) {
    return Container(
      height: 120, // Fixed height
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported,
              size: 32, color: Colors.grey[400]), // Smaller icon
          SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
                fontSize: 10, color: Colors.grey[600]), // Smaller font
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
