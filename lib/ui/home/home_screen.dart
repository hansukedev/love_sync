import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../services/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthProvider để biết trạng thái Loading hoặc Error
    final authProvider = Provider.of<AuthProvider>(context);

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
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await authProvider.signOut();
              // Không cần Navigator push vì main.dart đã tự điều hướng về Login
            },
          ),
        ],
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, authProvider),
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider auth) {
    // TRƯỜNG HỢP 1: Chưa có phòng (Stream null) -> Hiện giao diện Tạo/Join
    if (auth.roomStream == null) {
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
                    "Tạo Phòng Mới",
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
                      "HOẶC",
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
                  labelText: "Nhập mã kết nối",
                  hintText: "Ví dụ: DHAPW0",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
                textCapitalization:
                    TextCapitalization.characters, // Tự viết hoa
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
                    "Tham Gia Phòng",
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
                const Text("Lỗi kết nối hoặc phòng đã bị hủy"),
                TextButton(
                  onPressed: () => auth.signOut(), // Reset state
                  child: const Text("Quay lại"),
                ),
              ],
            ),
          );
        }

        // Lấy dữ liệu phòng về
        final data = snapshot.data!.snapshot.value as Map;
        final status = data['status']; // 'waiting' hoặc 'paired'
        final code = data['code'];
        final partnerName = data['user2'] != null ? "Partner" : null;

        // --- TRƯỜNG HỢP 2A: ĐÃ KẾT ĐÔI (PAIRED) ---
        if (status == 'paired') {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 100, color: Colors.pink),
                const SizedBox(height: 24),
                Text(
                  "You are Paired!",
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Welcome to your shared space.",
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                ),
                // Có thể thêm nút Chat hoặc tính năng khác ở đây sau này
              ],
            ),
          );
        }

        // --- TRƯỜNG HỢP 2B: ĐANG CHỜ (WAITING) ---
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 30),
                Text(
                  "Đang chờ người ấy...",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),

                // Hiển thị Mã Code
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.pinkAccent.withOpacity(0.3),
                    ),
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
                    "Sao chép mã",
                    style: GoogleFonts.nunito(color: Colors.grey),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã sao chép mã!")),
                    );
                  },
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => auth.signOut(),
                  child: const Text("Hủy bỏ"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
