import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'pairing_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Helper to handle navigation on success
    void handleLoginSuccess(bool success) {
      if (success && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PairingScreen()),
        );
      } else if (!success &&
          authProvider.errorMessage != null &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Login failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Subtle Light Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[100]!, Colors.white],
              ),
            ),
          ),

          // 2. Liquid/Blob decorations (Subtle shadows for depth)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.03), // Very subtle tint
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. Central Glass Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo / Icon (Dark Contrast)
                      const Icon(
                        Icons.favorite_rounded,
                        size: 72,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 16),

                      // App Title
                      Text(
                        'Love Sync',
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect with your partner',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Loading Indicator or Buttons
                      if (authProvider.isLoading)
                        const CircularProgressIndicator(color: Colors.black87)
                      else ...[
                        // Google Login Button
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              bool success = await authProvider
                                  .signInWithGoogle();
                              handleLoginSuccess(success);
                            },
                            // Using standard Google Icon color usually implies custom asset or colored icon logic,
                            // sticking to generic Icon(Icons.login) as placeholder but colored for now.
                            // Ideally use FontAwesomeIcons.google or an asset.
                            icon: const Icon(
                              Icons.login,
                              color: Colors.redAccent,
                            ),
                            label: Text(
                              'Tiếp tục với Google',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 56),
                              elevation:
                                  0, // Handled by container for custom feel
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Anonymous Login Button
                        TextButton(
                          onPressed: () async {
                            bool success = await authProvider
                                .signInAnonymously();
                            handleLoginSuccess(success);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                          ),
                          child: Text(
                            'Vào ẩn danh',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
