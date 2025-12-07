import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_sync/l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mood_provider.dart';

class MoodSection extends StatefulWidget {
  final AuthProvider auth;
  final MoodProvider mood;

  const MoodSection({super.key, required this.auth, required this.mood});

  @override
  State<MoodSection> createState() => _MoodSectionState();
}

class _MoodSectionState extends State<MoodSection> {
  String? _selectedMood;
  late TextEditingController _descController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current values from Provider
    _selectedMood = widget.mood.myMood;
    _descController = TextEditingController(text: widget.mood.myMoodDesc ?? "");
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  // Update local state when Provider data changes (sync from remote initially)
  @override
  void didUpdateWidget(covariant MoodSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood.myMood != oldWidget.mood.myMood &&
        widget.mood.myMood != _selectedMood) {
      if (_selectedMood == null) {
        // Only update if local is null (first load), don't overwrite user changes
        setState(() {
          _selectedMood = widget.mood.myMood;
          _descController.text = widget.mood.myMoodDesc ?? "";
        });
      }
    }
  }

  Future<void> _submitMood() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.auth.coupleId == null ||
        widget.auth.user == null ||
        _selectedMood == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    await widget.mood.setMood(
      widget.auth.coupleId!,
      widget.auth.user!.uid,
      _selectedMood!,
      _descController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.moodUpdated),
          backgroundColor: Colors.pinkAccent,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // --- 1. PARTNER MOOD AREA ---
        if (widget.mood.partnerMood != null) ...[
          _buildMoodIcon(widget.mood.partnerMood!, size: 100),
          const SizedBox(height: 16),
          Text(
            l10n.partnerIsFeeling,
            style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
          ),
          if (widget.mood.partnerMoodDesc != null &&
              widget.mood.partnerMoodDesc!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 30, right: 30),
              child: Text(
                '"${widget.mood.partnerMoodDesc}"',
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
            l10n.youArePaired,
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
          l10n.howAreYouToday,
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
        if (_selectedMood != null) ...[
          const SizedBox(height: 16),
          // Input Field
          Container(
            width: 250,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: l10n.whyDoYouFeelThisWay,
                border: InputBorder.none,
                icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
              ),
              style: GoogleFonts.nunito(fontSize: 14),
              // NO onSubmitted here, only button triggers update
            ),
          ),

          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 20, color: Colors.white),
              label: Text(
                _isSubmitting ? l10n.sending : l10n.updateMood,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
    final isSelected = _selectedMood == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = code;
          // Optionally reset description or keep it?
          // Keeping it is usually better UX if they just change icons.
        });
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
