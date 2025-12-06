import 'dart:math';
import 'package:firebase_core/firebase_core.dart'; // <--- NHỚ THÊM DÒNG NÀY
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class DatabaseService {
  // --- ĐOẠN SỬA QUAN TRỌNG NHẤT ---
  // Thay vì dùng instance mặc định (trỏ về US), mình ép nó dùng URL của ông (trỏ về Singapore)
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://lovesync-sang-dev-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  // --------------------------------

  // Generate a random 6-character code
  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // Create a new pairing room
  Future<Map<String, String>?> createCouple(String userId) async {
    try {
      String code = _generateCode();
      // Push tạo ra một key ngẫu nhiên unique
      String coupleId = _dbRef.child('couples').push().key!;

      await _dbRef.child('couples/$coupleId').set({
        'code': code,
        'user1': userId,
        'user2': null,
        'startDate': ServerValue.timestamp,
      });

      return {'code': code, 'coupleId': coupleId};
    } catch (e) {
      print('Create Couple Error: $e');
      return null;
    }
  }

  // Join an existing couple
  // Returns coupleId if successful, null otherwise
  Future<String?> joinCouple(String codeRaw, String userId) async {
    // 1. Chuẩn hóa input: Xóa khoảng trắng, uppercase
    final String code = codeRaw.trim().toUpperCase();
    debugPrint(
      '⚡ [JoinRoom] Attempting to join with code: "$code" (Raw: "$codeRaw")',
    );

    try {
      // 2. Query tìm node nào có 'code' bằng với code nhập vào
      // IMPORTANT: Cần chắc chắn Firebase Rules đã có ".indexOn": ["code"]
      final query = _dbRef
          .child('couples')
          .orderByChild('code')
          .equalTo(code)
          .limitToFirst(1);

      final snapshot = await query.get();

      debugPrint('⚡ [JoinRoom] Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        // Snapshot trả về là một Map<key, value>, ta cần iterate qua nó
        for (final child in snapshot.children) {
          debugPrint('⚡ [JoinRoom] Found room: ${child.key}');

          final data = child.value;
          // Check data an toàn
          if (data is Map) {
            final user2 = data['user2'];
            debugPrint('⚡ [JoinRoom] Current user2: $user2');

            if (user2 == null || (user2 is String && user2.isEmpty)) {
              // Room còn trống -> Update user2
              await child.ref.update({'user2': userId});
              debugPrint('✅ [JoinRoom] Success! Joined room ${child.key}');
              return child.key;
            } else {
              debugPrint('❌ [JoinRoom] Room is full (User2 already exists)');
              // Có thể return một mã lỗi đặc biệt nếu muốn handle UI kỹ hơn
              return null;
            }
          }
        }
      } else {
        debugPrint('❌ [JoinRoom] No room found with code: $code');
      }
      return null; // Không tìm thấy hoặc full
    } catch (e) {
      debugPrint('🔥 [JoinRoom] Error: $e');
      return null;
    }
  }

  // Listen to a couple node (để biết khi nào user2 nhảy vào)
  Stream<DatabaseEvent> getCoupleStream(String coupleId) {
    return _dbRef.child('couples/$coupleId').onValue.asBroadcastStream();
  }

  // Create user info
  Future<void> createUser(UserModel user) async {
    try {
      await _dbRef.child('users/${user.id}').set(user.toMap());
    } catch (e) {
      print('Create User Error: $e');
    }
  }
}
