import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '/Service/guardattendanceinService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GuardAttendanceOut.dart';

class GuardAttendanceIn extends StatefulWidget {
  final String guardName;
  final String? employeeId; // Make nullable
  final String? mobile; // Make nullable

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
  final ImagePicker _picker = ImagePicker();
  late GuardAttendanceService _attendanceService;

  String _employeeId = '';
  String _mobile = '';
  bool _loadingUserData = true;
  bool _initialized = false;

  Position? _position;
  String? _address;
  bool _loadingLocation = false;
  bool _checkingIn = false;
  File? _capturedImage;

  String get _time => DateFormat.jm().format(DateTime.now());
  String get _date => DateFormat('EEE, MMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _attendanceService = GuardAttendanceService();
      await _loadUserData();
      await _fetchLocation();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint("Initialization error: $e");
      _showError('Initialization failed: $e');
    }
  }

  // ================= LOAD USER DATA =================
  Future<void> _loadUserData() async {
    try {
      // First, try to use the parameters passed from constructor
      String? loadedEmployeeId = widget.employeeId;
      String? loadedMobile = widget.mobile;

      // If not provided in constructor, try to get from SharedPreferences
      if (loadedEmployeeId == null || loadedMobile == null) {
        final prefs = await SharedPreferences.getInstance();

        // Try to get from SharedPreferences
        loadedEmployeeId ??= prefs.getString('employeeId');
        loadedMobile ??= prefs.getString('mobile');

        // If still null, use defaults
        loadedEmployeeId ??= prefs.getString('agentMobileNo') ?? 'EMP001';
        loadedMobile ??= prefs.getString('agentMobileNo') ?? '9876543210';
      }

      // Validate that we have required data
      if (loadedEmployeeId == null || loadedEmployeeId.isEmpty) {
        throw Exception('Employee ID is required');
      }

      if (loadedMobile == null || loadedMobile.isEmpty) {
        throw Exception('Mobile number is required');
      }

      setState(() {
        _employeeId = loadedEmployeeId!;
        _mobile = loadedMobile!;
        _loadingUserData = false;
      });
    } catch (e) {
      debugPrint("Error loading user data: $e");
      setState(() {
        _employeeId = 'EMP001';
        _mobile = '9876543210';
        _loadingUserData = false;
      });
      _showError('Could not load user data: $e');
    }
  }

  // ================= LOCATION =================
  Future<void> _fetchLocation() async {
    if (!mounted) return;

    setState(() => _loadingLocation = true);

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
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
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 30));

      // Get address
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint("Geocoding error: $e");
      }

      String fullAddress = 'Address unavailable';
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        fullAddress = [
          p.name,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }

      if (mounted) {
        setState(() {
          _position = pos;
          _address = fullAddress;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
        _showError('Location error: $e');
      }
    }
  }

  // ================= TAKE PHOTO =================
  Future<void> _takePhoto() async {
    // Validate state
    if (!mounted) return;

    if (_loadingUserData) {
      _showError('User data is still loading');
      return;
    }

    if (_loadingLocation) {
      _showError('Location is still loading');
      return;
    }

    if (_position == null) {
      _showError('Location not available. Please enable location services.');
      return;
    }

    if (_address == null || _address!.isEmpty) {
      _showError('Address not available');
      return;
    }

    if (_employeeId.isEmpty) {
      _showError('Employee ID is required');
      return;
    }

    if (_mobile.isEmpty) {
      _showError('Mobile number is required');
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) {
        _showError('No photo captured');
        return;
      }

      File imageFile = File(pickedFile.path);

      // Check if file exists
      bool exists = await imageFile.exists();
      if (!exists) {
        _showError('Captured image file not found');
        return;
      }

      setState(() {
        _capturedImage = imageFile;
      });

      // Automatically call check-in after photo capture
      _performCheckIn();
    } catch (e) {
      debugPrint("Photo capture error: $e");
      _showError('Failed to capture photo: $e');
    }
  }

  // ================= PERFORM CHECK-IN API CALL =================
  Future<void> _performCheckIn() async {
    if (!mounted) return;

    // Validate all required data
    if (_capturedImage == null) {
      _showError('Please capture image first');
      return;
    }

    if (_position == null) {
      _showError('Location not available');
      return;
    }

    if (_address == null || _address!.isEmpty) {
      _showError('Address not available');
      return;
    }

    if (_employeeId.isEmpty) {
      _showError('Employee ID is required');
      return;
    }

    if (_mobile.isEmpty) {
      _showError('Mobile number is required');
      return;
    }

    setState(() => _checkingIn = true);

    try {
      // Call the API
      final result = await _attendanceService.checkIn(
        employeeId: _employeeId,
        mobile: _mobile,
        location: _address!,
        image: _capturedImage!,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
      );

      if (!mounted) return;

      setState(() => _checkingIn = false);

      // Check API response
      if (result.status) {
        // Success - navigate to Check-Out screen
        _showSuccess(result.message ?? 'Check-in successful');

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GuardAttendanceOut(
              checkInTime: DateTime.now(),
              checkInPhoto: _capturedImage!,
              checkInPosition: _position!,
              checkInAddress: _address!,
              /*employeeId: _employeeId,
              mobile: _mobile,*/
            ),
          ),
        );
      } else {
        // API returned error
        _showError(result.message ?? 'Check-in failed');
        // Reset captured image to allow retry
        setState(() {
          _capturedImage = null;
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
      if (mounted) {
        setState(() {
          _checkingIn = false;
          _capturedImage = null;
        });
        _showError('Network error: ${e.toString()}');
      }
    }
  }

  // ================= CHECK-IN PROCESS =================
  Future<void> _checkIn() async {
    // Validate app is mounted
    if (!mounted) return;

    // First take photo
    await _takePhoto();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_initialized) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F5FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Initializing...'),
              const SizedBox(height: 10),
              Text(
                'Loading user: ${widget.guardName}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B46FF)),
            onPressed: _fetchLocation,
            tooltip: 'Refresh Location',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Welcome and Employee Info
            Column(
              children: [
                Text(
                  'Welcome, ${widget.guardName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B46FF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _loadingUserData ? 'Loading user data...' : 'ID: $_employeeId',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _loadingUserData ? '' : 'Mobile: $_mobile',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              _time,
              style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(_date, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // CHECK-IN BUTTON
            GestureDetector(
              onTap: (_checkingIn || _loadingUserData || _loadingLocation)
                  ? null
                  : _checkIn,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6B46FF).withOpacity(0.15),
                    ),
                  ),
                  Container(
                    width: 135,
                    height: 135,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _checkingIn
                          ? Colors.orange
                          : (_capturedImage != null
                          ? Colors.green
                          : const Color(0xFF6B46FF)),
                    ),
                    child: _checkingIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (_loadingLocation || _loadingUserData
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'LOADING...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _capturedImage != null
                              ? Icons.check_circle
                              : Icons.camera_alt,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _capturedImage != null
                              ? 'PROCESSING...'
                              : 'CHECK-IN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _checkingIn
                  ? 'Submitting check-in...'
                  : (_loadingLocation
                  ? 'Fetching location...'
                  : (_loadingUserData
                  ? 'Loading user data...'
                  : (_capturedImage != null
                  ? 'Photo captured! Processing...'
                  : 'Tap to take photo for check-in'))),
              style: TextStyle(
                color: _checkingIn
                    ? Colors.orange
                    : (_loadingLocation || _loadingUserData
                    ? Colors.blue
                    : (_capturedImage != null ? Colors.green : Colors.grey)),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            // Captured Image Preview
            if (_capturedImage != null && !_checkingIn) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Captured Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Image.file(
                      _capturedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // USER INFO CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B6CB0),
                        ),
                      ),
                      Chip(
                        label: Text(
                          _loadingUserData ? 'Loading' : 'Ready',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                        _loadingUserData ? Colors.orange : Colors.green,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Employee ID: ${_loadingUserData ? '...' : _employeeId}'),
                  const SizedBox(height: 6),
                  Text('Mobile: ${_loadingUserData ? '...' : _mobile}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LOCATION CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B6CB0),
                        ),
                      ),
                      Chip(
                        label: Text(
                          _loadingLocation
                              ? 'Loading'
                              : (_position != null ? 'Acquired' : 'Failed'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: _loadingLocation
                            ? Colors.orange
                            : (_position != null ? Colors.green : Colors.red),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _position != null
                        ? 'Lat: ${_position!.latitude.toStringAsFixed(6)}'
                        '\nLng: ${_position!.longitude.toStringAsFixed(6)}'
                        : 'Location not available',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _address ?? 'Fetching address...',
                    style: const TextStyle(color: Color(0xFF2B6CB0)),
                  ),
                  if (_loadingLocation) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                  ]
                ],
              ),
            ),

            // API Status (when checking in)
            if (_checkingIn) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text(
                'Submitting check-in to server...',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    _capturedImage = null;
    super.dispose();
  }
}