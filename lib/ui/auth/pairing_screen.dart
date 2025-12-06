import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _generatedCode;
  String? _currentCoupleId;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[100]!, Colors.white],
              ),
            ),
          ),

          DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Pairing',
                  style: GoogleFonts.nunito(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                bottom: TabBar(
                  labelColor: Colors.black87,
                  indicatorColor: Colors.black87,
                  tabs: const [
                    Tab(text: 'Create Room'),
                    Tab(text: 'Join Room'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildCreateTab(authProvider),
                  _buildJoinTab(authProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab(AuthProvider auth) {
    return Center(
      child: _glassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_outline, size: 64, color: Colors.black54),
            const SizedBox(height: 16),
            Text(
              'Your Pairing Code',
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            if (_isCreating)
              const CircularProgressIndicator(color: Colors.black87)
            else if (_generatedCode != null) ...[
              Text(
                _generatedCode!,
                style: GoogleFonts.nunito(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedCode!));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Copied!')));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  side: const BorderSide(color: Colors.black12),
                ),
              ),
              const SizedBox(height: 24),
              const LinearProgressIndicator(
                color: Colors.pinkAccent,
                backgroundColor: Colors.black12,
              ),
              const SizedBox(height: 8),
              Text(
                'Waiting for partner...',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),

              // Hidden Stream Listener
              StreamBuilder<DatabaseEvent>(
                stream: _currentCoupleId != null
                    ? auth.getCoupleStream(_currentCoupleId!)
                          as Stream<DatabaseEvent>
                    : null,
                builder: (context, snapshot) {
                  return const SizedBox.shrink();
                },
              ),
            ] else
              ElevatedButton(
                onPressed: () async {
                  setState(() => _isCreating = true);
                  final result = await auth.createPairingCode();
                  if (result != null) {
                    setState(() {
                      _generatedCode = result['code'];
                      _currentCoupleId = result['coupleId'];
                      _isCreating = false;
                    });
                  } else {
                    setState(() => _isCreating = false);
                  }
                },
                child: const Text('Generate Code'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinTab(AuthProvider auth) {
    return Center(
      child: _glassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Partner Code',
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50], // Slightly visible input bg
                hintText: 'XXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (auth.isLoading)
              const CircularProgressIndicator(color: Colors.black87)
            else
              ElevatedButton(
                onPressed: () async {
                  bool success = await auth.joinPairingCode(
                    _codeController.text.trim().toUpperCase(),
                  );
                  if (success && mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } else if (auth.errorMessage != null && mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
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
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
