import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bookworld/Service/admin_login_service.dart';
import 'package:bookworld/Service/agent_login_service.dart';
import 'package:bookworld/adminPage/admin_page.dart';
import 'package:bookworld/staffPage/staff_page.dart';
import 'package:bookworld/staffPage/attendanceCheckOut.dart';
import 'package:bookworld/SchoolPage/school_page_screen.dart';
import 'package:bookworld/counterPage/counter_main_page.dart';
import 'package:bookworld/home_screen.dart';
import 'package:bookworld/AgentStaff/agentStaffPage.dart';
import 'package:bookworld/AgentStaff/getmanHomePage.dart';

/// Service for securely storing and retrieving user credentials
/// Also handles authentication and auto-login functionality
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Login services
  final AdminLoginService _adminLoginService = AdminLoginService();
  final AgentLoginService _agentLoginService = AgentLoginService();

  // Storage keys
  static const String _keyUserType = 'user_type';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';

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
  static const String _keyStaffMobileNo = 'staff_mobile_no';
  static const String _keyStaffEmail = 'staff_email';

  // School keys
  static const String _keySchoolId = 'school_id';
  static const String _keySchoolUsername = 'school_username';
  static const String _keySchoolPassword = 'school_password';

  // Security Guard specific keys
  static const String _keyGuardName = 'guard_name';
  static const String _keyGuardEmail = 'guard_email';
  static const String _keyGuardRole = 'guard_role';

  // Agent specific keys
  static const String _keyAgentId = 'agent_id';
  static const String _keyAgentEmail = 'agent_email';
  static const String _keyAgentPosition = 'agent_position';

  // Attendance check-in keys
  static const String _keyCheckInStatus = 'checkin_status';
  static const String _keyCheckInTime = 'checkin_time';
  static const String _keyCheckInPhotoPath = 'checkin_photo_path';
  static const String _keyCheckInLatitude = 'checkin_latitude';
  static const String _keyCheckInLongitude = 'checkin_longitude';
  static const String _keyCheckInAddress = 'checkin_address';

  // ===========================================================================
  // ✅ SAVE METHODS
  // ===========================================================================

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

  /// Save staff credentials
  Future<void> saveStaffCredentials({
    required String username,
    required String password,
    String? employeeType,
    String? agentName,
    String? employeeId,
    String? mobileNo,
    String? email,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'staff');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyStaffUsername, value: username);
      await _storage.write(key: _keyStaffPassword, value: password);

      if (employeeType != null) {
        await _storage.write(key: _keyStaffEmployeeType, value: employeeType);
      }

      if (agentName != null) {
        await _storage.write(key: _keyStaffAgentName, value: agentName);
      }

      if (employeeId != null) {
        await _storage.write(key: _keyStaffEmployeeId, value: employeeId);
      }

      if (mobileNo != null) {
        await _storage.write(key: _keyStaffMobileNo, value: mobileNo);
      }

      if (email != null) {
        await _storage.write(key: _keyStaffEmail, value: email);
      }
    } catch (e) {
      throw Exception('Failed to save staff credentials: $e');
    }
  }

  /// ✅ Save Agent credentials
  Future<void> saveAgentCredentials({
    required String employeeId,
    required String mobile,
    required String password,
    required String name,
    required String email,
    required String position,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'agent');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyUserId, value: employeeId);
      await _storage.write(key: _keyStaffEmployeeId, value: employeeId);
      await _storage.write(key: _keyStaffMobileNo, value: mobile);
      await _storage.write(key: _keyStaffPassword, value: password);
      await _storage.write(key: _keyStaffAgentName, value: name);
      await _storage.write(key: _keyAgentEmail, value: email);
      await _storage.write(key: _keyAgentPosition, value: position);
      await _storage.write(key: _keyStaffEmail, value: email);
    } catch (e) {
      throw Exception('Failed to save agent credentials: $e');
    }
  }

  /// ✅ Save Guard credentials
  Future<void> saveGuardCredentials({
    required String employeeId,
    required String mobile,
    required String password,
    required String name,
    required String email,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'guard');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyUserId, value: employeeId);
      await _storage.write(key: _keyStaffEmployeeId, value: employeeId);
      await _storage.write(key: _keyStaffMobileNo, value: mobile);
      await _storage.write(key: _keyStaffPassword, value: password);
      await _storage.write(key: _keyGuardName, value: name);
      await _storage.write(key: _keyGuardEmail, value: email);
      await _storage.write(key: _keyGuardRole, value: 'SECURITY_GUARD');
      await _storage.write(key: _keyStaffEmail, value: email);
    } catch (e) {
      throw Exception('Failed to save guard credentials: $e');
    }
  }

  /// Save Agent/GetMan credentials (Legacy method)
  Future<void> saveAgentGetManCredentials({
    required String mobileNo,
    required String role,
    required String name,
    required String email,
    String? employeeId,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: role.toLowerCase());
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyStaffMobileNo, value: mobileNo);
      await _storage.write(key: _keyStaffEmployeeType, value: role);
      await _storage.write(key: _keyStaffAgentName, value: name);
      await _storage.write(key: _keyStaffEmail, value: email);

      // Always save employeeId - use mobile as fallback if not provided or empty
      final employeeIdToSave = (employeeId != null && employeeId.trim().isNotEmpty)
          ? employeeId.trim()
          : mobileNo;
      await _storage.write(key: _keyStaffEmployeeId, value: employeeIdToSave);
      debugPrint('Saved employeeId to storage: $employeeIdToSave');

      // Save based on role
      if (role == 'AGENT') {
        await _storage.write(key: _keyAgentEmail, value: email);
      } else if (role == 'SECURITY_GUARD') {
        await _storage.write(key: _keyGuardName, value: name);
        await _storage.write(key: _keyGuardEmail, value: email);
      }
    } catch (e) {
      throw Exception('Failed to save Agent/GetMan credentials: $e');
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

  /// Save counter credentials
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

  // ===========================================================================
  // ✅ GET METHODS
  // ===========================================================================

  /// Get admin credentials
  Future<Map<String, String?>> getAdminCredentials() async {
    try {
      final mobileNo = await _storage.read(key: _keyAdminMobileNo);
      final password = await _storage.read(key: _keyAdminPassword);
      final name = await _storage.read(key: _keyAdminName);
      final email = await _storage.read(key: _keyAdminEmail);

      return {
        'mobileNo': mobileNo,
        'password': password,
        'name': name,
        'email': email,
      };
    } catch (e) {
      throw Exception('Failed to get admin credentials: $e');
    }
  }

  /// Get staff credentials
  Future<Map<String, String?>> getStaffCredentials() async {
    try {
      final username = await _storage.read(key: _keyStaffUsername);
      final password = await _storage.read(key: _keyStaffPassword);
      final employeeType = await _storage.read(key: _keyStaffEmployeeType);
      final agentName = await _storage.read(key: _keyStaffAgentName);
      final mobileNo = await _storage.read(key: _keyStaffMobileNo);
      final email = await _storage.read(key: _keyStaffEmail);
      final employeeId = await _storage.read(key: _keyStaffEmployeeId);

      return {
        'username': username,
        'password': password,
        'employeeType': employeeType,
        'agentName': agentName,
        'mobileNo': mobileNo,
        'email': email,
        'employeeId': employeeId,
      };
    } catch (e) {
      throw Exception('Failed to get staff credentials: $e');
    }
  }

  /// ✅ Get all user details
  Future<Map<String, String?>> getUserDetails() async {
    try {
      final userType = await getUserType();

      Map<String, String?> details = {
        'userType': userType,
        'employeeId': await getStaffEmployeeId(),
        'mobile': await getStaffMobileNo(),
        'name': await getStaffName(),
        'email': await getStaffEmail(),
        'role': await getStaffEmployeeType(),
      };

      // Get additional details based on user type
      if (userType == 'guard') {
        details['guardName'] = await _storage.read(key: _keyGuardName);
        details['guardEmail'] = await _storage.read(key: _keyGuardEmail);
      } else if (userType == 'agent') {
        details['agentEmail'] = await _storage.read(key: _keyAgentEmail);
        details['position'] = await _storage.read(key: _keyAgentPosition);
      }

      return details;
    } catch (e) {
      return {};
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

  // ===========================================================================
  // ✅ SPECIFIC GETTERS
  // ===========================================================================

  /// Get staff employee ID
  Future<String?> getStaffEmployeeId() async {
    try {
      final employeeId = await _storage.read(key: _keyStaffEmployeeId);
      return employeeId;
    } catch (e) {
      return null;
    }
  }

  /// Get staff mobile number
  Future<String?> getStaffMobileNo() async {
    try {
      return await _storage.read(key: _keyStaffMobileNo);
    } catch (e) {
      return null;
    }
  }

  /// Get staff employee type
  Future<String?> getStaffEmployeeType() async {
    try {
      return await _storage.read(key: _keyStaffEmployeeType);
    } catch (e) {
      return null;
    }
  }

  /// Get staff name
  Future<String?> getStaffName() async {
    try {
      return await _storage.read(key: _keyStaffAgentName) ??
          await _storage.read(key: _keyGuardName);
    } catch (e) {
      return null;
    }
  }

  /// Get staff email
  Future<String?> getStaffEmail() async {
    try {
      return await _storage.read(key: _keyStaffEmail) ??
          await _storage.read(key: _keyAgentEmail) ??
          await _storage.read(key: _keyGuardEmail);
    } catch (e) {
      return null;
    }
  }

  /// Get staff password
  Future<String?> getStaffPassword() async {
    try {
      return await _storage.read(key: _keyStaffPassword);
    } catch (e) {
      return null;
    }
  }

  /// Get guard name
  Future<String?> getGuardName() async {
    try {
      return await _storage.read(key: _keyGuardName);
    } catch (e) {
      return null;
    }
  }

  /// Get guard email
  Future<String?> getGuardEmail() async {
    try {
      return await _storage.read(key: _keyGuardEmail);
    } catch (e) {
      return null;
    }
  }

  /// Get agent email
  Future<String?> getAgentEmail() async {
    try {
      return await _storage.read(key: _keyAgentEmail);
    } catch (e) {
      return null;
    }
  }

  // ===========================================================================
  // ✅ CHECK-IN METHODS
  // ===========================================================================

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

  // ===========================================================================
  // ✅ UTILITY METHODS
  // ===========================================================================

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

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId) ??
          await getStaffEmployeeId();
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored credentials
  Future<void> clearAllCredentials() async {
    try {
      // Clear authentication keys
      await _storage.delete(key: _keyUserType);
      await _storage.delete(key: _keyIsLoggedIn);
      await _storage.delete(key: _keyUserId);

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
      await _storage.delete(key: _keyStaffEmail);

      // Clear school credentials
      await _storage.delete(key: _keySchoolId);
      await _storage.delete(key: _keySchoolUsername);
      await _storage.delete(key: _keySchoolPassword);

      // Clear guard credentials
      await _storage.delete(key: _keyGuardName);
      await _storage.delete(key: _keyGuardEmail);
      await _storage.delete(key: _keyGuardRole);

      // Clear agent credentials
      await _storage.delete(key: _keyAgentId);
      await _storage.delete(key: _keyAgentEmail);
      await _storage.delete(key: _keyAgentPosition);

      // Clear check-in data
      await clearCheckInData();
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }

  // ===========================================================================
  // ✅ AUTHENTICATION METHODS
  // ===========================================================================

  /// Logout user (alias for clearAllCredentials)
  Future<void> logout() async {
    await clearAllCredentials();
  }

  /// Check login status (alias for isLoggedIn)
  Future<bool> checkLoginStatus() async {
    return await isLoggedIn();
  }

  /// Get current user type (alias for getUserType)
  Future<String?> getCurrentUserType() async {
    return await getUserType();
  }

  /// -------------------------------------------------------------------------
  /// Decide Initial Screen (Auto-login)
  /// -------------------------------------------------------------------------
  Future<Widget> getInitialScreen() async {
    try {
      final isLoggedIn = await this.isLoggedIn();

      if (!isLoggedIn) return const HomeScreen();

      final userType = await getUserType();

      switch (userType) {
        case 'admin':
          return await _getAdminScreen();

        case 'staff':
          return await _getStaffScreen();

        case 'school':
          return await _getSchoolScreen();

        case 'counter':
          return const CounterMainPage();

        default:
          return const HomeScreen();
      }
    } catch (e) {
      return const HomeScreen();
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → Admin Section
  /// -------------------------------------------------------------------------
  Future<Widget> _getAdminScreen() async {
    try {
      final credentials = await getAdminCredentials();
      final mobileNo = credentials['mobileNo'];
      final password = credentials['password'];

      if (mobileNo == null || password == null) {
        await clearAllCredentials();
        return const HomeScreen();
      }

      final loginResponse = await _adminLoginService.performLogin(
        mobileNo: mobileNo,
        password: password,
      );

      if (loginResponse.isSuccess) {
        return AdminPage(userData: loginResponse);
      } else {
        await clearAllCredentials();
        return const HomeScreen();
      }
    } catch (e) {
      await clearAllCredentials();
      return const HomeScreen();
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → Staff (AgentStaff / Staff)
  /// -------------------------------------------------------------------------
  Future<Widget> _getStaffScreen() async {
    try {
      // First check if this is an Agent/SecurityGuard user
      final mobileNo = await getStaffMobileNo();
      final employeeType = await getStaffEmployeeType();

      // If we have Agent/SecurityGuard credentials
      if (mobileNo != null && employeeType != null &&
          (employeeType == "AGENT" || employeeType == "SECURITY_GUARD")) {
        // For Agent/SecurityGuard users, we don't have password stored
        // So we need to redirect to appropriate home page based on role

        if (employeeType == "SECURITY_GUARD") {
          return const getmanHomePage();
        } else {
          return const agentStaffHomePage();
        }
      }

      // Regular staff login flow
      final credentials = await getStaffCredentials();

      final username = credentials['username']; // Mobile
      final password = credentials['password'];
      final empType = credentials['employeeType'] ?? "AgentStaff";

      if (username == null || password == null) {
        await clearAllCredentials();
        return const HomeScreen();
      }

      final loginResponse = await _agentLoginService.login(
        mobile: username,
        password: password,
        position: empType,
      );

      if (loginResponse != null && loginResponse.status == "Success") {
        // Check if user has already checked in
        final hasCheckedIn = await this.hasCheckedIn();

        if (hasCheckedIn) {
          // Load check-in data and navigate to checkout page
          try {
            final checkInData = await getCheckInData();
            final checkoutScreen = await _buildCheckoutScreen(checkInData);

            // Validate that we got a valid checkout screen
            if (checkoutScreen is AttendanceCheckOut) {
              return checkoutScreen;
            }
            // If invalid, fall through to StaffPage
          } catch (e) {
            SecureStorageService.debugPrint('Error loading check-in data: $e');
            await clearCheckInData();
            // Fall through to StaffPage
          }
        }

        // No check-in found or error loading check-in, show normal StaffPage
        return StaffPage(
          agentName: loginResponse.agentName,
          employeeType: loginResponse.employeeType,
          email: loginResponse.agentAdminEmail,
          password: loginResponse.agentPassword,
          mobile: username, // ← MUST PASS to avoid LateInitializationError
        );
      } else {
        await clearAllCredentials();
        return const HomeScreen();
      }
    } catch (e) {
      await clearAllCredentials();
      return const HomeScreen();
    }
  }

  /// Build checkout screen from saved check-in data
  Future<Widget> _buildCheckoutScreen(Map<String, String?> checkInData) async {
    try {
      // Parse check-in time
      final checkInTimeStr = checkInData['time'];
      if (checkInTimeStr == null || checkInTimeStr.isEmpty) {
        throw Exception('Check-in time not found');
      }
      final checkInTime = DateTime.parse(checkInTimeStr);

      // Parse photo path
      final photoPath = checkInData['photoPath'];
      File? checkInPhoto;
      if (photoPath != null && photoPath.isNotEmpty) {
        final photoFile = File(photoPath);
        if (photoFile.existsSync()) {
          checkInPhoto = photoFile;
        }
      }

      // Parse position
      final latStr = checkInData['latitude'];
      final lngStr = checkInData['longitude'];
      Position? checkInPosition;
      if (latStr != null && lngStr != null) {
        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);
        if (lat != null && lng != null && lat.isFinite && lng.isFinite) {
          checkInPosition = Position(
            latitude: lat,
            longitude: lng,
            timestamp: checkInTime,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }

      // Get address
      final address = checkInData['address'] ?? 'Location not available';

      return AttendanceCheckOut(
        checkInTime: checkInTime,
        checkInPhoto: checkInPhoto,
        checkInPosition: checkInPosition,
        checkInAddress: address,
      );
    } catch (e) {
      // If there's an error loading check-in data, clear it and return null
      // This will fallback to StaffPage
      SecureStorageService.debugPrint('Error building checkout screen from saved data: $e');
      await clearCheckInData();
      return const SizedBox.shrink(); // Will be replaced by StaffPage
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → School
  /// -------------------------------------------------------------------------
  Future<Widget> _getSchoolScreen() async {
    return const SchoolPageScreen();
  }

  /// ✅ Check if employee ID exists
  Future<bool> hasEmployeeId() async {
    try {
      final employeeId = await getStaffEmployeeId();
      return employeeId != null && employeeId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ✅ Print all stored data (for debugging)
  Future<void> printAllStorage() async {
    try {
      final allKeys = await _storage.readAll();
      debugPrint('=== Secure Storage Contents ===');
      allKeys.forEach((key, value) {
        debugPrint('$key: $value');
      });
      debugPrint('===============================');
    } catch (e) {
      debugPrint('Error reading storage: $e');
    }
  }

  // Add this at the top of your class for debugging
  static void debugPrint(String message) {
    print('[SecureStorageService] $message');
  }
}