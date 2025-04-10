import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cards/product_horizontal_card.dart';

class UserCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Cart",
          style: GoogleFonts.lexend(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Implement action menu
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductCard(
              imageUrl: 'https://images-cdn.ubuy.com.sa/633acca599e9df2bf24a9ec8-hobibear-fashion-running-sneaker-for-men.jpg',
              productName: 'Sweat-Wicking Training Top',
              productDescription: 'Training Top',
              price: '\$18.00',
              size: 'Size M',
            ),
          ],
        ),
      )
    );
  }
}
