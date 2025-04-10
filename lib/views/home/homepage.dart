import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
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
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
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
        preferredSize: Size.fromHeight(screenHeight * 0.18),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black,
          flexibleSpace: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gear Up",
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.07,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  width: screenWidth * 0.85,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      hintText: "Search for gear",
                      hintStyle: GoogleFonts.lexend(color: Colors.blueAccent),
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart_outlined),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    child: Image.network(
                      'https://storage.googleapis.com/a1aa/image/J3gJhvAMSuIrAEy3uRpnfvZd18Fyfg6_pt1agRjvQUY.jpg',
                      width: screenWidth,
                      height: screenHeight * 0.25,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      'Score Big on Spring',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "Featured Products",
                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.sliderImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(controller.sliderImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: SmoothPageIndicator(
                  controller: controller.pageController,
                  count: controller.sliderImages.length,
                  effect: ExpandingDotsEffect(dotHeight: 8, dotWidth: 8, activeDotColor: Colors.blue, dotColor: Colors.grey),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "For you",
                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              SizedBox(height: 8),
              Obx(() {
                if (productController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final productList = productController.products;
                if (productList.isEmpty) {
                  return Center(child: Text("No products available"));
                }

                return SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productList.length,
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
              })

            ],
          ),
        ),
      ),
    );
  }
}
