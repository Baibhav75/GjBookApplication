// guard_attendance_in.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/Model/guardAttendanceCheckin.dart';
import '/Service/guardattendanceinService.dart';
import 'GuardAttendanceOut.dart';

class GuardAttendanceIn extends StatefulWidget {
  final String guardName;
  final String? employeeId;
  final String? mobile;

  const GuardAttendanceIn({
    Key? key,
    required this.guardName,
    this.employeeId,
    this.mobile,
  }) : super(key: key);

  @override
  State<GuardAttendanceIn> createState() => _GuardAttendanceInState();
}

class _GuardAttendanceInState extends State<GuardAttendanceIn> {
  // State Management
  late GuardAttendanceService _attendanceService;
  final ImagePicker _picker = ImagePicker();

  UserData? _userData;
  Position? _currentPosition;
  String? _currentAddress;
  File? _capturedImage;
  CheckInProcess _process = CheckInProcess.initializing;

  // Constants
  static const _defaultEmployeeId = 'EMP001';
  static const _defaultMobile = '9876543210';

  @override
  void initState() {
    super.initState();
    _initializeApplication();
  }

  Future<void> _initializeApplication() async {
    try {
      _attendanceService = GuardAttendanceService();
      await _loadUserDataFromStorage();
      await _getCurrentLocation();

      setState(() {
        _process = CheckInProcess.ready;
      });

      print('App initialized successfully');
      print('User: ${_userData?.employeeId}, Location: $_currentAddress');
    } catch (e) {
      print('Initialization error: $e');
      setState(() => _process = CheckInProcess.error);
      _showSnackBar('Initialization failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _loadUserDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get Employee ID with fallbacks
      String employeeId =
          widget.employeeId ??
          prefs.getString('employeeId') ??
          prefs.getString('agentMobileNo') ??
          prefs.getString('EmployeeId') ??
          _defaultEmployeeId;

      // Get Mobile Number with fallbacks
      String mobile =
          widget.mobile ??
          prefs.getString('mobile') ??
          prefs.getString('agentMobileNo') ??
          prefs.getString('EmpMobNo') ??
          _defaultMobile;

      // Validate
      if (employeeId.isEmpty) {
        throw Exception('Employee ID not found');
      }

      if (mobile.isEmpty) {
        throw Exception('Mobile number not found');
      }

      setState(() {
        _userData = UserData(
          employeeId: employeeId,
          mobile: mobile,
          name: widget.guardName,
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _process = CheckInProcess.gettingLocation);

      // Check permissions
      await _checkLocationPermissions();

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address
      final address = await _getAddressFromCoordinates(position);

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });

      print('Location acquired: ${position.latitude}, ${position.longitude}');
      print('Address: $address');
    } catch (e) {
      print('Location error: $e');
      setState(() => _process = CheckInProcess.ready);
      _showSnackBar('Location error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _checkLocationPermissions() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. '
        'Please enable them in app settings.',
      );
    }
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isEmpty) {
        return 'Near ${position.latitude.toStringAsFixed(4)}, '
            '${position.longitude.toStringAsFixed(4)}';
      }

      final place = placemarks.first;
      final addressParts = [
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((part) => part != null && part.isNotEmpty).toList();

      return addressParts.isEmpty
          ? 'Location acquired'
          : addressParts.join(', ');
    } catch (e) {
      return 'Location: ${position.latitude.toStringAsFixed(4)}, '
          '${position.longitude.toStringAsFixed(4)}';
    }
  }

  Future<void> _capturePhotoAndCheckIn() async {
    // Validate state
    if (_process == CheckInProcess.processing) return;

    if (_userData == null) {
      _showSnackBar('User data not loaded', isError: true);
      return;
    }

    if (_currentPosition == null) {
      _showSnackBar('Location not available', isError: true);
      await _getCurrentLocation();
      return;
    }

    if (_currentAddress == null || _currentAddress!.isEmpty) {
      _showSnackBar('Address not available', isError: true);
      return;
    }

    try {
      // Capture photo
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        _showSnackBar('No photo captured', isError: true);
        return;
      }

      final imageFile = File(pickedFile.path);
      if (!await imageFile.exists()) {
        _showSnackBar('Image file not found', isError: true);
        return;
      }

      setState(() {
        _capturedImage = imageFile;
        _process = CheckInProcess.processing;
      });

      // Perform check-in
      await _executeCheckIn(imageFile);
    } catch (e) {
      print('Photo capture error: $e');
      setState(() => _process = CheckInProcess.ready);
      _showSnackBar('Failed to capture photo: ${e.toString()}', isError: true);
    }
  }

  Future<void> _executeCheckIn(File imageFile) async {
    try {
      print('=== Executing Check-In ===');

      final result = await _attendanceService.checkIn(
        employeeId: _userData!.employeeId,
        mobile: _userData!.mobile,
        location: _currentAddress!,
        image: imageFile,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      if (!mounted) return;

      if (result.status) {
        // Success
        _showSnackBar(result.message, isError: false);

        print('Check-in successful. Type: ${result.type}');
        print('Check-in time: ${result.checkInTime}');

        // Store attendance data if needed
        if (result.data != null) {
          print('Attendance ID: ${result.data!.id}');
          print('Employee Name: ${result.data!.empName}');
        }

        // Navigate to check-out screen
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GuardAttendanceOut(
              checkInTime: DateTime.now(),
              checkInPhoto: imageFile,
              checkInPosition: _currentPosition!,
              checkInAddress: _currentAddress!,
              employeeId: _userData!.employeeId,
              mobile: _userData!.mobile,
              attendanceId: result.data?.id,
              guardName: widget.guardName,
            ),
          ),
        );
      } else {
        // API returned error
        setState(() {
          _process = CheckInProcess.ready;
          _capturedImage = null;
        });

        _showSnackBar(result.message, isError: true);

        print('Check-in failed: ${result.message}');
      }
    } catch (e) {
      print('Check-in execution error: $e');

      if (mounted) {
        setState(() {
          _process = CheckInProcess.ready;
          _capturedImage = null;
        });

        _showSnackBar('Check-in failed: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _retryInitialization() async {
    setState(() => _process = CheckInProcess.initializing);
    await _initializeApplication();
  }

  // UI Helper Methods
  String get _currentTime => DateFormat.jm().format(DateTime.now());
  String get _currentDate =>
      DateFormat('EEE, MMM d, yyyy').format(DateTime.now());

  Color _getProcessColor() {
    switch (_process) {
      case CheckInProcess.initializing:
      case CheckInProcess.gettingLocation:
        return Colors.blue;
      case CheckInProcess.processing:
        return Colors.orange;
      case CheckInProcess.ready:
        return const Color(0xFF6B46FF);
      case CheckInProcess.error:
        return Colors.red;
    }
  }

  String _getProcessMessage() {
    switch (_process) {
      case CheckInProcess.initializing:
        return 'Initializing...';
      case CheckInProcess.gettingLocation:
        return 'Getting location...';
      case CheckInProcess.processing:
        return 'Processing check-in...';
      case CheckInProcess.ready:
        return _capturedImage != null
            ? 'Photo captured! Tap to submit'
            : 'Tap to check-in';
      case CheckInProcess.error:
        return 'Error occurred. Tap to retry';
    }
  }

  Widget _buildButtonContent() {
    if (_process == CheckInProcess.processing) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (_process == CheckInProcess.initializing ||
        _process == CheckInProcess.gettingLocation) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 8),
          Text(
            'LOADING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    if (_process == CheckInProcess.error) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.white, size: 36),
          SizedBox(height: 8),
          Text(
            'RETRY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _capturedImage != null ? Icons.check_circle : Icons.camera_alt,
          color: Colors.white,
          size: 36,
        ),
        const SizedBox(height: 8),
        Text(
          _capturedImage != null ? 'READY' : 'CHECK-IN',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 3 : 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Attendance Check-In',
          style: TextStyle(
            color: Color(0xFF6B46FF),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B46FF)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B46FF)),
            onPressed: _process == CheckInProcess.ready
                ? _getCurrentLocation
                : null,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (_process == CheckInProcess.initializing) {
      return _buildLoadingScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // User Info
          Column(
            children: [
              Text(
                'Welcome, ${_userData?.name ?? widget.guardName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B46FF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData == null
                    ? 'Loading...'
                    : 'ID: ${_userData!.employeeId}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                _userData == null ? '' : 'Mobile: ${_userData!.mobile}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          // Time and Date
          const SizedBox(height: 10),
          Text(
            _currentTime,
            style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
          ),
          Text(_currentDate, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),

          // Check-In Button
          GestureDetector(
            onTap: _process == CheckInProcess.error
                ? _retryInitialization
                : _process == CheckInProcess.ready
                ? _capturePhotoAndCheckIn
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getProcessColor().withOpacity(0.15),
                  ),
                ),
                Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getProcessColor(),
                    boxShadow: [
                      BoxShadow(
                        color: _getProcessColor().withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _buildButtonContent(),
                ),
              ],
            ),
          ),

          // Status Message
          const SizedBox(height: 16),
          Text(
            _getProcessMessage(),
            style: TextStyle(
              color: _getProcessColor(),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          // Image Preview
          if (_capturedImage != null && _process != CheckInProcess.processing)
            _buildImagePreview(),

          // User Info Card
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'User Information',
            status: _userData == null ? 'Loading' : 'Ready',
            statusColor: _userData == null ? Colors.orange : Colors.green,
            children: [
              Text('Employee ID: ${_userData?.employeeId ?? '...'}'),
              const SizedBox(height: 6),
              Text('Mobile: ${_userData?.mobile ?? '...'}'),
              const SizedBox(height: 6),
              Text('Name: ${_userData?.name ?? '...'}'),
            ],
          ),

          // Location Card
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Current Location',
            status: _currentPosition == null ? 'Not Available' : 'Acquired',
            statusColor: _currentPosition == null ? Colors.red : Colors.green,
            children: [
              if (_currentPosition != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAddress ?? 'Fetching address...',
                      style: const TextStyle(color: Color(0xFF2B6CB0)),
                    ),
                  ),
                ],
              ),
              if (_process == CheckInProcess.gettingLocation)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),

          // Instructions
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Instructions',
            status: 'Important',
            statusColor: Colors.amber,
            children: [
              const Text('1. Ensure GPS is enabled'),
              const SizedBox(height: 4),
              const Text('2. Capture clear photo'),
              const SizedBox(height: 4),
              const Text('3. Stay at location during check-in'),
              const SizedBox(height: 4),
              Text(
                '4. Your ID: ${_userData?.employeeId ?? '...'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B46FF),
                ),
              ),
            ],
          ),

          // Processing Indicator
          if (_process == CheckInProcess.processing)
            _buildProcessingIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46FF)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Initializing Check-In System',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            'User: ${widget.guardName}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _retryInitialization,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Photo Captured',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _capturedImage!,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey[300],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text('Error loading image'),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '✓ Ready for submission',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String status,
    required Color statusColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46FF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF2B6CB0),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 12),
          const Text(
            'Submitting check-in to server...',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Please wait', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            'Employee: ${_userData?.employeeId ?? '...'}',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _capturedImage = null;
    super.dispose();
  }
}

// Supporting Classes
enum CheckInProcess { initializing, gettingLocation, ready, processing, error }

class UserData {
  final String employeeId;
  final String mobile;
  final String name;
  final int? attendanceId;

  UserData({
    required this.employeeId,
    required this.mobile,
    required this.name,
    this.attendanceId,
  });
}
