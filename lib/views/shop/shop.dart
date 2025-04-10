import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class Shop extends StatelessWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Shop',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        leading: const Icon(Icons.search, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.shopping_cart, color: Colors.black),
          ),
        ],
      ),
      body: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tabs
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Bikes', 'Treadmills', 'Ellipticals']
                  .map((category) => GestureDetector(
                onTap: () => productController.setCategory(category),
                child: CategoryTab(
                  title: category,
                  selected: productController.selectedCategory.value == category,
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Sort By',
                style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          const SortOptions(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Filter By',
                style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          const FilterOptions(),
          Expanded(child: ProductList()),
        ],
      )),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String title;
  final bool selected;
  const CategoryTab({required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.blueGrey : Colors.grey,
            ),
          ),
        ),
        if (selected)
          Container(
            height: 3,
            width: 20,
            color: Colors.blueGrey,
          ),
      ],
    );
  }
}

class SortOptions extends StatelessWidget {
  const SortOptions();

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
  const RadioTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    return Obx(() => ListTile(
      title: Text(title, style: GoogleFonts.lexend()),
      trailing: Icon(
        controller.sortOption.value == value
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: Colors.blueGrey,
      ),
      onTap: () => controller.setSortOption(value),
    ));
  }
}

class FilterOptions extends StatelessWidget {
  const FilterOptions();

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8,
        children: priceRanges.entries.map((entry) {
          final isSelected = controller.selectedPrice.value == entry.value;
          return GestureDetector(
            onTap: () => controller.setPriceFilter(entry.value),
            child: Chip(
              backgroundColor: isSelected ? Colors.blueGrey : Colors.grey.shade200,
              label: Text(
                entry.key,
                style: GoogleFonts.lexend(color: isSelected ? Colors.white : Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (productController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final productList = productController.filteredProducts;
      if (productList.isEmpty) {
        return Center(child: Text("No products available"));
      }

      return ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return ProductItem(
            product: productList[index],
          );
        },
      );
    });
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(product.name, style: GoogleFonts.lexend(fontWeight: FontWeight.w500)),
        subtitle: Text('\$${product.price.toStringAsFixed(2)}',
            style: GoogleFonts.lexend(color: Colors.blueGrey)),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
