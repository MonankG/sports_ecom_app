import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_app/views/auth/signupform.dart';
import 'package:sample_app/views/home/homepage.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {

  bool isMailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isMailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isMailVerified) {
      sendVerificationEmail();

      var timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${ex.toString()}'),
          ),
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isMailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if(isMailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => isMailVerified
      ? UserDetailsFormPage()
      : Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Verify Email',
              style: GoogleFonts.lexend(
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A verification link has been sent to your email. Please check your inbox.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  child: Text(
                      'Resend Verification Email',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                      ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: FirebaseAuth.instance.signOut,
                    child: Text(
                        'Cancel',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                        ),
                    ),)
              ],
            ),
          ),
        );
}
