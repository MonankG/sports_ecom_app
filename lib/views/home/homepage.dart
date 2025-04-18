import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sample_app/models/product_model.dart';
import 'package:sample_app/views/cards/product_card_vertical.dart';
import 'package:sample_app/views/auth/profile.dart';
import 'package:sample_app/views/cart/cart.dart';
import 'package:sample_app/views/shop/shop.dart';
import 'package:sample_app/views/wishlist/wishlist.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../controllers/product_controller.dart';

class HomepageController extends GetxController {
  final PageController pageController = PageController();
  final RxInt selectedIndex = 0.obs;

  final List<String> sliderImages = [
    "assets/images/Babolat-pkl.webp",
    "assets/images/Engage-1-pkll.webp",
    "assets/images/Joola-1-pkl.webp",
    "assets/images/Six-zero-pkl.webp",
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

class Homepage extends StatelessWidget {
  final HomepageController controller = Get.put(HomepageController());
  final ProductController productController = Get.put(ProductController());

  final List<Widget> pages = [
    HomeScreen(),
    Shop(),
    UserCart(),
    WishList(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.blueGrey,
          selectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.lexend(),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Shop'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: 'Favorites'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void changeIndex(int i) {}
}

class HomeScreen extends StatelessWidget {
  final HomepageController controller = Get.find();
  final ProductController productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(screenHeight * 0.13), // Reduced from 0.18
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: 8, // Use fixed padding
                bottom: 8, // Use fixed padding
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App title and search bar in a column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min, // Important to minimize height
                      children: [
                        Text(
                          "Gear Up",
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                24, // Fixed font size instead of responsive
                          ),
                        ),
                        SizedBox(height: 8), // Fixed height
                        Container(
                          height: 40, // Fixed height for search bar
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              hintText: "Search for gear",
                              hintStyle: GoogleFonts.lexend(
                                color: Colors.blueAccent,
                                fontSize: 14, // Smaller font size
                              ),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.blueAccent, size: 18),
                              suffixIcon: Obx(() =>
                                  productController.searchQuery.value.isNotEmpty
                                      ? IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.clear,
                                              color: Colors.blueAccent,
                                              size: 18),
                                          onPressed: () {
                                            productController.clearSearch();
                                          },
                                        )
                                      : SizedBox.shrink()),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.lexend(fontSize: 14),
                            onChanged: (value) {
                              productController.updateSearchQuery(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cart icon
                  IconButton(
                    onPressed: () {
                      try {
                        Get.to(() => UserCart());
                      } catch (e) {
                        print('Error navigating to cart: $e');
                      }
                    },
                    icon:
                        Icon(Icons.shopping_cart_outlined, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(), // Remove default padding
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        // Check if search is active
        bool isSearching = productController.searchQuery.value.isNotEmpty;

        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show banner and features when not searching
              if (!isSearching) ...[
                // Banner with overlay gradient
                Stack(
                  children: [
                    ClipRRect(
                      child: Image.network(
                        'https://storage.googleapis.com/a1aa/image/J3gJhvAMSuIrAEy3uRpnfvZd18Fyfg6_pt1agRjvQUY.jpg',
                        width: screenWidth,
                        height: screenHeight * 0.22,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      width: screenWidth,
                      height: screenHeight * 0.22,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score Big on Spring',
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'SHOP NOW',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Featured Products section
                Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Featured Products",
                        style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.changeIndex(1); // Navigate to Shop tab
                        },
                        child: Text(
                          "See All",
                          style: GoogleFonts.lexend(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.sliderImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              controller.sliderImages[index],
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  'Featured Product ${index + 1}',
                                  style: GoogleFonts.lexend(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SmoothPageIndicator(
                      controller: controller.pageController,
                      count: controller.sliderImages.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        activeDotColor: Colors.blue[700]!,
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "For you",
                    style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(height: 8),
                _buildProductsList(productController.products),
              ],

              // Show search results section
              if (isSearching)
                _buildSearchResultsSection(
                    productController.searchQuery.value,
                    productController.filteredProducts,
                    controller,
                    productController),

              // Add padding at the bottom to prevent content from being hidden by bottom nav bar
              SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  // Helper method to build the product list
  Widget _buildProductsList(List<Product> productList) {
    if (productList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No products available"),
        ),
      );
    }

    return SizedBox(
      height: 240, // Slightly reduced height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productList.length,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return ProductVerticalCard(
            product: productList[index],
            onWishlistTap: () {
              // Handle wishlist
            },
          );
        },
      ),
    );
  }

  // Helper method to build search results section
  Widget _buildSearchResultsSection(String query, List<Product> results,
      HomepageController controller, ProductController productController) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, size: 18, color: Colors.blue[700]),
                    SizedBox(width: 8),
                    Text(
                      'Search Results (${results.length})',
                      style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                if (results.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      controller.changeIndex(1); // Navigate to Shop tab
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.lexend(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          if (results.isEmpty)
            Container(
              padding: EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                  SizedBox(height: 12),
                  Text(
                    'No products match "$query"',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      productController.clearSearch();
                    },
                    child: Text('Clear Search'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[700]!),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 210, // Reduced height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: results.length > 5 ? 5 : results.length,
                itemBuilder: (context, index) {
                  return ProductVerticalCard(
                    product: results[index],
                    onWishlistTap: () {
                      // Handle wishlist
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void changeIndex(int i) {}
}
