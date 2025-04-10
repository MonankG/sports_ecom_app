import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch products from Firestore
  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Products').get();
      return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }
}
