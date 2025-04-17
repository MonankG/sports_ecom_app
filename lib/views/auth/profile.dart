import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_app/views/auth/edit_profile.dart';
import 'package:sample_app/views/orders/my_orders.dart';
import 'package:sample_app/views/wishlist/wishlist.dart';
import 'package:sample_app/views/settings/notifications_settings.dart';
import 'package:sample_app/views/settings/addresses.dart';
import 'package:sample_app/views/settings/payment_methods.dart';
import 'package:sample_app/views/auth/login.dart';

import '../../controllers/auth_controller.dart';

class UserProfile extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "My Profile",
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
              // Show options menu
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.help_outline),
                      title: Text('Help & Support'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help page
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('About Us'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to about page
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: Obx(() {
        // Check if user is logged in
        final user = authController.firebaseUser.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You're not logged in",
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => LoginPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // User is logged in, fetch their data
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading profile. Please try again.',
                  style: GoogleFonts.lexend(),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Profile not found. Please update your information.',
                  style: GoogleFonts.lexend(),
                ),
              );
            }

            // Get user data
            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;

            // Use user data for display - match your actual field names in Firestore
            String firstName = userData['first_name'] ?? 'User';
            String lastName = userData['last_name'] ?? '';
            String fullName = '$firstName $lastName';
            String email =
                userData['email'] ?? user.email ?? 'No email provided';
            String phone = userData['phone_number'] ?? 'No phone provided';

            // If you have a profile picture field, use it here
            String photoUrl = userData['profile_picture'] ??
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(firstName)}+${Uri.encodeComponent(lastName)}&size=150';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: constraints.maxWidth * 0.12,
                              backgroundImage: NetworkImage(photoUrl),
                              onBackgroundImageError: (_, __) {
                                // Handle image loading errors
                              },
                            ),
                            SizedBox(width: constraints.maxWidth * 0.05),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: GoogleFonts.lexend(
                                      fontSize: constraints.maxWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style:
                                        GoogleFonts.lexend(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => EditProfilePage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Edit profile',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'General',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildListItem(
                      title: 'My Orders',
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => Get.to(() => MyOrders()),
                    ),
                    _buildListItem(
                      title: 'Reviews',
                      icon: Icons.star_border,
                      onTap: () {
                        // Navigate to reviews page when implemented
                        Get.snackbar(
                          'Coming Soon',
                          'Reviews feature will be available soon!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                    _buildListItem(
                      title: 'Favorites',
                      icon: Icons.favorite_border,
                      onTap: () => Get.to(() => WishList()),
                    ),
                    _buildListItem(
                      title: 'Notifications',
                      icon: Icons.notifications_none,
                      onTap: () => Get.to(() => NotificationsSettings()),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Account',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildListItem(
                      title: 'Addresses',
                      icon: Icons.location_on_outlined,
                      onTap: () => Get.to(() => Addresses()),
                    ),
                    _buildListItem(
                      title: 'Payment Methods',
                      icon: Icons.credit_card,
                      onTap: () => Get.to(() => PaymentMethods()),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await authController.logoutUser();
                              Get.snackbar(
                                'Success',
                                'You have been logged out successfully',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Failed to logout: $e',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Log Out',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildListItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.lexend(fontSize: 16),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
