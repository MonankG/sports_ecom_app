import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts() async {
    try {
      // Get products from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      // Convert to list of Products
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          stockQuantity: data['stockQuantity'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          featured: data['featured'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Products')
          .where('category', isEqualTo: category)
          .get();

      List<Product> products = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Product product = Product.fromFirestore(data, doc.id);
          products.add(product);
        } catch (e) {
          print(
              'Error processing product in category $category, document ${doc.id}: $e');
          continue;
        }
      }

      return products;
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  // Fetch product by ID
  Future<Product?> fetchProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Products').doc(productId).get();

      if (doc.exists) {
        try {
          return Product.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          print('Error processing product document $productId: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching product by ID: $e');
      return null;
    }
  }

  // Fetch featured products
  Future<List<Product>> fetchFeaturedProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Products')
          .where('featured', isEqualTo: true)
          .limit(5)
          .get();

      List<Product> products = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Product product = Product.fromFirestore(data, doc.id);
          products.add(product);
        } catch (e) {
          print('Error processing featured product document ${doc.id}: $e');
          continue;
        }
      }

      // If no featured products found, get latest products
      if (products.isEmpty) {
        querySnapshot = await _firestore
            .collection('Products')
            .orderBy('date_added', descending: true)
            .limit(5)
            .get();

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Product product = Product.fromFirestore(data, doc.id);
            products.add(product);
          } catch (e) {
            print('Error processing latest product document ${doc.id}: $e');
            continue;
          }
        }
      }

      return products;
    } catch (e) {
      print('Error fetching featured products: $e');
      return [];
    }
  }
}
