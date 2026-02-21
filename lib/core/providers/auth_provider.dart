import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Provider - Manages user authentication state
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _isNewUser = true;
  bool _hasCompletedOnboarding = false;
  String? _userId;
  String? _userName;
  String? _userPhone;

  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyIsNewUser = 'is_new_user';
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isNewUser => _isNewUser;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userPhone => _userPhone;

  /// Check if onboarding should be shown
  bool get shouldShowOnboarding => _isAuthenticated && !_hasCompletedOnboarding;

  /// Initialize authentication state from storage
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool(_keyIsAuthenticated) ?? false;
      _userId = prefs.getString(_keyUserId);
      _userName = prefs.getString(_keyUserName);
      _userPhone = prefs.getString(_keyUserPhone);
      _isNewUser = prefs.getBool(_keyIsNewUser) ?? true;
      _hasCompletedOnboarding = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
    } catch (e) {
      debugPrint('Error loading auth state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasCompletedOnboarding, true);
      await prefs.setBool(_keyIsNewUser, false);
      _hasCompletedOnboarding = true;
      _isNewUser = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  /// Sign in with phone number (simplified for now)
  Future<bool> signInWithPhone(String phone, String otp) async {
    try {
      // TODO: Implement actual OTP verification
      // For now, accept any 6-digit OTP
      if (otp.length == 6) {
        // Check if this user has logged in before
        final prefs = await SharedPreferences.getInstance();
        final existingPhone = prefs.getString(_keyUserPhone);
        final isReturningUser = existingPhone == phone;

        await _saveAuthState(
          userId: 'user_${phone.substring(phone.length - 4)}',
          userName: prefs.getString(_keyUserName) ?? 'Farmer',
          userPhone: phone,
          isNewUser: !isReturningUser,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    }
  }

  /// Sign up with phone number and name
  Future<bool> signUpWithPhone(String name, String phone, String otp) async {
    try {
      // TODO: Implement actual OTP verification
      // For now, accept any 6-digit OTP
      if (otp.length == 6) {
        await _saveAuthState(
          userId: 'user_${phone.substring(phone.length - 4)}',
          userName: name,
          userPhone: phone,
          isNewUser: true,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    }
  }

  /// Save authentication state
  Future<void> _saveAuthState({
    required String userId,
    required String userName,
    required String userPhone,
    bool isNewUser = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAuthenticated, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserPhone, userPhone);

    // Only update isNewUser if it's a new user
    if (isNewUser) {
      await prefs.setBool(_keyIsNewUser, true);
      await prefs.setBool(_keyHasCompletedOnboarding, false);
      _isNewUser = true;
      _hasCompletedOnboarding = false;
    }

    _isAuthenticated = true;
    _userId = userId;
    _userName = userName;
    _userPhone = userPhone;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    // Preserve language-related settings
    final languageCode = prefs.getString('language_code');
    final hasSelectedLanguage = prefs.getBool('has_selected_language');

    // Clear all preferences
    await prefs.clear();

    // Restore language settings
    if (languageCode != null) {
      await prefs.setString('language_code', languageCode);
    }
    if (hasSelectedLanguage == true) {
      await prefs.setBool('has_selected_language', true);
    }

    _isAuthenticated = false;
    _isNewUser = true;
    _hasCompletedOnboarding = false;
    _userId = null;
    _userName = null;
    _userPhone = null;
    notifyListeners();
  }

  /// Update user name
  Future<void> updateUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    _userName = name;
    notifyListeners();
  }
}
