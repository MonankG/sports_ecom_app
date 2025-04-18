import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_app/controllers/wishlist_controller.dart';
import 'package:sample_app/models/product_model.dart';
import 'package:sample_app/controllers/cart_controller.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:sample_app/views/product/product_details.dart';

class ProductHorizontalCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onRemove;
  final VoidCallback? onWishlistTap;
  final bool showQuantityControls;
  final bool showRemoveButton;

  const ProductHorizontalCard({
    Key? key,
    required this.product,
    this.onRemove,
    this.onWishlistTap,
    this.showQuantityControls = true,
    this.showRemoveButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    // Check if product id is valid - if not, don't render card
    if (product.id == null || product.id.isEmpty) {
      return SizedBox.shrink();
    }

    return Material(
      // Wrap with Material for proper touch feedback
      color: Colors.transparent,
      child: InkWell(
        // Use InkWell instead of GestureDetector for touch effect
        onTap: () {
          print('Card tapped for product: ${product.name}');
          // Make sure to use proper import for ProductDetails
          // Try both naming variations
          try {
            Get.to(() => ProductDetails(product: product) ,preventDuplicates: true, transition: Transition.noTransition);
          } catch (e) {
            print('Error navigating: $e');
            // Try alternate product detail page name if it exists
            try {
              Get.to(() => ProductDetails(product: product),
                  preventDuplicates: true, transition: Transition.noTransition);
            } catch (e2) {
              print('Error on second attempt: $e2');
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: _buildProductImage(),
                ),
              ),

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Category
                      Text(
                        product.category,
                        style: GoogleFonts.lexend(
                          color: Colors.grey[600],
                          fontSize: 13.0,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Price and Wishlist
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price display
                          Text(
                            '\₹${product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.lexend(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          // Wishlist icon
                          if (onWishlistTap != null)
                            GestureDetector(
                              onTap: onWishlistTap,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[100],
                                ),
                                child: Obx(() {
                                  final WishlistController wishlistController =
                                      Get.find<WishlistController>();
                                  final isInWishlist = wishlistController
                                      .isInWishlist(product.id);
                                  return Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isInWishlist ? Colors.red : Colors.grey,
                                    size: 18,
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),

                      // Stock status
                      if (product.stockQuantity <= 5)
                        Text(
                          product.stockQuantity > 0
                              ? 'Low Stock'
                              : 'Out of Stock',
                          style: GoogleFonts.lexend(
                            color: product.stockQuantity > 0
                                ? Colors.orange
                                : Colors.red,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      // Quantity controls or Remove button
                      if (showQuantityControls && product.stockQuantity > 0)
                        Obx(() {
                          final quantity =
                              cartController.getQuantity(product.id);
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  cartController.decreaseQuantity(product.id);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$quantity',
                                  style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  cartController.addToCart(product);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),

              // Optional Remove Button
              if (showRemoveButton)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Completely rewritten image loading logic
  Widget _buildProductImage() {
    // First handle null/empty case
    if (product.imageUrl == null || product.imageUrl.isEmpty) {
      return _buildPlaceholder('No image');
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
            return _buildPlaceholder('Asset error');
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
              return _buildPlaceholder('Format error');
            },
          );
        } catch (e) {
          print('Base64 decode error: $e for $imageUrl');
          return _buildPlaceholder('Decode error');
        }
      }

      // Handle network images (http/https URLs)
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, e, __) {
            print('Network image error: $e for $imageUrl');
            return _buildPlaceholder('Network error');
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
            return _buildPlaceholder('URL error');
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator(strokeWidth: 2.0));
          },
        );
      }

      // Fallback for any other format
      return _buildPlaceholder('Invalid format');
    } catch (e) {
      print('Unexpected image error: $e for $imageUrl');
      return _buildPlaceholder('Error');
    }
  }

  // Simple placeholder with message
  Widget _buildPlaceholder([String? message]) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 30, color: Colors.grey[400]),
            if (message != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
