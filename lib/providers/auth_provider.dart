import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get coupleId => _coupleId;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      if (user != null) {
        // Create user in DB to ensure document exists
        _dbService.createUser(UserModel(id: user.uid));
        checkPairingStatus();
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
      User? user = await _authService.signInAnonymously();
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
    _coupleId = null;
    _user = null;
    notifyListeners();
  }

  // --- Pairing Logic (Required for PairingScreen) ---

  Future<Map<String, String>?> createPairingCode() async {
    if (_user == null) return null;
    _setLoading(true);
    // Returns {code, coupleId}
    Map<String, String>? result = await _dbService.createCouple(_user!.uid);
    _setLoading(false);
    return result;
  }

  Future<bool> joinPairingCode(String code) async {
    if (_user == null) return false;
    _setLoading(true);

    // Log input nhận được từ UI
    print('🔑 [AuthProvider] joinPairingCode called with: "$code"');

    String? cId = await _dbService.joinCouple(code, _user!.uid);
    if (cId != null) {
      print('✅ [AuthProvider] Join success. CoupleID: $cId');
      await savePairingState(cId);
      _setLoading(false);
      return true;
    } else {
      print('❌ [AuthProvider] Join failed (DatabaseService returned null)');
      _errorMessage = "Failed to join. Check code, room status, or internet.";
      _setLoading(false);
      return false;
    }
  }

  Stream<dynamic> getCoupleStream(String coupleId) {
    return _dbService.getCoupleStream(coupleId);
  }

  // --- Persistence ---

  Future<void> checkPairingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _coupleId = prefs.getString('coupleId');
    notifyListeners();
  }

  Future<void> savePairingState(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coupleId', id);
    _coupleId = id;
    notifyListeners();
  }

  // Helper
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
