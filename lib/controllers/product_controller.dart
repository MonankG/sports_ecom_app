import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var isLoading = false.obs;

  // Filters
  var selectedCategory = 'All'.obs;
  var sortOption = 'Featured'.obs;
  var selectedPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      products.value = await _productService.fetchProducts();
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  // Filter by category
  void setCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  // Sort option (e.g., Featured, Newest, LowToHigh, HighToLow)
  void setSortOption(String option) {
    sortOption.value = option;
    applyFilters();
  }

  // Price filter
  void setPriceFilter(double price) {
    selectedPrice.value = price;
    applyFilters();
  }

  // Apply all filters and sorting
  void applyFilters() {
    List<Product> tempList = [...products];

    // Filter by category
    if (selectedCategory.value != 'All') {
      tempList = tempList.where((p) => p.category == selectedCategory.value).toList();
    }

    // Filter by price
    if (selectedPrice.value > 0 && selectedPrice.value <= 3000) {
      tempList = tempList.where((p) => p.price <= selectedPrice.value).toList();
    } else if (selectedPrice.value > 3000) {
      tempList = tempList.where((p) => p.price > 3000).toList();
    }

    // Sort logic
    switch (sortOption.value) {
      case 'LowToHigh':
        tempList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'HighToLow':
        tempList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Featured':
      default:
      // Leave as-is for Featured (or apply your own logic)
        break;
    }

    filteredProducts.value = tempList;
  }
}
