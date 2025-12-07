import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mood_provider.dart';

class LoveTouchButton extends StatelessWidget {
  final AuthProvider auth;
  final MoodProvider mood;

  const LoveTouchButton({super.key, required this.auth, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            // Có thể thêm hiệu ứng long press nếu muốn
          },
          onTap: () {
            if (auth.coupleId != null && auth.user != null) {
              mood.sendLoveTouch(auth.coupleId!, auth.user!.uid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("❤️ Đã gửi yêu thương!"),
                  duration: Duration(milliseconds: 500),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 50, left: 20, right: 20),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pink.withOpacity(0.1),
              border: Border.all(color: Colors.pinkAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.touch_app,
              size: 40,
              color: Colors.pinkAccent,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Chạm để gửi yêu thương",
          style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
