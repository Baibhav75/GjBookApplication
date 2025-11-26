import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/Service/admin_login_service.dart';
import 'package:bookworld/Service/agent_login_service.dart';
import 'package:bookworld/adminPage/admin_page.dart';
import 'package:bookworld/staffPage/staff_page.dart';
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
  /// Auto Login → Staff (Agent / Staff)
  /// -------------------------------------------------------------------------
  Future<Widget> _getStaffScreen() async {
    try {
      final credentials = await _storageService.getStaffCredentials();

      final username = credentials['username']; // Mobile
      final password = credentials['password'];
      final employeeType = credentials['employeeType'] ?? "Agent";

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
