import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String description;
  final double price;
  final int stockQuantity;
  final bool featured;
  final DateTime? dateAdded;
  final double? rating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.featured = false,
    this.dateAdded,
    this.rating,
    this.reviewCount,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Just get the raw image URL - we'll process it when needed
    String rawImageUrl = data['product_image_url'] ?? '';

    return Product(
      id: documentId,
      name: data['product_name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'],
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0.0),
      imageUrl: rawImageUrl, // Store the original URL
      stockQuantity: data['stock_quantity'] ?? 0,
      featured: data['featured'] ?? false,
      dateAdded: data['date_added'] != null
          ? (data['date_added'] is DateTime
              ? data['date_added']
              : data['date_added'] is Timestamp
                  ? (data['date_added'] as Timestamp).toDate()
                  : DateTime.tryParse(data['date_added'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      rating:
          data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      reviewCount: data['review_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': name,
      'category': category,
      'description': description,
      'price': price,
      'product_image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'featured': featured,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  String get processedImageUrl {
    // Handle null or empty URL
    if (imageUrl.isEmpty) {
      return '';
    }

    // Already a proper URL with http/https
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Already a properly formatted base64 image
    if (imageUrl.startsWith('data:image')) {
      return imageUrl;
    }

    // Handle basic base64 cleaning
    if (imageUrl.contains('base64')) {
      // Don't modify the base64 string here - return as is
      // We'll handle the cleaning in the widget
      return imageUrl;
    }

    // If the image URL is a file path starting with assets/
    if (imageUrl.startsWith('assets/')) {
      return imageUrl; // Keep asset paths as they are
    }

    // If it starts with a slash, assume it's a relative URL
    if (imageUrl.startsWith('/')) {
      return 'https:$imageUrl'; // Add https: prefix
    }

    // For any other case, assume it's a domain without protocol
    if (!imageUrl.startsWith('www.') && !imageUrl.contains('.')) {
      // If it doesn't look like a domain, return as is
      return imageUrl;
    }

    // Add https:// prefix for relative URLs
    return 'https://$imageUrl';
  }
}
