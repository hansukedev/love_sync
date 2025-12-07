import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/database_service.dart';

class MoodProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // Mood State
  String? _myMood;
  String? _myMoodDesc;
  String? _partnerMood;
  String? _partnerMoodDesc;

  // Touch State
  int _lastPartnerTouchTimestamp = 0;

  // Anniversary State
  DateTime? _startDate;

  // Subscriptions
  StreamSubscription<DatabaseEvent>? _moodSub;
  StreamSubscription<DatabaseEvent>? _touchSub;
  StreamSubscription<DatabaseEvent>? _dateSub;

  String? _trackedCoupleId;

  // Getters
  String? get myMood => _myMood;
  String? get myMoodDesc => _myMoodDesc;
  String? get partnerMood => _partnerMood;
  String? get partnerMoodDesc => _partnerMoodDesc;
  DateTime? get startDate => _startDate;

  int get daysTogether {
    if (_startDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_startDate!);
    return difference.inDays + 1; // +1 to include the start date
  }

  // Start Listening
  void startListening(String coupleId, String userId) {
    if (_trackedCoupleId == coupleId) return;

    _trackedCoupleId = coupleId;
    _moodSub?.cancel();
    _touchSub?.cancel();
    _dateSub?.cancel();

    debugPrint("MoodProvider: Start listening for couple $coupleId");

    // 1. Listen to Mood
    _moodSub = _dbService.getMoodStream(coupleId).listen((event) {
      if (event.snapshot.value == null) {
        _myMood = null;
        _myMoodDesc = null;
        _partnerMood = null;
        _partnerMoodDesc = null;
        notifyListeners();
        return;
      }

      final data = event.snapshot.value as Map;

      String? newMyMood;
      String? newMyMoodDesc;
      String? newPartnerMood;
      String? newPartnerMoodDesc;

      data.forEach((key, value) {
        if (value is Map) {
          final moodCode = value['code'] as String?;
          final moodDesc = value['description']?.toString();

          if (key == userId) {
            newMyMood = moodCode;
            newMyMoodDesc = moodDesc;
          } else {
            newPartnerMood = moodCode;
            newPartnerMoodDesc = moodDesc;
          }
        }
      });

      if (newMyMood != _myMood ||
          newPartnerMood != _partnerMood ||
          newMyMoodDesc != _myMoodDesc ||
          newPartnerMoodDesc != _partnerMoodDesc) {
        _myMood = newMyMood;
        _myMoodDesc = newMyMoodDesc;
        _partnerMood = newPartnerMood;
        _partnerMoodDesc = newPartnerMoodDesc;
        notifyListeners();
      }
    });

    // 2. Listen to Love Touch
    _touchSub = _dbService.getTouchStream(coupleId).listen((event) async {
      if (event.snapshot.value == null) return;

      final data = event.snapshot.value as Map;
      data.forEach((key, value) async {
        if (key != userId && value is Map) {
          final timestamp = value['timestamp'] as int?;
          if (timestamp != null) {
            _handleNewPartnerTouch(timestamp);
          }
        }
      });
    });

    // 3. Listen to Anniversary Date
    _dateSub = _dbService.getStartDateStream(coupleId).listen((event) {
      if (event.snapshot.value == null) {
        if (_startDate != null) {
          _startDate = null;
          notifyListeners();
        }
        return;
      }
      final timestamp = event.snapshot.value as int?;
      if (timestamp != null) {
        final newStartDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        // Avoid redundant notify updates
        if (_startDate == null ||
            newStartDate.millisecondsSinceEpoch !=
                _startDate!.millisecondsSinceEpoch) {
          _startDate = newStartDate;
          notifyListeners();
        }
      }
    });

    // 4. Listen to Decisions
    _listenToDecisions(coupleId);
  }

  void _handleNewPartnerTouch(int timestamp) async {
    if (timestamp <= _lastPartnerTouchTimestamp) return;

    _lastPartnerTouchTimestamp = timestamp;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - timestamp;

    if (diff < 5000) {
      debugPrint("❤️ LOVE TOUCH RECEIVED! Vibrating...");
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 500, 200, 500]);
      }
    } else {
      debugPrint("Old touch event ignored (Diff: ${diff}ms)");
    }
  }

  // --- Logic Methods ---

  Future<void> setMood(
    String coupleId,
    String userId,
    String moodCode,
    String description,
  ) async {
    _myMood = moodCode;
    _myMoodDesc = description;
    notifyListeners();

    await _dbService.updateMood(coupleId, userId, moodCode, description);
  }

  Future<void> sendLoveTouch(String coupleId, String userId) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
    await _dbService.sendTouch(coupleId, userId);
  }

  Future<void> setAnniversary(String coupleId, DateTime date) async {
    _startDate = date;
    notifyListeners();
    await _dbService.updateStartDate(coupleId, date.millisecondsSinceEpoch);
  }

  // --- Decision Tournament Methods ---
  String? _decisionResult;
  String? _decisionStatus;
  String? _decisionReason;
  DateTime? _decisionTime;
  StreamSubscription<DatabaseEvent>? _decisionSub;

  String? get currentValidDecision {
    if (_decisionStatus == 'rejected')
      return null; // Don't show winner if rejected
    if (_decisionResult == null || _decisionTime == null) return null;

    // TTL Check: Chỉ hiện trong 3 tiếng
    final now = DateTime.now();
    if (now.difference(_decisionTime!).inHours >= 3) {
      return null;
    }
    return _decisionResult;
  }

  bool get isRejected {
    if (_decisionStatus != 'rejected') return false;
    if (_decisionTime == null) return false;
    // Hide rejection after 3 hours too
    final now = DateTime.now();
    return now.difference(_decisionTime!).inHours < 3;
  }

  String? get decisionReason => _decisionReason;

  void _listenToDecisions(String coupleId) {
    _decisionSub = _dbService.listenToDecisionResult(coupleId).listen((event) {
      if (event.snapshot.value == null) {
        _decisionResult = null;
        _decisionStatus = null;
        _decisionReason = null;
        _decisionTime = null;
        notifyListeners();
        return;
      }
      final data = event.snapshot.value as Map;
      final winner = data['winner'] as String?;
      final status = data['status'] as String?;
      final reason = data['reason'] as String?;
      final timestamp = data['timestamp'] as int?;

      if (timestamp != null) {
        _decisionResult = winner;
        _decisionStatus = status;
        _decisionReason = reason;
        _decisionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        notifyListeners();
      }
    });
  }

  // Note: Cần gọi _listenToDecisions trong startListening

  @override
  void dispose() {
    _moodSub?.cancel();
    _touchSub?.cancel();
    _dateSub?.cancel();
    _decisionSub?.cancel();
    super.dispose();
  }
}
