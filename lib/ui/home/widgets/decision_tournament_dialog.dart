import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_sync/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    // Validate inputs
    final validOptions = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.needAtLeastTwoOptions)));
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.createTournament,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.enterOptionsForPartner,
            style: GoogleFonts.nunito(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Option Count Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.quantity),
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
                  labelText: l10n.optionIndex(index + 1),
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
            child: Text(
              l10n.send,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
