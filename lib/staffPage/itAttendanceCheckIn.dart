import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../Model/attendance_checkin_model.dart';
import '../Service/attendance_service.dart';
import '/staffPage/attendanceCheckIn.dart';
import '/staffPage/itAttendanceCheckOut.dart';
import '/Service/secure_storage_service.dart';
import '/Service/staff_profile_service.dart';

class ItAttendanceCheckIn extends StatefulWidget {
  final String? agentName;
  final String? employeeType;
  final String? mobile;

  const ItAttendanceCheckIn({
    super.key,
    this.agentName,
    this.employeeType,
    this.mobile,
  });

  @override
  State<ItAttendanceCheckIn> createState() => _ItAttendanceCheckInState();
}

class _ItAttendanceCheckInState extends State<ItAttendanceCheckIn> {
  // Location & Address
  Position? _position;
  String? _address;
  bool _isLoadingLocation = false;
  bool _gpsEnabled = false;

  // Photo
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  // State Management
  bool _isCheckingIn = false;

  // User Session
  String? _userName;
  String? _userMobile;
  String? _employeeId;
  bool _isLoadingUser = false;

  // API Response Data
  AttendanceCheckInModel? _lastCheckInResponse;

  bool get _isLocationReady =>
      _gpsEnabled &&
          _position != null &&
          (_address?.isNotEmpty ?? false);

  bool get _canSubmitCheckIn =>
      !_isCheckingIn && _gpsEnabled && _isLocationReady;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // 1️⃣ Check if already checked in
    final storage = SecureStorageService();
    if (await storage.hasCheckedIn()) {
      if (!mounted) return;
      
      final data = await storage.getCheckInData();
      if (data['time'] != null && data['address'] != null) {
        
        // Reconstruct Position if lat/lng exist (optional for IT but good practice)
        Position? savedPos;
        try {
          if (data['latitude'] != null && data['longitude'] != null) {
            savedPos = Position(
              longitude: double.parse(data['longitude']!),
              latitude: double.parse(data['latitude']!),
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0, 
              altitudeAccuracy: 0, 
              headingAccuracy: 0,
            );
          }
        } catch (e) {
          debugPrint('Error parsing saved position: $e');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ItAttendanceCheckOut(
              checkInTime: DateTime.parse(data['time']!),
              checkInPhoto: data['photoPath'] != null ? File(data['photoPath']!) : null,
              checkInPosition: savedPos,
              checkInAddress: data['address'],
              employeeId: data['employeeId'],
            ),
          ),
        );
        return;
      }
    }

    await _loadUserData();
    _initLocation();

    // Check for pending sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingSync();
    });
  }

  /// Check for pending check-in sync
  Future<void> _checkPendingSync() async {
    try {
      final storage = SecureStorageService();
      final pendingData = await storage.getCheckInData();
      if (pendingData.isNotEmpty) {
        final syncStatus = pendingData['syncStatus'] as String?;
        final hasPending = pendingData['hasPending'] as String?;
        // Check if there's a pending sync that needs to be handled
        if ((syncStatus == 'pending_sync' || hasPending == 'true') && 
            pendingData['status'] == 'true') {
          _showPendingSyncDialog();
        }
      }
    } catch (e) {
      debugPrint('Error checking pending sync: $e');
    }
  }

  void _showPendingSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sync, color: Colors.orange),
            SizedBox(width: 12),
            Text('Pending Check-In'),
          ],
        ),
        content: const Text(
          'You have a check-in that was not synced to the server. '
              'Would you like to sync it now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _syncPendingCheckIn();
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncPendingCheckIn() async {
    try {
      final storage = SecureStorageService();
      await storage.syncPendingCheckIn();
      if (mounted) {
        _showSuccess('Pending check-in synced successfully');
      }
    } catch (e) {
      debugPrint('Error syncing pending check-in: $e');
      if (mounted) {
        _showError('Failed to sync pending check-in: ${e.toString()}');
      }
    }
  }

  /// Load user data from secure storage
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoadingUser = true);

      final storageService = SecureStorageService();
      final credentials = await storageService.getStaffCredentials();
      final storedMobile = await storageService.getStaffMobileNo();

      if (mounted) {
        setState(() {
          final storedName = widget.agentName ??
              credentials?['agentName'] ??
              credentials?['username'] ??
              '';
          _userName = storedName.trim().isNotEmpty ? storedName : null;

          _userMobile = (storedMobile != null && storedMobile.isNotEmpty)
              ? storedMobile
              : widget.mobile ??
              credentials?['username'] ??
              credentials?['mobileNo'] ??
              '';

          String? employeeIdFromCreds = credentials?['employeeId'];
          _employeeId = employeeIdFromCreds?.trim().isNotEmpty == true
              ? employeeIdFromCreds!.trim()
              : null;

          _isLoadingUser = false;
        });
      }

      await _fetchEmployeeIdWithFallbacks();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userName = null;
          _userMobile = '';
          _employeeId = null;
          _isLoadingUser = false;
        });
      }
    }
  }

  /// Fetch employee ID using multiple fallback methods
  Future<void> _fetchEmployeeIdWithFallbacks() async {
    if (!mounted) return;

    try {
      final storage = SecureStorageService();

      // 1️⃣ ONLY: Staff Employee ID from storage
      final storedEmployeeId = await storage.getStaffEmployeeId();
      if (storedEmployeeId != null &&
          storedEmployeeId.trim().isNotEmpty &&
          storedEmployeeId.trim() != _userMobile) {
        setState(() {
          _employeeId = storedEmployeeId.trim();
        });
        debugPrint('✅ EmployeeId from storage: $_employeeId');
        return;
      }

      // 2️⃣ ONLY: Profile API (employeeId field)
      final mobile = _userMobile?.trim();
      if (mobile != null && mobile.isNotEmpty) {
        final profile =
        await StaffProfileService().fetchProfile(mobile);

        if (profile != null &&
            profile.employeeId.trim().isNotEmpty &&
            profile.employeeId.trim() != mobile) {
          setState(() {
            _employeeId = profile.employeeId.trim();
          });
          debugPrint('✅ EmployeeId from profile API: $_employeeId');
          return;
        }
      }

      // ❌ NO mobile fallback
      debugPrint('❌ EmployeeId NOT FOUND (mobile fallback blocked)');
      setState(() {
        _employeeId = null;
      });

    } catch (e) {
      debugPrint('❌ EmployeeId fetch failed: $e');
      setState(() {
        _employeeId = null;
      });
    }
  }






  /// Initialize location
  Future<void> _initLocation() async {
    if (!mounted) return;

    try {
      setState(() => _isLoadingLocation = true);

      final LocationPermission permission = await Geolocator.checkPermission();
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      setState(() {
        _gpsEnabled = serviceEnabled;
      });

      if (!serviceEnabled) {
        _handleGPSDisabled();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        _handlePermissionDeniedForever();
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        _handlePermissionDenied();
        return;
      }

      await _getLocationData();
    } catch (e) {
      debugPrint('Location initialization error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        _handleGPSDisabled();
      }
    }
  }

  /// Get location data
  Future<void> _getLocationData() async {
    if (!mounted) return;
    
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;
      
      setState(() {
        _position = pos;
      });

      await _fetchAddress(pos);
    } catch (e) {
      debugPrint('Get location error: $e');
      if (mounted) {
        setState(() {
          _address = 'Location unavailable';
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// Handle GPS disabled
  void _handleGPSDisabled() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('GPS is Off'),
            ),
          ],
        ),
        content: const Text('Please enable GPS to mark attendance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle permission denied forever
  void _handlePermissionDeniedForever() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_disabled, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Location Permission Required'),
            ),
          ],
        ),
        content: const Text(
            'Please enable location permission in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle permission denied
  void _handlePermissionDenied() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Permission Required'),
            ),
          ],
        ),
        content: const Text('Location permission is required for attendance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Fetch address from coordinates
  Future<void> _fetchAddress(Position pos) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final Placemark p = placemarks.first;
        final addressParts = [
          p.name,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((part) => part != null && part!.isNotEmpty).toList();

        setState(() {
          _address = addressParts.join(', ');
          _isLoadingLocation = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _address = 'Address unavailable';

            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
      if (mounted) {
        setState(() {
          _address = 'Address unavailable';
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// Validate all required fields
  Map<String, dynamic>? _validateCheckInData() {
    final employeeId = _employeeId?.trim();

    if (employeeId == null || employeeId.isEmpty) {
      return {
        'valid': false,
        'error': 'Employee ID not found. Please re-login or contact admin.',
      };
    }

    final mobile = _userMobile?.trim();
    if (mobile == null || mobile.isEmpty) {
      return {
        'valid': false,
        'error': 'Mobile number missing.',
      };
    }

    if (_address == null || _address!.isEmpty) {
      return {
        'valid': false,
        'error': 'Location not available.',
      };
    }

    return {
      'valid': true,
      'employeeId': employeeId,
      'mobile': mobile,
      'address': _address!,
    };
  }


  /// MAIN OPTIMIZED CHECK-IN METHOD////////////////////////////
  /// MAIN OPTIMIZED CHECK-IN METHOD
  Future<void> _performCheckIn() async {
    // 0️⃣ HARD GUARD: Prevent duplicate check-in
    try {
      final storage = SecureStorageService();
      if (await storage.hasCheckedIn()) {
        final checkInData = await storage.getCheckInData();
        final syncStatus = checkInData['syncStatus'];
        
        // If already checked in and synced, redirect to checkout
        if (syncStatus == 'synced' && mounted) {
          final checkInTime = checkInData['time'];
          final checkInPhotoPath = checkInData['photoPath'];
          final checkInAddress = checkInData['address'];
          
          if (checkInTime != null) {
            Position? savedPos;
            try {
              if (checkInData['latitude'] != null && checkInData['longitude'] != null) {
                savedPos = Position(
                  longitude: double.parse(checkInData['longitude']!),
                  latitude: double.parse(checkInData['latitude']!),
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  heading: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  altitudeAccuracy: 0,
                  headingAccuracy: 0,
                );
              }
            } catch (e) {
              debugPrint('Error parsing saved position: $e');
            }
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ItAttendanceCheckOut(
                  checkInTime: DateTime.parse(checkInTime),
                  checkInPhoto: checkInPhotoPath != null ? File(checkInPhotoPath) : null,
                  checkInPosition: savedPos,
                  checkInAddress: checkInAddress,
                  employeeId: _employeeId,
                ),
              ),
            );
            return;
          }
        }
        
        _showError("You have already checked in. Please check out first.");
        return;
      }
    } catch (e) {
      debugPrint('Error checking duplicate check-in: $e');
      // Continue with check-in if error occurs
    }

    // 1️⃣ Quick validation
    if (!_canSubmitCheckIn) {
      _showError("Location not ready. Please wait for GPS.");
      return;
    }

    /// 2️⃣ Validate required fields
    final validation = _validateCheckInData();
    if (validation?['valid'] != true) {
      _showError(validation?['error'] ?? 'Required information is missing.');
      return;
    }

    final String employeeId = validation!['employeeId'] as String;
    final String mobile = validation['mobile'] as String;
    final String address = validation['address'] as String;

    setState(() => _isCheckingIn = true);


    try {
      // 3️⃣ Capture photo
      final XFile? pic = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1024,
      );

      if (pic == null) {
        setState(() => _isCheckingIn = false);
        _showError("Photo is required for check-in.");
        return;
      }

      final File photoFile = File(pic.path);
      if (!photoFile.existsSync()) {
        setState(() => _isCheckingIn = false);
        _showError("Photo file not found.");
        return;
      }

      _photo = photoFile;

      // 4️⃣ Prepare data
      final DateTime checkInTime = DateTime.now();
      final String checkInTimeString = checkInTime.toIso8601String();

      debugPrint("📤 Sending check-in data:");
      debugPrint("   EmployeeId: $employeeId");
      debugPrint("   Mobile: $mobile");

      // 5️⃣ Save locally (IT specific – safe)
      try {
        final storageService = SecureStorageService();
        await storageService.saveItCheckInData(
          checkInTime: checkInTime,
          photoPath: photoFile.path,
          address: address,
          employeeId: employeeId,
          mobile: mobile,
          state: 'NA',
        );
        debugPrint('✅ IT Check-in data saved locally');
      } catch (e) {
        debugPrint('⚠️ Local save failed: $e');
        // Continue even if local save fails
      }

      // 6️⃣ Call API with proper loading state
      AttendanceCheckInModel? apiResult;
      
      try {
        apiResult = await AttendanceService.markAttendance(
          employeeId: employeeId,
          mobile: mobile,
          checkInTime: checkInTimeString,
          location: address,
          image: photoFile,
          state: 'NA',
        );

        if (!mounted) return;
        
        if (apiResult?.status == true) {
          _handleSuccess(checkInTime, photoFile, apiResult!);
        } else {
          _handleApiError(apiResult ?? AttendanceCheckInModel(
            status: false,
            message: "Unknown error occurred",
            type: "unknown",
          ), checkInTime, photoFile);
        }
      } catch (e) {
        debugPrint('API call exception: $e');
        if (!mounted) return;
        _handleApiError(
          AttendanceCheckInModel(
            status: false,
            message: "API call failed: ${e.toString()}",
            type: "exception",
          ),
          checkInTime,
          photoFile,
        );
      }
    } catch (e) {
      debugPrint('Check-in error: $e');
      if (mounted) {
        setState(() => _isCheckingIn = false);
        _showError("Check-in failed: ${e.toString()}");
      }
    }
  }



  /// Handle successful API response
  void _handleSuccess(
      DateTime checkInTime,
      File photoFile,
      AttendanceCheckInModel apiResult,
      ) {
    if (!mounted) return;

    // Reset checking state
    setState(() => _isCheckingIn = false);

    // Mark as synced in local storage
    try {
      SecureStorageService().markCheckInAsSynced();
    } catch (e) {
      debugPrint('Error marking check-in as synced: $e');
    }

    // Show success message
    _showSuccess(apiResult.message ?? 'Checked in successfully!');

    // Navigate to check-out page
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItAttendanceCheckOut(
            checkInTime: checkInTime,
            checkInPhoto: photoFile,
            checkInPosition: _position,
            checkInAddress: _address,
            employeeId: _employeeId?.trim(),
          ),
        ),
      );
    });
  }

  /// Handle API error
  void _handleApiError(
      AttendanceCheckInModel apiResult,
      DateTime checkInTime,
      File photoFile,
      ) {
    if (!mounted) return;

    setState(() => _isCheckingIn = false);

    final String errorMessage = apiResult.message ?? 'Check-in failed';
    final bool isDuplicate = errorMessage.toLowerCase().contains('already') ||
        errorMessage.toLowerCase().contains('duplicate');

    if (isDuplicate) {
      // For duplicate check-in, just navigate
      try {
        SecureStorageService().markCheckInAsSynced();
      } catch (e) {
        debugPrint('Error marking duplicate check-in: $e');
      }

      _showWarning(errorMessage);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ItAttendanceCheckOut(
              checkInTime: checkInTime,
              checkInPhoto: photoFile,
              checkInPosition: _position,
              checkInAddress: _address,
              employeeId: _employeeId?.trim(),
            ),
          ),
        );
      });
    } else {
      // Ask user what to do
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 12),
              Text('Check-In Issue'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage),
              const SizedBox(height: 16),
              const Text(
                'You can still proceed to check-out page.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Stay Here'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItAttendanceCheckOut(
                      checkInTime: checkInTime,
                      checkInPhoto: photoFile,
                      checkInPosition: _position,
                      checkInAddress: _address,
                      employeeId: _employeeId?.trim(),
                    ),
                  ),
                );
              },
              child: const Text('Proceed Anyway'),
            ),
          ],
        ),
      );
    }
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  void _showWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Format time and date
  String _formattedTime() => DateFormat.jm().format(DateTime.now());
  String _formattedDate() =>
      DateFormat('EEE, MMM d, yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B46FF)),
          onPressed: _isCheckingIn ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'IT Attendance',
          style: TextStyle(
              color: Color(0xFF6B46FF), fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B46FF)),
            onPressed: _isCheckingIn ? null : _initLocation,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initLocation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 6),

              // Welcome message
              _isLoadingUser
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Text(
                _userName != null ? 'Welcome, ${_userName!}!' : 'Welcome!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B46FF),
                ),
              ),

              const SizedBox(height: 12),

              // Time display
              Text(
                _formattedTime(),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              // Date display
              Text(
                _formattedDate(),
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 28),

              // Check-in button
              _buildCheckInButton(),

              const SizedBox(height: 12),

              // Instruction
              Text(
                _isCheckingIn ? 'Processing...' : 'Tap to take photo for check-in',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Location card
              _buildLocationCard(),

              const SizedBox(height: 22),

              // Summary card
              _buildSummaryCard(),

              const SizedBox(height: 30),

              // Photo preview
              if (_photo != null) _buildPhotoPreview(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  /// Build check-in button
  Widget _buildCheckInButton() {
    final bool isDisabled = !_canSubmitCheckIn;
    return GestureDetector(
      onTap: isDisabled ? null : _performCheckIn,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDisabled ? Colors.grey : const Color(0xFF6B46FF))
                      .withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDisabled ? Colors.grey.shade400 : const Color(0xFF6B46FF),
              boxShadow: [
                BoxShadow(
                  color: (isDisabled
                      ? Colors.grey
                      : const Color(0xFF6B46FF))
                      .withOpacity(0.3),
                  blurRadius: 20,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCheckingIn)
                  const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3)
                else
                  Icon(
                    isDisabled ? Icons.lock_clock : Icons.camera_alt,
                    color: Colors.white,
                    size: 36,
                  ),
                const SizedBox(height: 8),
                Text(
                  _isCheckingIn
                      ? 'CHECKING IN...'
                      : !_gpsEnabled
                      ? 'GPS OFF'
                      : isDisabled
                      ? 'WAITING GPS'
                      : 'CHECK-IN',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build location card
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E7FF)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF2B6CB0)),
                  SizedBox(width: 8),
                  Text('Current Location',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _gpsEnabled && _position != null
                      ? const Color(0xFFDCFCE7)
                      : !_gpsEnabled
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  !_gpsEnabled
                      ? 'GPS OFF'
                      : _position != null
                      ? 'Acquired'
                      : 'Acquiring...',
                  style: TextStyle(
                    color: !_gpsEnabled
                        ? Colors.red
                        : _position != null
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Latitude:',
                        style: TextStyle(color: Colors.black54)),
                    Text(_position != null
                        ? '${_position!.latitude.toStringAsFixed(6)}'
                        : '--'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Longitude:',
                        style: TextStyle(color: Colors.black54)),
                    Text(_position != null
                        ? '${_position!.longitude.toStringAsFixed(6)}'
                        : '--'),
                  ],
                ),
                if (_address != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Color(0xFF2B6CB0)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_address!)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary card
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Today', '0 h 0 m'),
          _buildSummaryItem('This Week', '0 h 0 m'),
          _buildSummaryItem('Status',
              _lastCheckInResponse?.status == true ? 'Checked In' : 'Ready'),
        ],
      ),
    );
  }

  /// Build summary item
  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF3E8FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today, color: Color(0xFF6B46FF)),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  /// Build photo preview
  Widget _buildPhotoPreview() {
    return Column(
      children: [
        const Text('Captured Photo',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_photo!,
              width: 220, height: 220, fit: BoxFit.cover),
        ),
      ],
    );
  }
}