import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xE6F0F5FF), // light blue background
      body: SafeArea(
        child: Column(
          children: [
            // Back Arrow
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Shoe Image
            SizedBox(
              height: 250,
              child: Image.asset(
                  'assets/images/shoe.png'), // Replace with your image path
            ),

            // Info Section
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nike Air Zoom Pegasus 38',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '\$120',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Size Selection
                      Row(
                        children: [5, 6, 7, 8].map((size) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Colors.grey),
                              ),
                              child: Text(
                                '$size',
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 30),

                      // Expandable Sections
                      _buildExpandableTile(
                        title: 'Material',
                        content:
                            'Cotton, polyester, and spandex blend. Machine wash.',
                      ),
                      _buildExpandableTile(
                        title: 'Usage',
                        content: 'Designed for running and daily wear.',
                      ),
                      _buildExpandableTile(
                        title: 'Warranty',
                        content: '1-year manufacturer warranty.',
                      ),
                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Add to Bag',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTile(
      {required String title, required String content}) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
