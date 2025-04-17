import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../addresses/add_address_form.dart';

class Addresses extends StatelessWidget {
  const Addresses({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Addresses',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Please login to view addresses'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Addresses')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Check if the addresses document exists
                final hasAddressDoc = snapshot.hasData && snapshot.data!.exists;

                // If no address document exists, show UI to add first address
                if (!hasAddressDoc) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No addresses found',
                                  style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Add your first delivery address',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Add New Address button
                        GestureDetector(
                          onTap: () => _addNewAddress(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E7DFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Add New Address',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Get addresses array from document
                final addressData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final addresses =
                    List<dynamic>.from(addressData['addressList'] ?? []);

                // Show empty state if addressList exists but has no addresses
                if (addresses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No saved addresses yet',
                                  style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Add your first delivery address',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Add New Address button
                        GestureDetector(
                          onTap: () => _addNewAddress(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E7DFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Add New Address',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Display addresses when they exist
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address =
                                addresses[index] as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            address['name'] ?? 'My Address',
                                            style: GoogleFonts.lexend(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            _formatAddress(address),
                                            style: GoogleFonts.lexend(
                                              color: Colors.blue[800],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _editAddress(
                                                context, address, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE7ECF1),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Edit',
                                            style: GoogleFonts.lexend(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            _deleteAddress(context, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE7ECF1),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: GoogleFonts.lexend(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _addNewAddress(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E7DFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Add New Address',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    final streetLine1 = address['streetLine1'] ?? '';
    final streetLine2 = address['streetLine2'] ?? '';
    final city = address['city'] ?? '';
    final state = address['state'] ?? '';
    final country = address['country'] ?? '';
    final pinCode = address['pinCode'] ?? '';

    return [
      streetLine1,
      streetLine2,
      city,
      "$state, $pinCode",
      country,
    ].where((element) => element.isNotEmpty).join(', ');
  }

  void _addNewAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressPage(),
      ),
    );
  }

  void _editAddress(
      BuildContext context, Map<String, dynamic> address, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddAddressPage(addressToEdit: address, addressIndex: index),
      ),
    );
  }

  void _deleteAddress(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Address', style: GoogleFonts.lexend()),
        content: Text(
          'Are you sure you want to delete this address?',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lexend()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteAddress(index);
            },
            child: Text('Delete', style: GoogleFonts.lexend(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAddress(int index) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final addressesRef = FirebaseFirestore.instance
          .collection('Addresses')
          .doc(currentUser.uid);

      final addressDoc = await addressesRef.get();

      if (!addressDoc.exists) return;

      final addressData = addressDoc.data() as Map<String, dynamic>;
      final addresses = List<dynamic>.from(addressData['addressList'] ?? []);

      if (index >= 0 && index < addresses.length) {
        addresses.removeAt(index);

        await addressesRef.update({'addressList': addresses});
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }
}
