import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_app/views/addresses/saved_addresses.dart';
import 'package:sample_app/views/auth/profile.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<AddAddressPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Address',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            Text(
              'Street Line 1',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Street Line 2',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'City',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Email Field
            Text(
              'State',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Country',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'PIN Code',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E7DFF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Address',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Get.to(() => SavedAddressesPage());
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
