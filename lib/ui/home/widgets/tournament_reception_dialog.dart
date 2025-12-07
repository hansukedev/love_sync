import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TournamentReceptionDialog extends StatefulWidget {
  final List<String> options;
  final Function(String) onWinnerFound;
  final Function(String) onReject;

  const TournamentReceptionDialog({
    super.key,
    required this.options,
    required this.onWinnerFound,
    required this.onReject,
  });

  @override
  State<TournamentReceptionDialog> createState() =>
      _TournamentReceptionDialogState();
}

class _TournamentReceptionDialogState extends State<TournamentReceptionDialog> {
  // Game State
  List<String> _currentRoundMatches = [];
  List<String> _nextRoundWinners = [];
  int _matchIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentRoundMatches = List.from(widget.options);
  }

  void _selectWinner(String winner) {
    _nextRoundWinners.add(winner);

    // Check if round is over
    if (_matchIndex + 2 >= _currentRoundMatches.length) {
      // Xử lý người lẻ loi cuối cùng (nếu có)
      if (_matchIndex + 2 < _currentRoundMatches.length) {
        // Còn 1 người chưa đấu -> vào thẳng
        _nextRoundWinners.add(_currentRoundMatches.last);
      } else if (_currentRoundMatches.length % 2 != 0 &&
          _matchIndex + 1 == _currentRoundMatches.length - 1) {
        // Case lẻ
        _nextRoundWinners.add(_currentRoundMatches.last);
      }

      // End of Round
      if (_nextRoundWinners.length == 1) {
        // FOUND CHAMPION
        widget.onWinnerFound(_nextRoundWinners.first);
        Navigator.of(context).pop();
      } else {
        // Next Round Setup
        setState(() {
          _currentRoundMatches = List.from(_nextRoundWinners);
          _nextRoundWinners = [];
          _matchIndex = 0;
        });
      }
    } else {
      // Next Match in current Round
      setState(() {
        _matchIndex += 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  // Show Reject Dialog
                  _showRejectDialog();
                },
              ),
            ),
            Expanded(child: _buildGameView()),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Từ chối tham gia?"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "Lý do (VD: Không đói)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close alert
              Navigator.pop(context); // Close tournament
              widget.onReject(
                reasonController.text.isEmpty
                    ? "Không muốn chơi"
                    : reasonController.text,
              );
            },
            child: const Text("Gửi", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    if (_currentRoundMatches.isEmpty) return const SizedBox();

    final optionA = _currentRoundMatches[_matchIndex];
    final optionB = (_matchIndex + 1 < _currentRoundMatches.length)
        ? _currentRoundMatches[_matchIndex + 1]
        : "N/A";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Người ấy muốn bạn chọn!",
          style: GoogleFonts.nunito(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionButton(optionA, Colors.blueAccent),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "VS",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              if (optionB != "N/A")
                _buildOptionButton(optionB, Colors.orangeAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _selectWinner(text),
        child: Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
