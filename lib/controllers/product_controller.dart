import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'dart:async';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();
  Timer? _debounce;

  // Observable properties
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString sortOption = 'Featured'.obs;
  final RxDouble selectedPrice = 0.0.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // Fetch all products
  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      var productsList = await _productService.fetchProducts();
      products.value = productsList;
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading(false);
    }
  }

  // Set category filter
  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Set sorting option
  void setSortOption(String option) {
    sortOption.value = option;
  }

  // Set price filter
  void setPriceFilter(double price) {
    if (selectedPrice.value == price) {
      // Toggle off if already selected
      selectedPrice.value = 0.0;
    } else {
      selectedPrice.value = price;
    }
  }

  // Update your search query
  void updateSearchQuery(String query) {
    print('Updating search query to: $query');
    searchQuery.value = query;
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
  }

  // Toggle search state
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }

  // Get filtered and sorted products
  List<Product> get filteredProducts {
    // Start with all products
    List<Product> result = List.from(products);

    // Apply search filter if we have a search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      print('Filtering by search: "$query"');
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false))
          .toList();
      print('Search results count: ${result.length}');
    }

    // Apply category filter
    if (selectedCategory.value != 'All') {
      result = result
          .where((p) =>
              p.category.toLowerCase() == selectedCategory.value.toLowerCase())
          .toList();
    }

    // Apply price filter
    if (selectedPrice.value > 0) {
      if (selectedPrice.value == 3001.0) {
        // "Over $3000"
        result = result.where((p) => p.price >= 3000).toList();
      } else {
        // "Under $X"
        result = result.where((p) => p.price <= selectedPrice.value).toList();
      }
    }

    // Apply sorting
    switch (sortOption.value) {
      case 'LowToHigh':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'HighToLow':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Featured':
      default:
        // Sort by featured first, then by newest
        result.sort((a, b) {
          if (a.featured && !b.featured) return -1;
          if (!a.featured && b.featured) return 1;

          // If both have same featured status, sort by date
          if (a.dateAdded != null && b.dateAdded != null) {
            return b.dateAdded!.compareTo(a.dateAdded!);
          }
          return 0;
        });
    }

    return result;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
