import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mood_provider.dart';

class MoodSection extends StatelessWidget {
  final AuthProvider auth;
  final MoodProvider mood;

  const MoodSection({super.key, required this.auth, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. PARTNER MOOD AREA ---
        if (mood.partnerMood != null) ...[
          _buildMoodIcon(mood.partnerMood!, size: 100),
          const SizedBox(height: 16),
          Text(
            "Người ấy đang cảm thấy...",
            style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
          ),
          if (mood.partnerMoodDesc != null && mood.partnerMoodDesc!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 30, right: 30),
              child: Text(
                '"${mood.partnerMoodDesc}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ] else ...[
          const Icon(Icons.favorite, size: 100, color: Colors.pink),
          const SizedBox(height: 16),
          Text(
            "You are Paired!",
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],

        const SizedBox(height: 40),
        Divider(
          color: Colors.grey[200],
          thickness: 2,
          indent: 40,
          endIndent: 40,
        ),
        const SizedBox(height: 40),

        // --- 3. MY MOOD SELECTOR ---
        Text(
          "Hôm nay bạn thế nào?",
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 16),

        // Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _moodOption(
                context,
                'happy',
                Icons.sentiment_very_satisfied,
                Colors.amber,
              ),
              _moodOption(context, 'loved', Icons.favorite, Colors.pink),
              _moodOption(
                context,
                'sad',
                Icons.sentiment_very_dissatisfied,
                Colors.blue,
              ),
              _moodOption(context, 'tired', Icons.bedtime, Colors.purple),
              _moodOption(
                context,
                'angry',
                Icons.sentiment_dissatisfied,
                Colors.red,
              ),
            ],
          ),
        ),

        // Description Input (Chỉ hiện khi đã chọn mood)
        if (mood.myMood != null) ...[
          const SizedBox(height: 16),
          Container(
            width: 250,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Tại sao bạn cảm thấy vậy?",
                border: InputBorder.none,
                icon: Icon(Icons.edit, size: 16, color: Colors.grey),
              ),
              style: GoogleFonts.nunito(fontSize: 14),
              onSubmitted: (value) {
                if (auth.coupleId != null &&
                    auth.user != null &&
                    mood.myMood != null) {
                  mood.setMood(
                    auth.coupleId!,
                    auth.user!.uid,
                    mood.myMood!,
                    value,
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _moodOption(
    BuildContext context,
    String code,
    IconData icon,
    Color color,
  ) {
    final isSelected = mood.myMood == code;

    return GestureDetector(
      onTap: () {
        if (auth.coupleId != null && auth.user != null) {
          // Khi nhấn icon, gửi mood với description rỗng hoặc giữ nguyên cái cũ (ở đây chọn gửi rỗng để reset)
          // Hoặc có thể lưu state local của textField.
          // Đơn giản nhất: gửi "" description khi mới chọn icon.
          mood.setMood(auth.coupleId!, auth.user!.uid, code, "");
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? color : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildMoodIcon(String code, {double size = 48}) {
    IconData icon;
    Color color;

    switch (code) {
      case 'happy':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.amber;
        break;
      case 'loved':
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case 'sad':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.blue;
        break;
      case 'tired':
        icon = Icons.bedtime;
        color = Colors.purple;
        break;
      case 'angry':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      default:
        icon = Icons.face;
        color = Colors.grey;
    }

    return Icon(icon, size: size, color: color);
  }
}
