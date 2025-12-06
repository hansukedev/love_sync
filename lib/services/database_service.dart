import 'dart:math';
import 'package:firebase_core/firebase_core.dart'; // <--- NHỚ THÊM DÒNG NÀY
import 'package:firebase_database/firebase_database.dart';
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
  Future<String?> joinCouple(String code, String userId) async {
    try {
      // Query tìm node nào có 'code' bằng với code nhập vào
      final query = _dbRef
          .child('couples')
          .orderByChild('code')
          .equalTo(code)
          .limitToFirst(1);

      final snapshot = await query.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          // Check if 'user2' is null (room is available) using child() accessor
          // This avoids casting child.value to Map which can cause errors if value is not a Map
          if (child.child('user2').exists == false ||
              child.child('user2').value == null) {
            // Update user2 into that node
            await child.ref.update({'user2': userId});
            return child.key; // Return coupleId
          } else {
            print('Room is full (Đã có người yêu rồi ông ơi!)');
            return null;
          }
        }
      }
      return null; // Không tìm thấy code
    } catch (e) {
      print('Join Couple Error: $e');
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
