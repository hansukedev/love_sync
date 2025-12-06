import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://lovesync-sang-dev-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  // Tạo mã ngẫu nhiên 6 ký tự
  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // Tạo phòng mới (Create Room)
  Future<Map<String, String>?> createCouple(String userId) async {
    try {
      String code = _generateCode();
      String coupleId = _dbRef.child('couples').push().key!;

      await _dbRef.child('couples/$coupleId').set({
        'code': code,
        'user1': userId,
        'user2': null,
        'startDate': ServerValue.timestamp,
        'status': 'waiting',
      });

      return {'code': code, 'coupleId': coupleId};
    } catch (e) {
      debugPrint('❌ Create Couple Error: $e');
      return null;
    }
  }

  Future<String?> joinCouple(String codeRaw, String userId) async {
    final String inputCode = codeRaw.trim().toUpperCase(); // Chuẩn hóa mã
    debugPrint('\n=== 🔍 BẮT ĐẦU TÌM PHÒNG: "$inputCode" ===');

    if (userId.isEmpty) {
      debugPrint('❌ Lỗi: User ID bị rỗng');
      return null;
    }

    try {
      final snapshot = await _dbRef.child('couples').get();

      if (!snapshot.exists) {
        debugPrint('❌ DB Rỗng: Không có phòng nào (Node "couples" null)');
        return null;
      }

      final Map<dynamic, dynamic> allCouples =
          snapshot.value as Map<dynamic, dynamic>;
      String? foundCoupleId;

      // 2. Soi từng phòng một
      allCouples.forEach((key, value) {
        // Lấy code từ DB ra, ép kiểu String và viết hoa để so sánh
        final dbCode = value['code']?.toString().toUpperCase() ?? '';

        if (dbCode == inputCode) {
          debugPrint('✅ TÌM THẤY! Mã khớp ở phòng ID: $key');

          // Kiểm tra xem phòng đầy chưa
          final user2 = value['user2'];
          if (user2 != null && user2.toString().isNotEmpty) {
            debugPrint('⚠️ Phòng này đã có người (User2: $user2) -> Bỏ qua.');
          } else {
            foundCoupleId = key; // Chốt đơn phòng này
          }
        }
      });

      // 3. Xử lý kết quả
      if (foundCoupleId != null) {
        debugPrint('🚀 Đang update User2 vào phòng $foundCoupleId...');

        await _dbRef.child('couples/$foundCoupleId').update({
          'user2': userId,
          'status': 'paired',
          'joinedAt': ServerValue.timestamp,
        });

        debugPrint('🎉 JOIN THÀNH CÔNG!');
        return foundCoupleId;
      } else {
        debugPrint(
          '❌ KHÔNG TÌM THẤY mã "$inputCode" trong ${allCouples.length} phòng.',
        );
        return null;
      }
    } catch (e) {
      debugPrint('🔥 CRASH LÚC JOIN: $e');
      return null;
    }
  }

  // Lấy Stream lắng nghe thay đổi của phòng
  Stream<DatabaseEvent> getCoupleStream(String coupleId) {
    // Trả về Broadcast Stream để nhiều nơi có thể nghe cùng lúc
    return _dbRef.child('couples/$coupleId').onValue.asBroadcastStream();
  }

  // Tạo thông tin User
  Future<void> createUser(UserModel user) async {
    try {
      await _dbRef.child('users/${user.id}').set(user.toMap());
    } catch (e) {
      debugPrint('Create User Error: $e');
    }
  }
}
