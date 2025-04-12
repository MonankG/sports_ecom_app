import 'package:sample_app/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  // Create a copy with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
