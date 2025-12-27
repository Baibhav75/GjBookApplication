import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import '/Service/guardattendanceoutService.dart';
import '/Model/guardAttendanceOutModel.dart';

enum CheckOutProcess {
  initializing,
  ready,
  capturingPhoto,
  submitting,
  success,
  error,
}

class GuardAttendanceOut extends StatefulWidget {
  final DateTime checkInTime;
  final Position checkInPosition;
  final String checkInAddress;
  final File checkInPhoto;
  final String employeeId;
  final String mobile;
  final int? attendanceId;
  final String guardName;

  const GuardAttendanceOut({
    Key? key,
    required this.checkInTime,
    required this.checkInPosition,
    required this.checkInAddress,
    required this.checkInPhoto,
    required this.employeeId,
    required this.mobile,
    this.attendanceId,
    required this.guardName,
  }) : super(key: key);

  @override
  State<GuardAttendanceOut> createState() => _GuardAttendanceOutState();
}

class _GuardAttendanceOutState extends State<GuardAttendanceOut> {
  // Services
  final ImagePicker _picker = ImagePicker();
  late GuardAttendanceOutService _attendanceService;

  // State
  CheckOutProcess _process = CheckOutProcess.initializing;

  // Data
  Position? _currentPosition;
  String? _currentAddress;
  File? _checkOutPhoto;
  DateTime? _checkOutTime;

  // Timer
  Timer? _durationTimer;
  Duration _workedDuration = Duration.zero;

  // API Response
  GuardCheckOutModel? _apiResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _attendanceService = GuardAttendanceOutService();
      await _fetchCurrentLocation();
      _startDurationTimer();

      setState(() => _process = CheckOutProcess.ready);

      print('Check-Out initialized');
      print('Employee: ${widget.employeeId}, Attendance ID: ${widget.attendanceId}');

    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        _process = CheckOutProcess.error;
        _errorMessage = 'Initialization failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  // ================= LOCATION =================
  Future<void> _fetchCurrentLocation() async {
    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
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
                'Please enable them in app settings.'
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address
      final address = await _getAddressFromCoordinates(position);

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });

      print('Location acquired for check-out');

    } catch (e) {
      print('Location error: $e');
      // Use check-in location as fallback
      setState(() {
        _currentAddress = widget.checkInAddress;
        _currentPosition = widget.checkInPosition;
      });
    }
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isEmpty) {
        return 'Near ${position.latitude.toStringAsFixed(4)}, '
            '${position.longitude.toStringAsFixed(4)}';
      }

      final place = placemarks.first;
      final addressParts = [
        place.street,
        place.subLocality,
        place.locality,
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

  // ================= TIMER =================
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _workedDuration = DateTime.now().difference(widget.checkInTime);
        });
      }
    });
  }

  String get _formattedDuration {
    final hours = _workedDuration.inHours;
    final minutes = _workedDuration.inMinutes.remainder(60);
    final seconds = _workedDuration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get _formattedCheckInTime =>
      DateFormat('MMM d, yyyy • hh:mm a').format(widget.checkInTime);

  // ================= CHECK-OUT PROCESS =================
  Future<void> _captureCheckoutPhoto() async {
    if (_process == CheckOutProcess.capturingPhoto) return;

    setState(() {
      _process = CheckOutProcess.capturingPhoto;
      _errorMessage = null;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        throw Exception('No photo captured');
      }

      final imageFile = File(pickedFile.path);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      // Stop timer and record check-out time
      _durationTimer?.cancel();
      final checkOutTime = DateTime.now();

      setState(() {
        _checkOutPhoto = imageFile;
        _checkOutTime = checkOutTime;
        _process = CheckOutProcess.ready;
      });

      print('Check-out photo captured at: $checkOutTime');

    } catch (e) {
      print('Photo capture error: $e');
      setState(() {
        _process = CheckOutProcess.error;
        _errorMessage = 'Failed to capture photo: ${e.toString()}';
      });
    }
  }

  Future<void> _submitCheckout() async {
    // Validate
    if (_checkOutPhoto == null) {
      _showError('Please capture check-out photo first');
      return;
    }

    if (_currentAddress == null || _currentAddress!.isEmpty) {
      _showError('Location not available');
      return;
    }

    if (_currentPosition == null) {
      _showError('GPS coordinates not available');
      return;
    }

    setState(() {
      _process = CheckOutProcess.submitting;
      _errorMessage = null;
    });

    try {
      final result = await _attendanceService.checkOut(
        employeeId: widget.employeeId,
        mobile: widget.mobile,
        attendanceId: widget.attendanceId,
        location: _currentAddress!,
        image: _checkOutPhoto!,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        checkInTime: widget.checkInTime,
      );

      if (!mounted) return;

      if (result.status) {
        // Success
        setState(() {
          _process = CheckOutProcess.success;
          _apiResponse = result;
        });

        _showSnackBar(result.message, isError: false);

        print('Check-out successful');
        print('Work Duration: ${result.workDuration}');
        print('Type: ${result.type}');

        // Auto-navigate after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });

      } else {
        // API returned error
        setState(() {
          _process = CheckOutProcess.ready;
          _errorMessage = result.message;
        });

        _showSnackBar(result.message, isError: true);
        print('Check-out failed: ${result.message}');
      }

    } catch (e) {
      print('Check-out submission error: $e');
      setState(() {
        _process = CheckOutProcess.error;
        _errorMessage = 'Submission failed: ${e.toString()}';
      });
      _showSnackBar('Check-out failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _retryProcess() async {
    setState(() {
      _process = CheckOutProcess.initializing;
      _errorMessage = null;
      _checkOutPhoto = null;
      _checkOutTime = null;
    });

    await _initialize();
    if (_process == CheckOutProcess.ready) {
      _startDurationTimer();
    }
  }

  // ================= UI HELPERS =================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    _showSnackBar(message, isError: true);
  }

  Color _getProcessColor() {
    switch (_process) {
      case CheckOutProcess.initializing:
      case CheckOutProcess.capturingPhoto:
      case CheckOutProcess.submitting:
        return Colors.blue;
      case CheckOutProcess.ready:
        return const Color(0xFF6B46FF);
      case CheckOutProcess.success:
        return Colors.green;
      case CheckOutProcess.error:
        return Colors.red;
    }
  }

  String _getProcessMessage() {
    switch (_process) {
      case CheckOutProcess.initializing:
        return 'Initializing...';
      case CheckOutProcess.ready:
        return _checkOutPhoto == null
            ? 'Ready for Check-Out'
            : 'Ready to Submit';
      case CheckOutProcess.capturingPhoto:
        return 'Capturing Photo...';
      case CheckOutProcess.submitting:
        return 'Submitting Check-Out...';
      case CheckOutProcess.success:
        return 'Check-Out Successful!';
      case CheckOutProcess.error:
        return 'Error Occurred';
    }
  }

  IconData _getProcessIcon() {
    switch (_process) {
      case CheckOutProcess.initializing:
        return Icons.hourglass_empty;
      case CheckOutProcess.ready:
        return _checkOutPhoto == null ? Icons.logout : Icons.cloud_upload;
      case CheckOutProcess.capturingPhoto:
        return Icons.camera_alt;
      case CheckOutProcess.submitting:
        return Icons.cloud_upload;
      case CheckOutProcess.success:
        return Icons.check_circle;
      case CheckOutProcess.error:
        return Icons.error;
    }
  }

  // ================= UI BUILDERS =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Attendance Check-Out',
          style: TextStyle(
            color: Color(0xFF6B46FF),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B46FF)),
          onPressed: _process == CheckOutProcess.submitting
              ? null
              : () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_process == CheckOutProcess.initializing) {
      return _buildLoadingScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Indicator
          _buildStatusCard(),

          // Session Summary
          _buildSessionCard(),

          const SizedBox(height: 16),

          // Location Info
          _buildLocationCard(),

          const SizedBox(height: 28),

          // Action Button
          Center(child: _buildActionButton()),

          const SizedBox(height: 28),

          // Photos Section
          _buildPhotosSection(),

          // Success Details
          if (_process == CheckOutProcess.success && _apiResponse != null)
            _buildSuccessDetails(),

          // Error Message
          if (_errorMessage != null) _buildErrorMessage(),

          const SizedBox(height: 20),
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
            'Preparing Check-Out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            widget.guardName,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 5),
          Text(
            'ID: ${widget.employeeId}',
            style: const TextStyle(
              color: Color(0xFF6B46FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _getProcessColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getProcessColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getProcessIcon(), color: _getProcessColor(), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getProcessMessage(),
              style: TextStyle(
                color: _getProcessColor(),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          if (_checkOutPhoto != null)
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B46FF),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Guard Name', widget.guardName),
          _buildInfoRow('Employee ID', widget.employeeId),
          _buildInfoRow('Mobile', widget.mobile),
          if (widget.attendanceId != null)
            _buildInfoRow('Attendance ID', widget.attendanceId.toString()),
          const Divider(height: 20),
          _buildInfoRow('Check-in Time', _formattedCheckInTime),
          _buildInfoRow('Work Duration', _formattedDuration),
          _buildInfoRow('Status',
              _checkOutPhoto == null
                  ? '🟢 Working'
                  : _process == CheckOutProcess.success
                  ? '✅ Completed'
                  : '🟡 Ready to Submit'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6B46FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B46FF),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _process == CheckOutProcess.ready
                    ? _fetchCurrentLocation
                    : null,
                color: const Color(0xFF6B46FF),
                tooltip: 'Refresh Location',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_currentPosition != null) ...[
            _buildInfoRow('Latitude',
                _currentPosition!.latitude.toStringAsFixed(6)),
            _buildInfoRow('Longitude',
                _currentPosition!.longitude.toStringAsFixed(6)),
            const SizedBox(height: 8),
          ],
          Text(
            _currentAddress ?? 'Fetching location...',
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_process == CheckOutProcess.success) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          icon: const Icon(Icons.home, color: Colors.white),
          label: const Text(
            'Go to Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    if (_process == CheckOutProcess.error) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _retryProcess,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text(
            'Retry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    if (_checkOutPhoto == null) {
      return GestureDetector(
        onTap: _process == CheckOutProcess.ready ? _captureCheckoutPhoto : null,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getProcessColor(),
            boxShadow: [
              BoxShadow(
                color: _getProcessColor().withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_process == CheckOutProcess.capturingPhoto)
                const CircularProgressIndicator(color: Colors.white)
              else
                const Icon(Icons.camera_alt, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                _process == CheckOutProcess.capturingPhoto
                    ? 'Capturing...'
                    : 'Check-Out',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formattedDuration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B46FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _process == CheckOutProcess.ready ? _submitCheckout : null,
        child: _process == CheckOutProcess.submitting
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 12),
            Text('Submitting...'),
          ],
        )
            : const Text(
          'Submit Check-Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Photos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B46FF),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPhotoBox(widget.checkInPhoto, 'Check-In', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                child: _checkOutPhoto == null
                    ? _buildPlaceholderBox('Check-Out\n(Pending)', Colors.purple)
                    : _buildPhotoBox(_checkOutPhoto!, 'Check-Out', Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox(File photo, String label, Color color) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              photo,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 40),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBox(String text, Color color) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, color: color.withOpacity(0.5), size: 40),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDetails() {
    if (_apiResponse == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Check-Out Successful',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_apiResponse!.workDuration != null)
            _buildInfoRow('Work Duration', _apiResponse!.workDuration!),
          if (_apiResponse!.checkOutTime != null)
            _buildInfoRow('Check-out Time',
                DateFormat('MMM d, yyyy • hh:mm a').format(
                    DateTime.parse(_apiResponse!.checkOutTime!)
                )
            ),
          if (_apiResponse!.data != null && _apiResponse!.data!.id != null)
            _buildInfoRow('Record ID', _apiResponse!.data!.id.toString()),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }
}