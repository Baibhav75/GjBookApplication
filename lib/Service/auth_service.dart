import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/Service/admin_login_service.dart';
import 'package:bookworld/Service/agent_login_service.dart';
import 'package:bookworld/adminPage/admin_page.dart';
import 'package:bookworld/staffPage/staff_page.dart';
import 'package:bookworld/staffPage/attendanceCheckOut.dart';
import 'package:bookworld/SchoolPage/school_page_screen.dart';
import 'package:bookworld/counterPage/counter_main_page.dart';
import 'package:bookworld/home_screen.dart';

/// Authentication service to manage user login state and auto-login
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SecureStorageService _storageService = SecureStorageService();
  final AdminLoginService _adminLoginService = AdminLoginService();
  final AgentLoginService _agentLoginService = AgentLoginService();

  /// -------------------------------------------------------------------------
  /// Decide Initial Screen (Auto-login)
  /// -------------------------------------------------------------------------
  Future<Widget> getInitialScreen() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();

      if (!isLoggedIn) return const HomeScreen();

      final userType = await _storageService.getUserType();

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
      final credentials = await _storageService.getAdminCredentials();
      final mobileNo = credentials['mobileNo'];
      final password = credentials['password'];

      if (mobileNo == null || password == null) {
        await _storageService.clearAllCredentials();
        return const HomeScreen();
      }

      final loginResponse = await _adminLoginService.performLogin(
        mobileNo: mobileNo,
        password: password,
      );

      if (loginResponse.isSuccess) {
        return AdminPage(userData: loginResponse);
      } else {
        await _storageService.clearAllCredentials();
        return const HomeScreen();
      }
    } catch (e) {
      await _storageService.clearAllCredentials();
      return const HomeScreen();
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → Staff (AgentStaff / Staff)
  /// -------------------------------------------------------------------------
  Future<Widget> _getStaffScreen() async {
    try {
      final credentials = await _storageService.getStaffCredentials();

      final username = credentials['username']; // Mobile
      final password = credentials['password'];
      final employeeType = credentials['employeeType'] ?? "AgentStaff";

      if (username == null || password == null) {
        await _storageService.clearAllCredentials();
        return const HomeScreen();
      }

      final loginResponse = await _agentLoginService.login(
        mobile: username,
        password: password,
        employeeType: employeeType,
      );

      if (loginResponse != null && loginResponse.status == "Success") {
        // Check if user has already checked in
        final hasCheckedIn = await _storageService.hasCheckedIn();
        
        if (hasCheckedIn) {
          // Load check-in data and navigate to checkout page
          try {
            final checkInData = await _storageService.getCheckInData();
            final checkoutScreen = await _buildCheckoutScreen(checkInData);
            
            // Validate that we got a valid checkout screen
            if (checkoutScreen is AttendanceCheckOut) {
              return checkoutScreen;
            }
            // If invalid, fall through to StaffPage
          } catch (e) {
            debugPrint('Error loading check-in data: $e');
            await _storageService.clearCheckInData();
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
        await _storageService.clearAllCredentials();
        return const HomeScreen();
      }
    } catch (e) {
      await _storageService.clearAllCredentials();
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
      debugPrint('Error building checkout screen from saved data: $e');
      await _storageService.clearCheckInData();
      return const SizedBox.shrink(); // Will be replaced by StaffPage
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → School
  /// -------------------------------------------------------------------------
  Future<Widget> _getSchoolScreen() async {
    return const SchoolPageScreen();
  }

  /// -------------------------------------------------------------------------
  /// Logout
  /// -------------------------------------------------------------------------
  Future<void> logout() async {
    await _storageService.clearAllCredentials();
  }

  /// -------------------------------------------------------------------------
  /// Helpers
  /// -------------------------------------------------------------------------
  Future<bool> checkLoginStatus() async {
    return await _storageService.isLoggedIn();
  }

  Future<String?> getCurrentUserType() async {
    return await _storageService.getUserType();
  }
}
