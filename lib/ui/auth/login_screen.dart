import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[100]!, Colors.white],
              ),
            ),
          ),

          // 2. Decorations
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
                color: Colors.pink.withOpacity(0.03),
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
                      const Icon(
                        Icons.favorite_rounded,
                        size: 72,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 16),
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

                      if (authProvider.isLoading)
                        const CircularProgressIndicator(color: Colors.black87)
                      else ...[
                        // Google Login Button (Đã sửa logic bắt lỗi hiển thị Dialog)
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
                              try {
                                bool success = await authProvider
                                    .signInWithGoogle();

                                // NẾU THÀNH CÔNG: KHÔNG LÀM GÌ CẢ.
                                // StreamBuilder ở main.dart sẽ tự chuyển trang.

                                // NẾU THẤT BẠI: Hiện lỗi
                                if (!success && context.mounted) {
                                  // Hiển thị dialog lỗi rõ ràng để debug SHA-1
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Đăng nhập thất bại"),
                                      content: Text(
                                        "Lỗi: ${authProvider.errorMessage ?? 'Không xác định'}\n\n(Nếu là bản Release, hãy kiểm tra SHA-1 trong Firebase)",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Bắt Exception (Thường là lỗi 10 hoặc 12500)
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Lỗi Google Sign-In"),
                                      content: Text("Chi tiết: $e"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
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
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Anonymous Login
                        TextButton(
                          onPressed: () async {
                            try {
                              bool success = await authProvider
                                  .signInAnonymously();
                              // Tương tự, để main.dart tự chuyển trang
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authProvider.errorMessage ??
                                          "Lỗi ẩn danh",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Lỗi: $e")),
                                );
                              }
                            }
                          },
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
