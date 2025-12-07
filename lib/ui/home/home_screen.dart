import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:love_sync/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../services/update_service.dart';
import '../../services/database_service.dart'; // Added for DecisionTournamentDialog

// Widgets
import 'widgets/anniversary_card.dart';
import 'widgets/mood_section.dart';

import 'widgets/decision_tournament_dialog.dart';
import 'widgets/tournament_reception_dialog.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isTournamentDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra cập nhật khi vào app
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        UpdateService().checkUpdate(context);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // --- Listen to Request ---
  void _listenToRequests(AuthProvider auth) {
    if (auth.coupleId == null || auth.user == null) return;

    DatabaseService().listenToDecisionRequest(auth.coupleId!).listen((event) {
      if (event.snapshot.value == null) return;
      final data = event.snapshot.value as Map;
      final status = data['status'];
      final senderId = data['senderId'];

      // Show dialog only if PENDING and NOT ME
      // GUARD: If we already have a result (e.g. just decided), don't show request dialog
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      if (moodProvider.currentValidDecision != null ||
          moodProvider.isRejected) {
        return;
      }

      if (status == 'pending' && senderId != auth.user!.uid) {
        final options = List<String>.from(data['options'] ?? []);

        if (mounted) {
          // GUARD: Check if dialog is already showing
          if (_isTournamentDialogShowing) return;

          _isTournamentDialogShowing = true;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => TournamentReceptionDialog(
              options: options,
              onWinnerFound: (winner) {
                DatabaseService().respondToDecision(
                  auth.coupleId!,
                  winner: winner,
                  status: 'accepted',
                );
              },
              onReject: (reason) {
                DatabaseService().respondToDecision(
                  auth.coupleId!,
                  reason: reason,
                  status: 'rejected',
                );
              },
            ),
          ).then((_) {
            // Reset flag when dialog closes
            if (mounted) {
              _isTournamentDialogShowing = false;
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthProvider để biết trạng thái Loading hoặc Error
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Love Sync',
          style: GoogleFonts.nunito(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, authProvider, l10n),
      floatingActionButton: authProvider.roomStream != null
          ? FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              child: const Icon(Icons.chat_bubble, color: Colors.white),
              onPressed: () {
                if (authProvider.coupleId != null &&
                    authProvider.user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        coupleId: authProvider.coupleId!,
                        userId: authProvider.user!.uid,
                      ),
                    ),
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthProvider auth,
    AppLocalizations l10n,
  ) {
    // TRƯỜNG HỢP 1: Chưa có phòng (Stream null) -> Hiện giao diện Tạo/Join
    if (auth.roomStream == null) {
      return _buildUnpairedView(auth, l10n);
    }

    // TRƯỜNG HỢP 2: Đã có phòng -> Lắng nghe thay đổi Realtime
    return StreamBuilder<DatabaseEvent>(
      stream: auth.roomStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.snapshot.value == null) {
          // Phòng bị lỗi hoặc bị xóa
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.connectionError),
                TextButton(
                  onPressed: () => auth.signOut(), // Reset state
                  child: Text(l10n.goBack),
                ),
              ],
            ),
          );
        }

        // Lấy dữ liệu phòng về
        final data = snapshot.data!.snapshot.value as Map;
        final status = data['status']; // 'waiting' hoặc 'paired'
        final code = data['code'];
        // final partnerName = data['user2'] != null ? "Partner" : null; // This line is no longer used

        // --- TRƯỜNG HỢP 2A: ĐÃ KẾT ĐÔI (PAIRED) ---
        if (status == 'paired') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (auth.coupleId != null && auth.user != null) {
              Provider.of<MoodProvider>(
                context,
                listen: false,
              ).startListening(auth.coupleId!, auth.user!.uid);
            }
            if (auth.coupleId != null && auth.user != null) {
              Provider.of<MoodProvider>(
                context,
                listen: false,
              ).startListening(auth.coupleId!, auth.user!.uid);
              _listenToRequests(auth);
            }
          });

          return _buildPairedView(context, auth, l10n);
        }

        // --- TRƯỜNG HỢP 2B: ĐANG CHỜ (WAITING) ---
        return _buildWaitingView(context, auth, code, l10n);
      },
    );
  }

  // --- SUB VIEWS ---

  // --- SUB VIEWS ---

  Widget _buildUnpairedView(AuthProvider auth, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 30),

            // Nút Tạo Phòng (Cho User A)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => auth.createPairingCode(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.createRoom,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    l10n.or,
                    style: GoogleFonts.nunito(color: Colors.grey),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 40),

            // Ô nhập mã (Cho User B)
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: l10n.enterCode,
                hintText: "DHAPW0",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters, // Tự viết hoa
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  if (_codeController.text.isNotEmpty) {
                    auth.joinPairingCode(_codeController.text);
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.joinRoom,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (auth.errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                auth.errorMessage!,
                style: GoogleFonts.nunito(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView(
    BuildContext context,
    AuthProvider auth,
    String? code,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 30),
            Text(
              l10n.waitingForPartner,
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Hiển thị Mã Code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Text(
                code ?? "ERROR",
                style: GoogleFonts.nunito(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.pink,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nút Copy
            TextButton.icon(
              icon: const Icon(Icons.copy, color: Colors.grey),
              label: Text(
                l10n.copyCode,
                style: GoogleFonts.nunito(color: Colors.grey),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code ?? ""));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.codeCopied)));
              },
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => auth.signOut(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPairedView(
    BuildContext context,
    AuthProvider auth,
    AppLocalizations l10n,
  ) {
    return Consumer<MoodProvider>(
      builder: (context, mood, child) {
        // Check for Mood Alert
        if (mood.shouldShowMoodAlert) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.partnerFeelingMessage(
                      mood.partnerMood ?? '',
                      mood.partnerMoodDesc ?? '',
                    ),
                  ),
                  backgroundColor: Colors.pinkAccent,
                ),
              );
              mood.consumeMoodAlert();
            }
          });
        }

        return Center(
          child: SingleChildScrollView(
            // Thêm Scroll để tránh overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. ANNIVERSARY CARD
                AnniversaryCard(auth: auth, mood: mood),

                // 2. Decision Result (If any)
                if (mood.currentValidDecision != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.orange),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.decisionResult(mood.currentValidDecision!),
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (mood.isRejected)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.decisionRejectedReason(
                              mood.decisionReason ?? l10n.unknownReason,
                            ),
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 3. MOOD AREA
                MoodSection(auth: auth, mood: mood),

                const SizedBox(height: 30),
                Divider(
                  color: Colors.grey[200],
                  thickness: 2,
                  indent: 40,
                  endIndent: 40,
                ),
                const SizedBox(height: 30),

                // 5. Decision Tournament Button
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => DecisionTournamentDialog(
                        onSendRequest: (options) async {
                          if (auth.coupleId != null && auth.user != null) {
                            await DatabaseService().sendDecisionRequest(
                              auth.coupleId!,
                              auth.user!.uid,
                              options,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.invitationSent)),
                            );
                          }
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.casino, color: Colors.deepPurple),
                  label: Text(
                    l10n.helpUsDecide,
                    style: GoogleFonts.nunito(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
