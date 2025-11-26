import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '/staffPage/attendanceCheckOut.dart';

class AttendanceCheckIn extends StatefulWidget {
  const AttendanceCheckIn({super.key});

  @override
  State<AttendanceCheckIn> createState() => _AttendanceCheckInState();
}

class _AttendanceCheckInState extends State<AttendanceCheckIn> {
  // Location & Address
  Position? _position;
  String? _address;
  String? _state; // State extracted from location
  bool _isLoadingLocation = true;

  // Photo
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  // State Management
  bool _isCheckingIn = false;

  // User Session - Simplified
  String? _userName;
  String? _userMobile;
  bool _isLoadingUser = false;

  bool get _isLocationReady =>
      !_isLoadingLocation && _position != null && (_address?.isNotEmpty ?? false);

  bool get _canSubmitCheckIn => !_isCheckingIn && _isLocationReady;

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
    // Set dummy user data (replace with your actual user management)
    _userName = "Demo User";
    _userMobile = "1234567890";

    await _initLocation();
  }

  /// Initialize location with better error handling
  Future<void> _initLocation() async {
    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _address = 'Location service disabled';
          });
          _showError('Please enable location services in your device settings.');
        }
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _address = 'Location permission denied';
            });
            _showError('Location permission is required for attendance.');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _address = 'Location permission permanently denied';
          });
          _showError('Please enable location permission in app settings.');
        }
        return;
      }

      // Get current position with timeout
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _position = pos;
        });
      }

      // Get address in background
      _fetchAddress(pos);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _address = 'Error getting location';
        });
        debugPrint('Location error: $e');
        _showError('Failed to get location. Please try again.');
      }
    }
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
    // Prevent double-tap
    if (!_canSubmitCheckIn) {
      _showError(_isLoadingLocation
          ? 'Still acquiring location. Please wait a moment.'
          : 'Location unavailable. Pull down to refresh.');
      if (!_isLoadingLocation) {
        _initLocation();
      }
      return;
    }

    setState(() => _isCheckingIn = true);

    try {
      // 1. Capture photo
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked == null) {
        if (mounted) {
          setState(() => _isCheckingIn = false);
        }
        return;
      }

      final photoFile = File(picked.path);
      setState(() => _photo = photoFile);

      // 2. Ensure location is available
      if (_position == null) {
        _showError('Waiting for location...');
        await _initLocation();

        if (_position == null) {
          throw Exception('Unable to get location. Please enable GPS.');
        }
      }

      // 3. Prepare check-in data
      final checkInTime = DateTime.now();
      final employeeName = _userName ?? '';
      final empMob = _userMobile ?? '';

      // Validate required fields
      if (employeeName.isEmpty) {
        throw Exception('Employee name is required.');
      }
      if (empMob.isEmpty) {
        throw Exception('Employee mobile number is required.');
      }
      if (_address == null || _address!.isEmpty) {
        throw Exception('Location address is required.');
      }

      // 4. Save check-in data locally
      await _saveCheckInLocally(
        checkInTime: checkInTime,
        checkInPhoto: photoFile,
        checkInPosition: _position,
        checkInAddress: _address!,
        employeeName: employeeName,
        empMob: empMob,
        state: _state,
      );

      // 5. Show success feedback in UI and navigate
      if (!mounted) return;
      _showSuccess('Check-in completed successfully');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceCheckOut(
            checkInTime: checkInTime,
            checkInPhoto: photoFile,
            checkInPosition: _position,
            checkInAddress: _address,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showError('Check-in failed: ${e.toString()}');
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

              // Welcome message with user name
              Text(
                'Welcome, ${_userName ?? 'User'}!',
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
                  color: _position != null
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _position != null ? 'Acquired' : 'Acquiring...',
                  style: TextStyle(
                    color: _position != null
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
                if (_address != null && _address!.isNotEmpty) ...[
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
                _position != null ? Icons.check_circle : Icons.access_time,
                color: _position != null
                    ? const Color(0xFF16A34A)
                    : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _position != null
                    ? 'Location captured successfully'
                    : 'Acquiring location...',
                style: TextStyle(
                  color: _position != null
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
          _summaryItem('0 h 0 m', 'Today'),
          _summaryItem('42h 15m', 'This Week'),
          _summaryItem('Ready', 'Status'),
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