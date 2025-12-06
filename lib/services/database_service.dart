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
  // Join an existing couple - HEAVY DEBUG VERSION
  Future<String?> joinCouple(String codeRaw, String userId) async {
    // 0. Sanitize Input
    final String code = codeRaw.trim().toUpperCase();
    debugPrint('\n================ [JOIN ROOM START] ================');
    debugPrint('⚡ [1] User ID: $userId');
    debugPrint('⚡ [2] Input Code: "$code" (Original: "$codeRaw")');

    if (userId.isEmpty) {
      debugPrint('❌ ERROR: User ID is empty! Cannot join.');
      return null;
    }

    try {
      // 3. Construct Query
      debugPrint(
        '⚡ [3] Querying "couples" ordered by "code" equal to "$code"...',
      );

      final query = _dbRef
          .child('couples')
          .orderByChild('code')
          .equalTo(code)
          .limitToFirst(1);

      final snapshot = await query.get();

      // 4. Analyze Snapshot
      debugPrint('⚡ [4] Query Result - Exists: ${snapshot.exists}');

      if (snapshot.exists) {
        debugPrint('📦 [RAW DATA]: ${snapshot.value}');
        debugPrint('📦 [DATA TYPE]: ${snapshot.value.runtimeType}');

        // 5. Iterate & Safe Cast
        for (final child in snapshot.children) {
          debugPrint('   👉 Found Child Key: ${child.key}');

          final dynamic childValue = child.value;

          if (childValue is Map) {
            // Safe Map Casting
            // Note: Firebase Realtime DB returns Map<Object?, Object?> usually
            final Map<dynamic, dynamic> data = childValue;

            final user2 = data['user2'];
            final status = data['status'];

            debugPrint('      - user2: $user2 (${user2.runtimeType})');
            debugPrint('      - status: $status');

            // 6. Check Availability
            if (user2 == null || (user2 is String && user2.isEmpty)) {
              // 7. Update DB
              debugPrint(
                '      ✅ [Action] Room is available. Updating user2...',
              );
              await child.ref.update({
                'user2': userId,
                'status': 'paired', // Optional: update status if used
                'joinedAt': ServerValue.timestamp,
              });

              debugPrint('✅ [SUCCESS] Joined Room ID: ${child.key}');
              debugPrint('================ [JOIN ROOM END] ================\n');
              return child.key;
            } else {
              debugPrint('❌ [FAIL] Room is full. User2 is already: $user2');
            }
          } else {
            debugPrint(
              '⚠️ [WARN] Child value is not a Map! It is: ${childValue.runtimeType}',
            );
          }
        }
      } else {
        debugPrint(
          '❌ [FAIL] No room found for code "$code". Check Firebase Console.',
        );
      }
    } catch (e, stack) {
      debugPrint('🔥 [EXCEPTION] Error in joinCouple: $e');
      debugPrint('Stack trace: $stack');
    }

    debugPrint('================ [JOIN ROOM END (FAILED)] ================\n');
    return null;
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
