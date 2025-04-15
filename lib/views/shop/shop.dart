import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import './product_item.dart';
import '../../views/cart/cart.dart'; // Import your cart screen

class Shop extends StatelessWidget {
  Shop({super.key});

  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool _isListening = false.obs;

  @override
  Widget build(BuildContext context) {
    // Make sure ProductController is registered only once
    final ProductController productController;
    if (Get.isRegistered<ProductController>()) {
      productController = Get.find<ProductController>();
    } else {
      productController = Get.put(ProductController());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          if (productController.isSearching.value) {
            return TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: InputBorder.none,
                hintStyle: GoogleFonts.lexend(color: Colors.grey),
              ),
              style: GoogleFonts.lexend(color: Colors.black),
              onChanged: (value) {
                print('Search query changed: $value');
                productController.updateSearchQuery(value);
              },
            );
          } else {
            return Text(
              'Shop',
              style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold, color: Colors.black),
            );
          }
        }),
        centerTitle: true,
        leading: IconButton(
          icon: Obx(() => Icon(
                productController.isSearching.value
                    ? Icons.arrow_back
                    : Icons.search,
                color: Colors.black,
              )),
          onPressed: () {
            print('Search toggle pressed');
            productController.toggleSearch();
          },
        ),
        actions: [
          Obx(() {
            // Show clear button when searching with text entered
            if (productController.isSearching.value &&
                productController.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  print('Clear search pressed');
                  productController.clearSearch();
                },
              );
            }
            // Show cart button when not searching
            if (!productController.isSearching.value) {
              return IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  try {
                    Get.to(() => UserCart());
                  } catch (e) {
                    print('Error navigating to cart: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cart coming soon!')));
                  }
                },
              );
            }
            return SizedBox.shrink(); // Empty widget when searching
          }),
        ],
      ),
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      'All',
                      'Bikes',
                      'Treadmills',
                      'Ellipticals',
                      'Weights',
                      'Accessories'
                    ]
                        .map((category) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: GestureDetector(
                                onTap: () {
                                  print('Category selected: $category');
                                  productController.setCategory(category);
                                },
                                child: CategoryTab(
                                  title: category,
                                  selected: productController
                                          .selectedCategory.value ==
                                      category,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

              // Show search history when searching with empty query
              Obx(() {
                if (productController.isSearching.value &&
                    productController.searchQuery.value.isEmpty) {
                  return Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Recent Searches',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        // You would typically load these from storage
                        _buildSearchHistoryItem('Bikes'),
                        _buildSearchHistoryItem('Running shoes'),
                        _buildSearchHistoryItem('Yoga mat'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Popular Searches',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        _buildSearchHistoryItem('Treadmill'),
                        _buildSearchHistoryItem('Weights'),
                        _buildSearchHistoryItem('Fitness tracker'),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 16),
                  children: [
                    // Filter Section (hide when searching)
                    if (!productController.isSearching.value ||
                        productController.searchQuery.value.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sort By',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                  fontSize: 16,
                                )),
                            const SortOptions(),
                            const SizedBox(height: 16),
                            Text('Filter By Price',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                  fontSize: 16,
                                )),
                            const SizedBox(height: 8),
                            const FilterOptions(),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Products Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Obx(() {
                        final count = productController.filteredProducts.length;
                        String countText =
                            'Showing $count product${count != 1 ? 's' : ''}';

                        // Add search context if searching
                        if (productController.searchQuery.value.isNotEmpty) {
                          countText +=
                              ' for "${productController.searchQuery.value}"';
                        }

                        return Text(
                          countText,
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    // Product List
                    ProductList(),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  // Helper method for search history items
  Widget _buildSearchHistoryItem(String query) {
    return InkWell(
      onTap: () {
        final productController = Get.find<ProductController>();
        print('Search history item tapped: $query');
        productController.updateSearchQuery(query);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.history, size: 16, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              query,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Icon(Icons.north_west, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening.value = false;
        }
      },
      onError: (error) {
        _isListening.value = false;
        print('Speech recognition error: $error');
      },
    );

    if (available) {
      _isListening.value = true;
      _speech.listen(
        onResult: (result) {
          final productController = Get.find<ProductController>();
          productController.updateSearchQuery(result.recognizedWords);
        },
      );
    } else {
      print('Speech recognition not available');
    }
  }
}

class CategoryTab extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryTab({Key? key, required this.title, this.selected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? Colors.blue[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.blue[800] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

class SortOptions extends StatelessWidget {
  const SortOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    return Column(
      children: [
        RadioTile(title: 'Featured', value: 'Featured'),
        RadioTile(title: 'Price: Low to High', value: 'LowToHigh'),
        RadioTile(title: 'Price: High to Low', value: 'HighToLow'),
      ],
    );
  }
}

class RadioTile extends StatelessWidget {
  final String title;
  final String value;

  const RadioTile({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    return Obx(() => InkWell(
          onTap: () => controller.setSortOption(value),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  controller.sortOption.value == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: controller.sortOption.value == value
                      ? Colors.blue[800]
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: GoogleFonts.lexend(
                      color: controller.sortOption.value == value
                          ? Colors.blue[800]
                          : Colors.black,
                      fontWeight: controller.sortOption.value == value
                          ? FontWeight.w600
                          : FontWeight.normal,
                    )),
              ],
            ),
          ),
        ));
  }
}

class FilterOptions extends StatelessWidget {
  const FilterOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    final priceRanges = {
      'Under \$500': 500.0,
      'Under \$1000': 1000.0,
      'Under \$2000': 2000.0,
      'Under \$3000': 3000.0,
      'Over \$3000': 3001.0,
    };

    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: priceRanges.entries.map((entry) {
            final isSelected = controller.selectedPrice.value == entry.value;
            return GestureDetector(
              onTap: () => controller.setPriceFilter(entry.value),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.key,
                  style: GoogleFonts.lexend(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

class ProductList extends StatelessWidget {
  ProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Obx(() {
      if (productController.isLoading.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final productList = productController.filteredProducts;

      if (productController.isSearching.value &&
          productController.searchQuery.value.isNotEmpty) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.blue[800]),
                  SizedBox(width: 12),
                  Text(
                    'Searching for "${productController.searchQuery.value}"',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[800],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[800]!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (productList.isEmpty)
              // Your existing empty state widget
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (productController.searchQuery.value.isNotEmpty) {
                          return Text(
                            "No results found for \"${productController.searchQuery.value}\"",
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return Text(
                            "No products match your criteria",
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          );
                        }
                      }),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          productController.clearSearch();
                          productController.setCategory('All');
                          productController.setSortOption('Featured');
                          productController.setPriceFilter(0.0);
                        },
                        child: Text('Clear All Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Your existing list view builder
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return ProductItem(
                    product: productList[index],
                  );
                },
              ),
          ],
        );
      }

      if (productList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Obx(() {
                  if (productController.searchQuery.value.isNotEmpty) {
                    return Text(
                      "No results found for \"${productController.searchQuery.value}\"",
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text(
                      "No products match your criteria",
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    );
                  }
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    productController.clearSearch();
                    productController.setCategory('All');
                    productController.setSortOption('Featured');
                    productController.setPriceFilter(0.0);
                  },
                  child: Text('Clear All Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: productList.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return ProductItem(
            product: productList[index],
          );
        },
      );
    });
  }
}
