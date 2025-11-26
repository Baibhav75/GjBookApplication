import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving user credentials
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  // Storage keys
  static const String _keyUserType = 'user_type';
  static const String _keyIsLoggedIn = 'is_logged_in';
  
  // Admin keys
  static const String _keyAdminMobileNo = 'admin_mobile_no';
  static const String _keyAdminPassword = 'admin_password';
  static const String _keyAdminName = 'admin_name';
  static const String _keyAdminEmail = 'admin_email';
  
  // Staff keys
  static const String _keyStaffUsername = 'staff_username';
  static const String _keyStaffPassword = 'staff_password';
  static const String _keyStaffEmployeeType = 'staff_employee_type';
  
  // School keys
  static const String _keySchoolId = 'school_id';
  static const String _keySchoolUsername = 'school_username';
  static const String _keySchoolPassword = 'school_password';
  
  // Counter keys (no specific credentials needed, just user type)

  /// Save admin credentials
  Future<void> saveAdminCredentials({
    required String mobileNo,
    required String password,
    String? adminName,
    String? adminEmail,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'admin');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyAdminMobileNo, value: mobileNo);
      await _storage.write(key: _keyAdminPassword, value: password);
      
      if (adminName != null) {
        await _storage.write(key: _keyAdminName, value: adminName);
      }
      
      if (adminEmail != null) {
        await _storage.write(key: _keyAdminEmail, value: adminEmail);
      }
    } catch (e) {
      throw Exception('Failed to save admin credentials: $e');
    }
  }

  /// Get admin credentials
  Future<Map<String, String?>> getAdminCredentials() async {
    try {
      final mobileNo = await _storage.read(key: _keyAdminMobileNo);
      final password = await _storage.read(key: _keyAdminPassword);
      
      return {
        'mobileNo': mobileNo,
        'password': password,
      };
    } catch (e) {
      throw Exception('Failed to get admin credentials: $e');
    }
  }

  /// Save staff credentials
  Future<void> saveStaffCredentials({
    required String username,
    required String password,
    String? employeeType,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'staff');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyStaffUsername, value: username);
      await _storage.write(key: _keyStaffPassword, value: password);
      
      if (employeeType != null) {
        await _storage.write(key: _keyStaffEmployeeType, value: employeeType);
      }
    } catch (e) {
      throw Exception('Failed to save staff credentials: $e');
    }
  }

  /// Get staff credentials
  Future<Map<String, String?>> getStaffCredentials() async {
    try {
      final username = await _storage.read(key: _keyStaffUsername);
      final password = await _storage.read(key: _keyStaffPassword);
      final employeeType = await _storage.read(key: _keyStaffEmployeeType);
      
      return {
        'username': username,
        'password': password,
        'employeeType': employeeType,
      };
    } catch (e) {
      throw Exception('Failed to get staff credentials: $e');
    }
  }

  /// Save school credentials
  Future<void> saveSchoolCredentials({
    required String schoolId,
    required String username,
    required String password,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'school');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keySchoolId, value: schoolId);
      await _storage.write(key: _keySchoolUsername, value: username);
      await _storage.write(key: _keySchoolPassword, value: password);
    } catch (e) {
      throw Exception('Failed to save school credentials: $e');
    }
  }

  /// Get school credentials
  Future<Map<String, String?>> getSchoolCredentials() async {
    try {
      final schoolId = await _storage.read(key: _keySchoolId);
      final username = await _storage.read(key: _keySchoolUsername);
      final password = await _storage.read(key: _keySchoolPassword);
      
      return {
        'schoolId': schoolId,
        'username': username,
        'password': password,
      };
    } catch (e) {
      throw Exception('Failed to get school credentials: $e');
    }
  }

  /// Save counter credentials (no user input required)
  Future<void> saveCounterCredentials() async {
    try {
      await _storage.write(key: _keyUserType, value: 'counter');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
    } catch (e) {
      throw Exception('Failed to save counter credentials: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _storage.read(key: _keyIsLoggedIn);
      return isLoggedIn == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get current user type
  Future<String?> getUserType() async {
    try {
      return await _storage.read(key: _keyUserType);
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored credentials
  Future<void> clearAllCredentials() async {
    try {
      await _storage.delete(key: _keyUserType);
      await _storage.delete(key: _keyIsLoggedIn);
      
      // Clear admin credentials
      await _storage.delete(key: _keyAdminMobileNo);
      await _storage.delete(key: _keyAdminPassword);
      await _storage.delete(key: _keyAdminName);
      await _storage.delete(key: _keyAdminEmail);
      
      // Clear staff credentials
      await _storage.delete(key: _keyStaffUsername);
      await _storage.delete(key: _keyStaffPassword);
      await _storage.delete(key: _keyStaffEmployeeType);
      
      // Clear school credentials
      await _storage.delete(key: _keySchoolId);
      await _storage.delete(key: _keySchoolUsername);
      await _storage.delete(key: _keySchoolPassword);
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }
}













