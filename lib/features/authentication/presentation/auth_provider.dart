import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/app_models.dart';
import '../../../shared/models/demo_data.dart';

/// Authentication state — demo mode implementation.
/// Interface is designed so Firebase Authentication can be wired in later
/// without changing any UI code.
enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  static const String _sessionKey = 'auth_session_type';
  static const String _accountTypeKey = 'auth_account_type';

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_sessionKey);
    if (session != null) {
      final accountType = prefs.getString(_accountTypeKey) == 'business'
          ? AccountType.business
          : AccountType.individual;
      _user = accountType == AccountType.business
          ? DemoData.demoBusinessUser
          : DemoData.demoUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Demo sign-in: accepts any email/password combination in demo mode.
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Demo validation
    if (email.trim().isEmpty) {
      _error = 'Please enter your email address.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final isBusiness =
        email.contains('business') ||
        email.contains('fleet') ||
        email.contains('logistics');

    _user = isBusiness ? DemoData.demoBusinessUser : DemoData.demoUser;
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();

    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, 'demo');
      await prefs.setString(
        _accountTypeKey,
        isBusiness ? 'business' : 'individual',
      );
    }

    return true;
  }

  /// Demo sign-up.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required AccountType accountType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (name.trim().isEmpty) {
      _error = 'Please enter your name.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    if (!email.contains('@')) {
      _error = 'Please enter a valid email address.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _user = accountType == AccountType.business
        ? DemoData.demoBusinessUser
        : DemoData.demoUser.copyWith(name: name, email: email);
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, 'demo');
    await prefs.setString(
      _accountTypeKey,
      accountType == AccountType.business ? 'business' : 'individual',
    );

    return true;
  }

  /// Continue as guest / demo.
  Future<void> continueAsGuest() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _user = DemoData.demoUser;
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_accountTypeKey);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Password reset — demo implementation.
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    _isLoading = false;
    notifyListeners();
    return email.contains('@');
  }
}
