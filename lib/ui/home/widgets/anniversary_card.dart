import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mood_provider.dart';

class AnniversaryCard extends StatelessWidget {
  final AuthProvider auth;
  final MoodProvider mood;

  const AnniversaryCard({super.key, required this.auth, required this.mood});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (auth.coupleId == null) return;
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: mood.startDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          mood.setAnniversary(auth.coupleId!, picked);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent.shade100, Colors.pinkAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Chúng mình bên nhau",
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              "${mood.daysTogether} Ngày",
              style: GoogleFonts.nunito(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (mood.startDate != null)
              Text(
                "Kể từ: ${mood.startDate!.day}/${mood.startDate!.month}/${mood.startDate!.year}",
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
              )
            else
              Text(
                "Chạm để chọn ngày",
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
