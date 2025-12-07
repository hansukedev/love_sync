import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  // --- Mood Sync Methods ---

  // Cập nhật Mood lên DB
  Future<void> updateMood(
    String coupleId,
    String userId,
    String moodCode,
    String description,
  ) async {
    try {
      await _dbRef.child('couples/$coupleId/mood/$userId').set({
        'code': moodCode,
        'description': description,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Update Mood Error: $e');
    }
  }

  // Lắng nghe thay đổi Mood của cả 2
  Stream<DatabaseEvent> getMoodStream(String coupleId) {
    return _dbRef.child('couples/$coupleId/mood').onValue;
  }

  // --- Love Touch Methods ---

  // Gửi tín hiệu rung (Love Touch)
  Future<void> sendTouch(String coupleId, String userId) async {
    try {
      await _dbRef.child('couples/$coupleId/touch/$userId').set({
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Send Touch Error: $e');
    }
  }

  // Lắng nghe tín hiệu rung
  Stream<DatabaseEvent> getTouchStream(String coupleId) {
    return _dbRef.child('couples/$coupleId/touch').onValue;
  }

  // --- Anniversary Methods ---

  // Cập nhật ngày bắt đầu yêu
  Future<void> updateStartDate(String coupleId, int timestamp) async {
    try {
      await _dbRef.child('couples/$coupleId/startDate').set(timestamp);
    } catch (e) {
      debugPrint('Update StartDate Error: $e');
    }
  }

  // Lắng nghe ngày bắt đầu yêu
  Stream<DatabaseEvent> getStartDateStream(String coupleId) {
    return _dbRef.child('couples/$coupleId/startDate').onValue;
  }

  // --- Decision Tournament Methods ---

  // Cập nhật kết quả quyết định
  Future<void> updateDecision(String coupleId, String result) async {
    try {
      await _dbRef.child('couples/$coupleId/decision').set({
        'winner': result,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Update Decision Error: $e');
    }
  }

  // Lắng nghe kết quả quyết định
  Stream<DatabaseEvent> getDecisionStream(String coupleId) {
    return _dbRef.child('couples/$coupleId/decision').onValue;
  }

  // --- New Decision Tournament (Request/Response) ---

  Future<void> sendDecisionRequest(
    String coupleId,
    String senderId,
    List<String> options,
  ) async {
    try {
      await _dbRef.child('couples/$coupleId/decision_request').set({
        'senderId': senderId,
        'options': options,
        'timestamp': ServerValue.timestamp,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('Send Decision Request Error: $e');
    }
  }

  Future<void> respondToDecision(
    String coupleId, {
    String? winner,
    String? reason,
    required String status,
  }) async {
    try {
      await _dbRef.child('couples/$coupleId/decision_result').set({
        'winner': winner,
        'reason': reason,
        'status': status,
        'timestamp': ServerValue.timestamp,
      });

      // Clear request logic if needed, but keeping history or clearing request might be good.
      // For now, let's update status of request to completed to hide it.
      await _dbRef
          .child('couples/$coupleId/decision_request/status')
          .set('completed');

      // Also update the main decision node for dashboard display if accepted
      if (status == 'accepted' && winner != null) {
        updateDecision(coupleId, winner);
      }
    } catch (e) {
      debugPrint('Respond Decision Error: $e');
    }
  }

  Stream<DatabaseEvent> listenToDecisionRequest(String coupleId) {
    return _dbRef.child('couples/$coupleId/decision_request').onValue;
  }

  Stream<DatabaseEvent> listenToDecisionResult(String coupleId) {
    return _dbRef.child('couples/$coupleId/decision_result').onValue;
  }

  // --- Secure Chat Methods ---

  Future<void> sendMessage(
    String coupleId,
    String senderId,
    String text, {
    String? imageUrl,
  }) async {
    try {
      await _dbRef.child('couples/$coupleId/messages').push().set({
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Send Message Error: $e');
    }
  }

  Stream<DatabaseEvent> getChatStream(String coupleId) {
    // Limit to last 50 messages for performance
    return _dbRef
        .child('couples/$coupleId/messages')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue;
  }

  Future<String?> uploadImage(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child(
        'chat_images/$fileName.jpg',
      );
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload Image Error: $e');
      return null;
    }
  }
}
