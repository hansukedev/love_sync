import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:vibration/vibration.dart';
import '../services/database_service.dart';

class MoodProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // Mood State
  String? _myMood;
  String? _myMoodDesc;
  String? _partnerMood;
  String? _partnerMoodDesc;

  // Anniversary State
  DateTime? _startDate;

  // Subscriptions
  StreamSubscription<DatabaseEvent>? _moodSub;

  StreamSubscription<DatabaseEvent>? _dateSub;

  String? _trackedCoupleId;

  // Getters
  String? get myMood => _myMood;
  String? get myMoodDesc => _myMoodDesc;
  String? get partnerMood => _partnerMood;
  String? get partnerMoodDesc => _partnerMoodDesc;
  DateTime? get startDate => _startDate;

  // Alert State
  bool _shouldShowMoodAlert = false;
  bool get shouldShowMoodAlert => _shouldShowMoodAlert;

  void consumeMoodAlert() {
    _shouldShowMoodAlert = false;
    // No need to notifyListeners if just consuming a UI flag that was checked in build
  }

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

      // Check for Partner Description Change (Notification logic)
      if (newPartnerMoodDesc != null &&
          newPartnerMoodDesc != _partnerMoodDesc &&
          newPartnerMoodDesc!.isNotEmpty &&
          _partnerMoodDesc != null) {
        // Only notify if it changed from a previous non-null value
        // (Prevents spam on first load)
        _shouldShowMoodAlert = true;
      } else if (newPartnerMoodDesc != null &&
          newPartnerMoodDesc!.isNotEmpty &&
          _partnerMoodDesc == null) {
        // Optional: Notify on first load if needed, but usually annoying.
        // Let's stick to explicit updates.
        // Actually, let's notify if it's an update.
        // Simplified: If different and new is not empty.
        // But need to be careful about init.
        // If _partnerMood was already loaded (we can check if _trackedCoupleId is set?)
        // Let's rely on standard change detection.
        // If it's NOT the very first event?
        // Let's just set it. UI will consume it.
      }

      // Refined Logic:
      if (newPartnerMoodDesc != _partnerMoodDesc &&
          newPartnerMoodDesc != null &&
          newPartnerMoodDesc!.isNotEmpty) {
        // Avoid alerting on initial null -> value transition if that's preferred,
        // but user wants notification on update.
        // If _partnerMoodDesc is null, it might be first load.
        // Let's allow it for now, unless it spams on startup.
        // Best practice: check if we have previous data.
        if (_partnerMood != null) {
          // We had data before
          _shouldShowMoodAlert = true;
        }
      }

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
    _dateSub?.cancel();
    _decisionSub?.cancel();
    super.dispose();
  }
}
