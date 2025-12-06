import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // 👈 Thêm cái này để dùng DatabaseEvent
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _coupleId;

  // 👇 BIẾN QUAN TRỌNG: Lưu trữ Stream để không bị tạo lại liên tục
  Stream<DatabaseEvent>? _roomStream;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get coupleId => _coupleId;

  // 👇 GETTER THÔNG MINH: Fix lỗi "Stream already listened to"
  // Chỉ tạo stream mới nếu chưa có, giúp UI không bị crash
  Stream<DatabaseEvent>? get roomStream {
    if (_roomStream == null && _coupleId != null) {
      print("📡 [AuthProvider] Khởi tạo Stream Room mới cho ID: $_coupleId");
      _roomStream = _dbService.getCoupleStream(_coupleId!);
    }
    return _roomStream;
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.user.listen((User? user) {
      _user = user;
      if (user != null) {
        // Create user in DB to ensure document exists
        _dbService.createUser(UserModel(id: user.uid));
        checkPairingStatus();
      } else {
        // Nếu logout thì xóa sạch
        _coupleId = null;
        _roomStream = null;
      }
      notifyListeners();
    });
  }

  // --- Authentication Flow ---

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        await _dbService.createUser(UserModel(id: user.uid));
      }
      _setLoading(false);
      return user != null;
    } catch (e) {
      print("Google Sign In Error: $e");
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    try {
      // CRITICAL FIX: Reset coupleId before logging in anonymously
      _coupleId = null;
      _roomStream = null;

      User? user = await _authService.signInAnonymously();

      if (user != null) {
        // Double check pairing status, but initially it should be null for fresh anon or cleared
        await checkPairingStatus();
      }

      _setLoading(false);
      return user != null;
    } catch (e) {
      print("Anonymous Auth Error: $e");
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coupleId');

    // Reset toàn bộ state
    _coupleId = null;
    _roomStream = null;
    _user = null;

    notifyListeners();
  }

  // --- Pairing Logic ---

  Future<Map<String, String>?> createPairingCode() async {
    if (_user == null) return null;
    _setLoading(true);

    // Returns {code, coupleId}
    Map<String, String>? result = await _dbService.createCouple(_user!.uid);

    if (result != null && result['coupleId'] != null) {
      // Tự động lưu trạng thái phòng vừa tạo
      String newCoupleId = result['coupleId']!;
      await savePairingState(newCoupleId);
      print('✅ [AuthProvider] Created room: $newCoupleId');
    }

    _setLoading(false);
    return result;
  }

  Future<bool> joinPairingCode(String code) async {
    if (_user == null) return false;
    _setLoading(true);

    print('🔑 [AuthProvider] joinPairingCode called with: "$code"');

    // Gọi hàm DatabaseService (đã sửa logic vét cạn)
    String? cId = await _dbService.joinCouple(code, _user!.uid);

    if (cId != null) {
      print('✅ [AuthProvider] Join success. CoupleID: $cId');
      await savePairingState(cId); // Lưu lại để lần sau mở app tự vào
      _setLoading(false);
      return true;
    } else {
      print('❌ [AuthProvider] Join failed (DatabaseService returned null)');
      _errorMessage = "Không tìm thấy phòng hoặc phòng đã đầy.";
      _setLoading(false);
      return false;
    }
  }

  Stream<DatabaseEvent> getCoupleStream(String coupleId) {
    return _dbService.getCoupleStream(coupleId);
  }

  // --- Persistence ---

  Future<void> checkPairingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('coupleId');

    if (savedId != _coupleId) {
      _coupleId = savedId;
      _roomStream = null; // Reset stream khi ID thay đổi
      notifyListeners();
    }
  }

  Future<void> savePairingState(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coupleId', id);
    _coupleId = id;
    _roomStream = null; // Reset stream để getter tạo cái mới
    notifyListeners();
  }

  // Helper
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
