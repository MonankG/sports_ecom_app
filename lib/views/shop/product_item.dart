import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../views/product/product_details.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to product details
          try {
            Get.to(() => ProductDetails(product: product));
          } catch (e) {
            print('Error navigating to product details: $e');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildProductImage(),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: GoogleFonts.lexend(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.lexend(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (product.stockQuantity <= 5)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.stockQuantity > 0
                                  ? Colors.orange
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.stockQuantity > 0
                                  ? 'Low Stock'
                                  : 'Out of Stock',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    String imageUrl = product.imageUrl;

    // Handle base64 images
    if (imageUrl.contains('base64')) {
      try {
        String base64Data;
        if (imageUrl.contains(',')) {
          base64Data = imageUrl.split(',').last;
        } else {
          base64Data = imageUrl.replaceAll('data:image/jpeg;base64,', '');
        }

        base64Data = base64Data.trim();
        final bytes = base64Decode(base64Data);

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    // Handle asset images
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    // Handle network images
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child:
            Icon(Icons.image_not_supported, size: 24, color: Colors.grey[400]),
      ),
    );
  }
}
