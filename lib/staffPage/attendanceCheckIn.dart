import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '/staffPage/attendanceCheckOut.dart';
import '/Service/agent_login_service.dart';
import '/Model/agent_login_model.dart';
import '/Service/secure_storage_service.dart';
import '/Model/attendance_checkin_model.dart';
import '/Service/attendance_service.dart';
import '/Service/staff_profile_service.dart';

class AttendanceCheckIn extends StatefulWidget {
  final String? agentName;
  final String? employeeType;
  final String? mobile;

  const AttendanceCheckIn({
    super.key,
    this.agentName,
    this.employeeType,
    this.mobile,
  });

  @override
  State<AttendanceCheckIn> createState() => _AttendanceCheckInState();
}

class _AttendanceCheckInState extends State<AttendanceCheckIn> {
  // Location & Address
  Position? _position;
  String? _address;
  String? _state; // State extracted from location
  bool _isLoadingLocation = false;
  bool _gpsEnabled = false;

  // Photo
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  // State Management
  bool _isCheckingIn = false;

  // User Session - Simplified
  String? _userName;
  String? _userMobile;
  String? _employeeId; // Store actual employee ID
  bool _isLoadingUser = false;

  // API Response Data
  AttendanceCheckInModel? _lastCheckInResponse;
  String? _todayWorkDuration;
  String? _weekWorkDuration;

  bool get _isLocationReady =>
      _gpsEnabled && _position != null && (_address?.isNotEmpty ?? false);

  bool get _canSubmitCheckIn => !_isCheckingIn && _gpsEnabled && _isLocationReady;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }

  /// Initialize screen with user data and location
  Future<void> _initializeScreen() async {
    // Load user data from secure storage
    await _loadUserData();

    // Auto-request permissions and check GPS without blocking
    _initLocation();
  }

  /// Load user data from secure storage
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoadingUser = true);

      final storageService = SecureStorageService();
      final credentials = await storageService.getStaffCredentials();

      if (mounted) {
        setState(() {
          final storedName = widget.agentName ??
              credentials['agentName'] ??
              credentials['username'] ??
              '';
          _userName = storedName.trim().isNotEmpty ? storedName : null;
          _userMobile = widget.mobile ?? credentials['username'] ?? '';
          
          // Try to get employee ID from credentials or use mobile as fallback
          // Mobile number is commonly used as employee ID in many systems
          _employeeId = credentials['employeeId'] ?? _userMobile;
          
          _isLoadingUser = false;
        });
      }
      
      // Try to fetch employee ID from staff profile if mobile is available
      if (_userMobile != null && _userMobile!.isNotEmpty) {
        await _fetchEmployeeId();
      }
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

  /// Fetch employee ID from staff profile API
  Future<void> _fetchEmployeeId() async {
    if (_userMobile == null || _userMobile!.isEmpty) return;
    
    try {
      final staffProfileService = StaffProfileService();
      final profile = await staffProfileService.fetchProfile(_userMobile!);
      
      if (profile != null && profile.employeeId.isNotEmpty && mounted) {
        setState(() {
          _employeeId = profile.employeeId;
        });
        debugPrint('Employee ID fetched: $_employeeId');
      } else {
        // Fallback to mobile number if profile fetch fails
        if (mounted) {
          setState(() {
            _employeeId = _userMobile;
          });
        }
        debugPrint('Using mobile number as Employee ID: $_employeeId');
      }
    } catch (e) {
      debugPrint('Error fetching employee ID: $e');
      // Fallback to mobile number
      if (mounted) {
        setState(() {
          _employeeId = _userMobile;
        });
      }
    }
  }

  /// Initialize location with auto permission and GPS detection
  Future<void> _initLocation() async {
    if (!mounted) return;

    try {
      // 1. Auto-request permission first (non-blocking)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Check GPS status immediately
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      setState(() {
        _gpsEnabled = serviceEnabled;
        _isLoadingLocation = false; // Clear loading state
      });

      // 3. If GPS is OFF, show popup and navigate
      if (!serviceEnabled) {
        _handleGPSDisabled();
        return;
      }

      // 4. If permission denied forever, show popup and navigate
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        _handlePermissionDeniedForever();
        return;
      }

      // 5. If permission still denied, show popup and navigate
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        _handlePermissionDenied();
        return;
      }

      // 6. GPS is ON and permission granted - get location
      _getLocationData();
    } catch (e) {
      if (mounted) {
        debugPrint('Location initialization error: $e');
        _handleGPSDisabled();
      }
    }
  }

  /// Get location data when GPS is enabled
  Future<void> _getLocationData() async {
    try {
      // Get current position with shorter timeout
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      if (mounted) {
        setState(() {
          _position = pos;
          _isLoadingLocation = false;
        });
      }

      // Get address in background
      _fetchAddress(pos);
    } catch (e) {
      if (mounted) {
        debugPrint('Get location error: $e');
        setState(() {
          _address = 'Location unavailable';
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// Handle GPS disabled - show popup and navigate
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
              child: Text(
                'your GPS is Off',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Please on GPS and befour connect it ',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToCheckOut();
            },
            child: const Text(
              'Ok',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B46FF),
              ),
            ),
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
              child: Text(
                'Location Permission',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'कृपया app settings में location permission enable करें।',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToCheckOut();
            },
            child: const Text(
              'ठीक है',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B46FF),
              ),
            ),
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
              child: Text(
                'Permission Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Location permission आवश्यक है attendance के लिए।',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToCheckOut();
            },
            child: const Text(
              'ठीक है',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B46FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to check out page with default values
  void _navigateToCheckOut() {
    if (!mounted) return;
    
    // Create default values for navigation
    final defaultCheckInTime = DateTime.now();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceCheckOut(
          checkInTime: defaultCheckInTime,
          checkInPhoto: _photo, // Can be null if GPS was off before photo capture
          checkInPosition: _position,
          checkInAddress: _address ?? 'Location not available',
        ),
      ),
    );
  }

  /// Fetch address from coordinates
  Future<void> _fetchAddress(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final addressParts = [
          p.name,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((part) => part != null && part.isNotEmpty).toList();

        setState(() {
          _address = addressParts.join(', ');
          // Extract state from administrativeArea
          _state = p.administrativeArea;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'Address unavailable';
          _state = null;
          _isLoadingLocation = false;
        });
      }
      debugPrint('Geocoding error: $e');
    }
  }

  /// Perform check-in with validation
  Future<void> _performCheckIn() async {
    if (!_canSubmitCheckIn) {
      _showError("Location not ready. Please wait.");
      return;
    }

    setState(() => _isCheckingIn = true);

    try {
      // Capture photo
      final pic = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);

      if (pic == null) {
        setState(() => _isCheckingIn = false);
        return;
      }

      final photoFile = File(pic.path);
      
      // Validate image file exists
      if (!photoFile.existsSync()) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Photo file not found. Please try again.");
        return;
      }

      _photo = photoFile;

      // Comprehensive validation of required info
      if (_employeeId == null || _employeeId!.trim().isEmpty) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Employee ID is missing. Please wait or login again.");
        return;
      }

      if (_userMobile == null || _userMobile!.trim().isEmpty) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Mobile number is missing. Please login again.");
        return;
      }

      if (_address == null || _address!.trim().isEmpty) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Location is missing. Please wait for GPS location.");
        return;
      }

      if (_position == null) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("GPS position is missing. Please wait for location.");
        return;
      }

      // Validate coordinates are valid numbers
      if (_position!.latitude.isNaN || _position!.longitude.isNaN || 
          _position!.latitude.isInfinite || _position!.longitude.isInfinite) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Invalid GPS coordinates. Please try again.");
        return;
      }

      final checkInTime = DateTime.now().toIso8601String();
      
      // Validate check-in time is valid
      if (checkInTime.isEmpty) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Invalid check-in time. Please try again.");
        return;
      }

      // Send API with all validated parameters - Use employee ID, not name
      final result = await AttendanceService.markAttendance(
        employeeId: _employeeId!.trim(),
        mobile: _userMobile!.trim(),
        checkInTime: checkInTime,
        location: _address!.trim(),
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        image: photoFile,
      );

      // Validate result
      if (result == null) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        _showError("Check-in failed: No response from server");
        return;
      }

      // Store response data
      if (mounted) {
        setState(() {
          _lastCheckInResponse = result;
          if (result.workDuration != null && result.workDuration!.isNotEmpty) {
            _todayWorkDuration = result.workDuration;
          }
        });
      }

      // Check if status is false
      if (result.status == false) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        
        // Handle specific error messages
        String errorMessage = "Check-in failed. Please try again.";
        
        if (result.message != null && result.message!.isNotEmpty) {
          final msg = result.message!.trim();
          
          // Check for specific server errors
          if (msg.toLowerCase().contains("object reference not set") ||
              msg.toLowerCase().contains("null reference")) {
            errorMessage = "Server error: Required information is missing. Please check all fields and try again.";
          } else if (msg.toLowerCase().contains("employee") || 
                     msg.toLowerCase().contains("not found")) {
            errorMessage = "Employee not found. Please check your login credentials.";
          } else {
            errorMessage = msg;
          }
        }
        
        _showError(errorMessage);
        return;
      }

      // Success - show message
      final successMessage = result.message?.isNotEmpty == true
          ? result.message!
          : "Check-in successful";
      
      if (mounted) {
        _showSuccess(successMessage);
      }

      // Navigate to check out only if mounted
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceCheckOut(
            checkInTime: DateTime.parse(checkInTime),
            checkInPhoto: photoFile,
            checkInPosition: _position!,
            checkInAddress: _address!,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("Check-in error: $e");
      debugPrint("Stack trace: $stackTrace");
      
      if (mounted) {
        setState(() => _isCheckingIn = false);
        _showError("Error: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }



  /// Save check-in data locally
  Future<void> _saveCheckInLocally({
    required DateTime checkInTime,
    required File checkInPhoto,
    required Position? checkInPosition,
    required String checkInAddress,
    required String employeeName,
    required String empMob,
    required String? state,
  }) async {
    // Implement local storage here
    // You can use shared_preferences, hive, or sqflite

    debugPrint('Check-in saved locally:');
    debugPrint('Employee: $employeeName');
    debugPrint('Mobile: $empMob');
    debugPrint('Check-in Time: $checkInTime');
    debugPrint('Location: $checkInAddress');
    debugPrint('State: $state');
    debugPrint('Latitude: ${checkInPosition?.latitude}');
    debugPrint('Longitude: ${checkInPosition?.longitude}');

    // Example using shared_preferences (uncomment if you have the package):
    /*
    final prefs = await SharedPreferences.getInstance();
    final checkInData = {
      'employeeName': employeeName,
      'empMob': empMob,
      'checkInTime': checkInTime.toIso8601String(),
      'checkInLocation': checkInAddress,
      'state': state,
      'latitude': checkInPosition?.latitude,
      'longitude': checkInPosition?.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString('last_checkin', jsonEncode(checkInData));
    */
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Format current time
  String _formattedTime() => DateFormat.jm().format(DateTime.now());

  /// Format current date
  String _formattedDate() => DateFormat('EEE, MMM d, yyyy').format(DateTime.now());

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
        centerTitle: true,
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Color(0xFF6B46FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B46FF)),
            onPressed: _isCheckingIn ? null : _initLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initLocation,
        color: const Color(0xFF6B46FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),

              // Welcome message with logged-in user name
              _isLoadingUser
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6B46FF),
                      ),
                    )
                  : Text(
                      _userName != null && _userName!.trim().isNotEmpty
                          ? 'Welcome, ${_userName!.trim()}!'
                          : 'Welcome!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B46FF),
                      ),
                      textAlign: TextAlign.center,
                    ),

              const SizedBox(height: 12),

              // Time display
              Text(
                _formattedTime(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Date display
              Text(
                _formattedDate(),
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 28),

              _buildCheckInButton(),

              const SizedBox(height: 12),

              // Instruction text
              Text(
                _isCheckingIn
                    ? 'Processing check-in...'
                    : 'Tap to take photo for check-in',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Location card
              _buildLocationCard(),

              const SizedBox(height: 22),

              // Summary card
              _buildSummaryCard(),

              const SizedBox(height: 30),

              // Captured photo preview
              if (_photo != null) _buildPhotoPreview(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  /// Build location information card
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF2B6CB0)),
                  SizedBox(width: 8),
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B6CB0),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        ? const Color(0xFFDC2626)
                        : _position != null
                            ? const Color(0xFF166534)
                            : const Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location details
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latitude:',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      _position != null
                          ? '${_position!.latitude.toStringAsFixed(6)}'
                          : '--',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Longitude:',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      _position != null
                          ? '${_position!.longitude.toStringAsFixed(6)}'
                          : '--',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                if (!_gpsEnabled) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'GPS is turned off. Please enable GPS to get location.',
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (_address != null && _address!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF2B6CB0),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _address!,
                          style: const TextStyle(
                            color: Color(0xFF2B6CB0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Status
          Row(
            children: [
              Icon(
                !_gpsEnabled
                    ? Icons.location_off
                    : _position != null
                        ? Icons.check_circle
                        : Icons.access_time,
                color: !_gpsEnabled
                    ? const Color(0xFFDC2626)
                    : _position != null
                        ? const Color(0xFF16A34A)
                        : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                !_gpsEnabled
                    ? 'GPS is turned off. Please enable GPS.'
                    : _position != null
                        ? 'Location captured successfully'
                        : 'Acquiring location...',
                style: TextStyle(
                  color: !_gpsEnabled
                      ? const Color(0xFFDC2626)
                      : _position != null
                          ? const Color(0xFF16A34A)
                          : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    final isDisabled = !_canSubmitCheckIn;
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
                  (_canSubmitCheckIn ? Colors.purple : Colors.grey)
                      .withOpacity(0.18),
                  Colors.transparent,
                ],
                radius: 0.7,
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
                  color: (isDisabled ? Colors.grey : const Color(0xFF6B46FF))
                      .withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCheckingIn)
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
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
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary card
  Widget _buildSummaryCard() {
    // Get work duration from API response if available
    final todayDuration = _todayWorkDuration?.isNotEmpty == true 
        ? _todayWorkDuration! 
        : '0 h 0 m';
    
    final weekDuration = _weekWorkDuration?.isNotEmpty == true 
        ? _weekWorkDuration! 
        : '0 h 0 m';
    
    final status = _lastCheckInResponse != null && _lastCheckInResponse!.status == true
        ? 'Checked In'
        : 'Ready';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(todayDuration, 'Today'),
          _summaryItem(weekDuration, 'This Week'),
          _summaryItem(status, 'Status'),
        ],
      ),
    );
  }

  /// Build summary item widget
  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF3E8FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_today,
            color: Color(0xFF6B46FF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// Build photo preview widget
  Widget _buildPhotoPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Captured Photo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _photo!,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}