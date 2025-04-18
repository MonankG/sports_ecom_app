import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, dynamic>? addressToEdit;
  final int? addressIndex;

  const AddAddressPage({
    super.key,
    this.addressToEdit,
    this.addressIndex,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController streetLine1Controller = TextEditingController();
  final TextEditingController streetLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Populate fields if editing an existing address
    if (widget.addressToEdit != null) {
      nameController.text = widget.addressToEdit!['name'] ?? '';
      streetLine1Controller.text = widget.addressToEdit!['streetLine1'] ?? '';
      streetLine2Controller.text = widget.addressToEdit!['streetLine2'] ?? '';
      cityController.text = widget.addressToEdit!['city'] ?? '';
      stateController.text = widget.addressToEdit!['state'] ?? '';
      countryController.text = widget.addressToEdit!['country'] ?? '';
      pinCodeController.text = widget.addressToEdit!['pinCode'] ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    streetLine1Controller.dispose();
    streetLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Address' : 'Add Address',
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
              'Name',
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
                hintText: 'Home, Office, etc.',
              ),
            ),

            const SizedBox(height: 10),

            // Street Line 1 Field
            Text(
              'Street Line 1',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: streetLine1Controller,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Street address',
              ),
            ),

            const SizedBox(height: 10),

            // Street Line 2 Field
            Text(
              'Street Line 2',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: streetLine2Controller,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE7ECF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Apartment, suite, unit, etc. (optional)',
              ),
            ),

            const SizedBox(height: 10),

            // City Field
            Text(
              'City',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: cityController,
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

            // State Field
            Text(
              'State',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: stateController,
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

            // Country Field
            Text(
              'Country',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: countryController,
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

            // PIN Code Field
            Text(
              'PIN Code',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: pinCodeController,
              style: GoogleFonts.lexend(),
              keyboardType: TextInputType.number,
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
                    onPressed: isLoading ? null : () => _saveAddress(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E7DFF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            isEditing ? 'Update Address' : 'Add Address',
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
                    Navigator.pop(context);
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

  Future<void> _saveAddress(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to save an address')),
      );
      return;
    }

    // Validate form inputs
    if (streetLine1Controller.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        countryController.text.isEmpty ||
        pinCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create address object
      final addressData = {
        'name': nameController.text,
        'streetLine1': streetLine1Controller.text,
        'streetLine2': streetLine2Controller.text,
        'city': cityController.text,
        'state': stateController.text,
        'country': countryController.text,
        'pinCode': pinCodeController.text,
      };

      // Get reference to addresses document for the current user
      final addressesRef = FirebaseFirestore.instance
          .collection('Addresses')
          .doc(currentUser.uid);

      final addressDoc = await addressesRef.get();

      if (!addressDoc.exists) {
        // Create addresses document if it doesn't exist
        await addressesRef.set({
          'addressList': [addressData],
          'userId': currentUser.uid,
        });
      } else {
        // Update existing addresses document
        final existingData = addressDoc.data() as Map<String, dynamic>;
        final addresses = List<dynamic>.from(existingData['addressList'] ?? []);

        if (widget.addressToEdit != null && widget.addressIndex != null) {
          // Update existing address
          addresses[widget.addressIndex!] = addressData;
        } else {
          // Add new address
          addresses.add(addressData);
        }

        await addressesRef.update({
          'addressList': addresses,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.addressToEdit != null
                  ? 'Address updated'
                  : 'Address added',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
