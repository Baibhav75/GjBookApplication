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
  static const String _keyStaffAgentName = 'staff_agent_name';
  static const String _keyStaffEmployeeId = 'staff_employee_id';
  static const String _keyStaffMobileNo =
      'staff_mobile_no'; // Added mobile number key

  // School keys
  static const String _keySchoolId = 'school_id';
  static const String _keySchoolUsername = 'school_username';
  static const String _keySchoolPassword = 'school_password';

  // Counter keys (no specific credentials needed, just user type)

  // Attendance check-in keys
  static const String _keyCheckInStatus = 'checkin_status';
  static const String _keyCheckInTime = 'checkin_time';
  static const String _keyCheckInPhotoPath = 'checkin_photo_path';
  static const String _keyCheckInLatitude = 'checkin_latitude';
  static const String _keyCheckInLongitude = 'checkin_longitude';
  static const String _keyCheckInAddress = 'checkin_address';

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

      return {'mobileNo': mobileNo, 'password': password};
    } catch (e) {
      throw Exception('Failed to get admin credentials: $e');
    }
  }

  /// Save staff credentials
  Future<void> saveStaffCredentials({
    required String username,
    required String password,
    String? employeeType,
    String? agentName,
    String? employeeId, // ✅ NEW
    String? mobileNo, // Added mobile number
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'staff');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyStaffUsername, value: username);
      await _storage.write(key: _keyStaffPassword, value: password);
      await _storage.write(key: _keyStaffEmployeeType, value: employeeType);
      await _storage.write(key: _keyStaffAgentName, value: agentName);
      await _storage.write(key: _keyStaffMobileNo, value: mobileNo);
      if (employeeType != null) {
        await _storage.write(key: _keyStaffEmployeeType, value: employeeType);
      }

      if (agentName != null) {
        await _storage.write(key: _keyStaffAgentName, value: agentName);
      }

      if (employeeId != null) {
        await _storage.write(
          key: _keyStaffEmployeeId,
          value: employeeId,
        ); // ✅ SAVE
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
      final agentName = await _storage.read(key: _keyStaffAgentName);
      final mobileNo = await _storage.read(
        key: _keyStaffMobileNo,
      ); // Get mobile number

      return {
        'username': username,
        'password': password,
        'employeeType': employeeType,
        'agentName': agentName,
        'mobileNo': mobileNo, // Include mobile number
      };
    } catch (e) {
      throw Exception('Failed to get staff credentials: $e');
    }
  }

  /// Get staff employee ID
  /// ⭐ Attendance ke liye MOST IMPORTANT
  Future<String?> getStaffMobileNo() async {
    return await _storage.read(key: _keyStaffMobileNo);
  }

  Future<String?> getStaffEmployeeId() async {
    try {
      return await _storage.read(key: _keyStaffEmployeeId);
    } catch (e) {
      return null;
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

      return {'schoolId': schoolId, 'username': username, 'password': password};
    } catch (e) {
      throw Exception('Failed to get school credentials: $e');
    }
  }

  /// Save counter credentials (no user input required)
  Future<void> saveCounterCredentials({
    required String password,
    required String counterId,
  }) async {
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

  /// Save check-in data
  Future<void> saveCheckInData({
    required DateTime checkInTime,
    required String photoPath,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      await _storage.write(key: _keyCheckInStatus, value: 'true');
      await _storage.write(
        key: _keyCheckInTime,
        value: checkInTime.toIso8601String(),
      );
      await _storage.write(key: _keyCheckInPhotoPath, value: photoPath);
      await _storage.write(
        key: _keyCheckInLatitude,
        value: latitude.toString(),
      );
      await _storage.write(
        key: _keyCheckInLongitude,
        value: longitude.toString(),
      );
      await _storage.write(key: _keyCheckInAddress, value: address);
    } catch (e) {
      throw Exception('Failed to save check-in data: $e');
    }
  }

  /// Get check-in data
  Future<Map<String, String?>> getCheckInData() async {
    try {
      final status = await _storage.read(key: _keyCheckInStatus);
      final time = await _storage.read(key: _keyCheckInTime);
      final photoPath = await _storage.read(key: _keyCheckInPhotoPath);
      final latitude = await _storage.read(key: _keyCheckInLatitude);
      final longitude = await _storage.read(key: _keyCheckInLongitude);
      final address = await _storage.read(key: _keyCheckInAddress);

      return {
        'status': status,
        'time': time,
        'photoPath': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };
    } catch (e) {
      throw Exception('Failed to get check-in data: $e');
    }
  }

  /// Check if user has checked in
  Future<bool> hasCheckedIn() async {
    try {
      final status = await _storage.read(key: _keyCheckInStatus);
      return status == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Clear check-in data
  Future<void> clearCheckInData() async {
    try {
      await _storage.delete(key: _keyCheckInStatus);
      await _storage.delete(key: _keyCheckInTime);
      await _storage.delete(key: _keyCheckInPhotoPath);
      await _storage.delete(key: _keyCheckInLatitude);
      await _storage.delete(key: _keyCheckInLongitude);
      await _storage.delete(key: _keyCheckInAddress);
    } catch (e) {
      throw Exception('Failed to clear check-in data: $e');
    }
  }

  /// Clear all stored credentials
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
      await _storage.delete(key: _keyStaffAgentName);
      await _storage.delete(key: _keyStaffEmployeeId);
      await _storage.delete(key: _keyStaffMobileNo);

      // Clear school credentials
      await _storage.delete(key: _keySchoolId);
      await _storage.delete(key: _keySchoolUsername);
      await _storage.delete(key: _keySchoolPassword);

      // Clear check-in data
      await clearCheckInData();
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }
  /// ✅ Save Agent / GetMan credentials (NO PASSWORD)
  Future<void> saveAgentGetManCredentials({
    required String mobileNo,
    required String role, // Agent / GetMan
    required String name,
    required String email,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: role.toLowerCase());
      await _storage.write(key: _keyIsLoggedIn, value: 'true');

      await _storage.write(key: _keyStaffMobileNo, value: mobileNo);
      await _storage.write(key: _keyStaffEmployeeType, value: role);
      await _storage.write(key: _keyStaffAgentName, value: name);
      await _storage.write(key: _keyAdminEmail, value: email);
    } catch (e) {
      throw Exception(
        'Failed to save Agent/GetMan credentials: $e',
      );
    }
  }


}
