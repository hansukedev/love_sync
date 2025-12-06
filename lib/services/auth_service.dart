import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- Đừng quên import dòng này

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cấu hình Google Sign In với Client ID lấy từ google-services.json
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // ID này lấy từ dòng "client_type": 3 trong file json ông gửi
    clientId:
        '440780270480-5530071k0jmpm3ihjld5oj892a8695jr.apps.googleusercontent.com',
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  // Stream theo dõi trạng thái đăng nhập
  Stream<User?> get user => _auth.authStateChanges();

  // Đăng nhập ẩn danh
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print('Auth Error (Anonymous): $e');
      return null;
    }
  }

  // Đăng nhập Google (ĐÃ SỬA LOGIC)
  Future<User?> signInWithGoogle() async {
    try {
      print("Bắt đầu quy trình Google Sign In...");

      // 1. Mở cửa sổ chọn tài khoản Google
      // LƯU Ý: Nếu nó xoay mà không hiện gì, kiểm tra lại SHA-1 hoặc máy ảo có CH Play không
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Người dùng đã hủy chọn tài khoản (bấm ra ngoài)");
        return null;
      }

      print("Đã chọn user: ${googleUser.email}");

      // 2. Lấy Token xác thực từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo chứng chỉ (Credential) để gửi cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase bằng chứng chỉ đó
      UserCredential result = await _auth.signInWithCredential(credential);
      print("Đăng nhập Firebase thành công: ${result.user?.uid}");

      return result.user;
    } catch (e) {
      print('LỖI ĐĂNG NHẬP GOOGLE: $e');
      return null;
    }
  }

  // Đăng xuất (Thoát cả Firebase và Google)
  Future<void> signOut() async {
    await _googleSignIn
        .signOut(); // Thoát tài khoản Google để lần sau nó hỏi lại
    await _auth.signOut();
  }
}
