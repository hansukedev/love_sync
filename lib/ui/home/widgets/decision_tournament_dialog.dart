import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DecisionTournamentDialog extends StatefulWidget {
  final Function(List<String>) onSendRequest;

  const DecisionTournamentDialog({super.key, required this.onSendRequest});

  @override
  State<DecisionTournamentDialog> createState() =>
      _DecisionTournamentDialogState();
}

class _DecisionTournamentDialogState extends State<DecisionTournamentDialog> {
  // Input State
  final List<TextEditingController> _controllers = [];
  int _optionCount = 4; // Default 4

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _controllers.clear();
    for (int i = 0; i < _optionCount; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _sendRequest() {
    // Validate inputs
    final validOptions = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cần ít nhất 2 lựa chọn!")));
      return;
    }

    widget.onSendRequest(validOptions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 500),
        child: _buildInputView(),
      ),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tạo Giải Đấu",
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Nhập các lựa chọn để gửi cho người ấy chọn!",
            style: GoogleFonts.nunito(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Option Count Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Số lượng: "),
              DropdownButton<int>(
                value: _optionCount,
                items: [2, 4, 8]
                    .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _optionCount = val;
                      _setupControllers();
                    });
                  }
                },
              ),
            ],
          ),

          // Inputs
          ...List.generate(
            _optionCount,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  labelText: "Lựa chọn ${index + 1}",
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              "Gửi đi!",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
