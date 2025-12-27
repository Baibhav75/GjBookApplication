import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../AgentStaff/agentStaffPage.dart';
import '../Service/attendance_out_service.dart';
import '/Service/agent_login_service.dart';
import '/Model/agent_login_model.dart';
import '/Service/secure_storage_service.dart';
import '/Service/staff_profile_service.dart';



/// IT Checkout screen that completes the attendance flow.
class ItAttendanceCheckOut extends StatefulWidget {
  const ItAttendanceCheckOut({
    super.key,
    required this.checkInTime,
    this.checkInPhoto,
    required this.checkInPosition,
    required this.checkInAddress,
    this.employeeId,
  });

  final DateTime checkInTime;
  final File? checkInPhoto;
  final Position? checkInPosition;
  final String? checkInAddress;
  final String? employeeId; // Accept passed employee ID

  @override
  State<ItAttendanceCheckOut> createState() => _ItAttendanceCheckOutState();
}

class _ItAttendanceCheckOutState extends State<ItAttendanceCheckOut> {
  final ImagePicker _picker = ImagePicker();

  bool _isCheckingOut = false;
  File? _checkOutPhoto;
  DateTime? _checkOutTime;

  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = true;

  // Timer for real-time duration update
  DateTime? _lastUpdateTime;

  // User data
  String? _userName;
  String? _userMobile;
  String? _employeeId; // Store actual employee ID

  @override
  void initState() {
    super.initState();
    // Initialize with passed employee ID if available
    _employeeId = widget.employeeId;
    
    _loadUserData();
    _initLocation();
    _startDurationTimer();
  }
  /// Load user data from secure storage
  Future<void> _loadUserData() async {
    try {
      final storageService = SecureStorageService();
      final credentials = await storageService.getStaffCredentials();
      
      // Get mobile number directly from storage first (more reliable for Agent/IT staff)
      final storedMobile = await storageService.getStaffMobileNo();
      
      if (mounted) {
        setState(() {
          _userName = credentials['agentName'];
          
          // Use stored mobile as primary source, fallback to username credential
          _userMobile = (storedMobile != null && storedMobile.isNotEmpty)
              ? storedMobile
              : credentials['username'];
              
          // Use passed employee ID from widget if available, otherwise try credentials
          if (_employeeId == null || _employeeId!.isEmpty) {
             _employeeId = credentials['employeeId'] ?? _userMobile;
          }
        });
        
        debugPrint('Checkout User Data Loaded:');
        debugPrint('Mobile: $_userMobile');
        debugPrint('Employee ID: $_employeeId');
      }
      
      // Try to fetch employee ID from staff profile if mobile is available
      if (_userMobile != null && _userMobile!.isNotEmpty) {
        await _fetchEmployeeId();
      }
    } catch (e) {
      debugPrint('Error loading user data in checkout: $e');
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
        debugPrint('Employee ID fetched in checkout: $_employeeId');
      } else {
        // Fallback to mobile number if profile fetch fails
        if (mounted) {
          setState(() {
            _employeeId = _userMobile;
          });
        }
        debugPrint('Using mobile number as Employee ID in checkout: $_employeeId');
      }
    } catch (e) {
      debugPrint('Error fetching employee ID in checkout: $e');
      // Fallback to mobile number
      if (mounted) {
        setState(() {
          _employeeId = _userMobile;
        });
      }
    }
  }

  @override
  void dispose() {
    _lastUpdateTime = null;
    super.dispose();
  }

  /// Start timer to update duration in real-time (optimized)
  void _startDurationTimer() {
    if (_checkOutTime != null) return; // Stop if checkout completed
    
    _lastUpdateTime = DateTime.now();
    // Update every second for real-time duration display
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _checkOutTime == null) {
        setState(() {
          _lastUpdateTime = DateTime.now();
        });
        _startDurationTimer(); // Recursive call for continuous updates
      }
    });
  }

  /// Initialize location with optimized fetching
  Future<void> _initLocation() async {
    if (!mounted) return;

    try {
      // Check GPS service status
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationFailure('Location service disabled');
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _handleLocationFailure('Location permission denied');
        return;
      }

      // Get position with optimized timeout
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;

      // Update position immediately
      setState(() {
        _currentPosition = pos;
      });

      // Fetch address in parallel (non-blocking)
      _fetchAddress(pos);
    } catch (e) {
      if (mounted) {
        _handleLocationFailure('Unable to fetch current location');
        debugPrint('Checkout location error: $e');
      }
    }
  }

  void _handleLocationFailure(String message) {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = false;
      _currentAddress = message;
    });
  }

  /// Fetch address from coordinates with optimized error handling
  Future<void> _fetchAddress(Position pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => <Placemark>[],
      );

      if (placemarks.isEmpty || !mounted) {
        if (mounted) {
          setState(() {
            _currentAddress = 'Address unavailable';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      final p = placemarks.first;
      // Build address parts more efficiently
      final addressParts = <String>[];
      
      if (p.name?.isNotEmpty ?? false) addressParts.add(p.name!);
      if (p.subLocality?.isNotEmpty ?? false) addressParts.add(p.subLocality!);
      if (p.locality?.isNotEmpty ?? false) addressParts.add(p.locality!);
      if (p.administrativeArea?.isNotEmpty ?? false) {
        addressParts.add(p.administrativeArea!);
      }
      if (p.postalCode?.isNotEmpty ?? false) addressParts.add(p.postalCode!);
      if (p.country?.isNotEmpty ?? false) addressParts.add(p.country!);

      if (mounted) {
        setState(() {
          _currentAddress = addressParts.join(', ');
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _handleLocationFailure('Address unavailable');
        debugPrint('Checkout geocoding error: $e');
      }
    }
  }

  /// Perform checkout with camera and show session summary popup
  Future<void> _performCheckOut() async {
    if (_isCheckingOut || !mounted) return;

    setState(() => _isCheckingOut = true);

    try {
      // Open camera to capture checkout photo
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked == null) {
        if (mounted) {
          setState(() => _isCheckingOut = false);
        }
        return;
      }

      final checkoutPhoto = File(picked.path);
      final checkoutTime = DateTime.now();

      if (!mounted) return;

      // Update state with checkout data
      setState(() {
        _checkOutPhoto = checkoutPhoto;
        _checkOutTime = checkoutTime;
        _lastUpdateTime = checkoutTime; // Stop timer updates
      });

      // Show session summary popup
      await _showSessionSummaryPopup(checkoutTime, checkoutPhoto);

    } catch (e) {
      if (mounted) {
        _showError('Check-out failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  /// Show session summary popup with all relevant information
  Future<void> _showSessionSummaryPopup(DateTime checkoutTime, File checkoutPhoto) async {
    if (!mounted) return;

    final fullFormatter = DateFormat('MMM d, yyyy – hh:mm a');
    final finalDuration = checkoutTime.difference(widget.checkInTime);
    
    // Check if checkout location is valid (calculate before widget tree)
    final isValidCheckoutLocation = (_currentAddress ?? '').isNotEmpty &&
        _currentAddress != 'Address will appear here once available' &&
        _currentAddress != 'Location service disabled' &&
        _currentAddress != 'Location permission denied' &&
        _currentAddress != 'Address unavailable' &&
        _currentAddress != 'Unable to fetch current location';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B46FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF6B46FF),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Check-out Complete',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B46FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Checkout Photo Preview
                if (checkoutPhoto.existsSync())
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      checkoutPhoto,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                if (checkoutPhoto.existsSync()) const SizedBox(height: 20),

                // Session Information
                _buildPopupInfoRow(
                  Icons.access_time,
                  'Check-in Time',
                  fullFormatter.format(widget.checkInTime),
                ),
                const SizedBox(height: 12),
                _buildPopupInfoRow(
                  Icons.logout,
                  'Check-out Time',
                  fullFormatter.format(checkoutTime),
                ),
                const SizedBox(height: 12),
                _buildPopupInfoRow(
                  Icons.timer,
                  'Work Duration',
                  _formatDuration(finalDuration),
                ),
                const SizedBox(height: 12),

                // Location Information
                if ((widget.checkInAddress ?? '').isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    'Check-in Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPopupInfoRow(
                    Icons.location_on,
                    'Address',
                    widget.checkInAddress!,
                    isAddress: true,
                  ),
                  if (widget.checkInPosition != null) ...[
                    const SizedBox(height: 8),
                    _buildPopupInfoRow(
                      Icons.my_location,
                      'Coordinates',
                      '${widget.checkInPosition!.latitude.toStringAsFixed(6)}, ${widget.checkInPosition!.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ],

                // Check-out Location (only if available and valid)
                if (isValidCheckoutLocation) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 24),
                  const Text(
                    'Check-out Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPopupInfoRow(
                    Icons.location_on,
                    'Address',
                    _currentAddress!,
                    isAddress: true,
                  ),
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    _buildPopupInfoRow(
                      Icons.my_location,
                      'Coordinates',
                      '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _saveAndNavigate();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B46FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build info row for popup
  Widget _buildPopupInfoRow(IconData icon, String label, String value, {bool isAddress = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B46FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isAddress ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: isAddress ? null : 2,
                softWrap: true,
                overflow: isAddress ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Save checkout data and navigate to StaffPage
  void _saveAndNavigate() async {
    if (_checkOutTime == null || _checkOutPhoto == null) {
      _showError("Checkout photo missing");
      return;
    }

    // Validate employee ID
    if (_employeeId == null || _employeeId!.trim().isEmpty) {
      _showError("Employee ID is missing. Please wait.");
      return;
    }

    // Validate mobile
    if (_userMobile == null || _userMobile!.trim().isEmpty) {
      _showError("Mobile number is missing.");
      return;
    }

    // Validate address
    if (_currentAddress == null || _currentAddress!.trim().isEmpty) {
      _showError("Location is missing. Please wait for GPS location.");
      return;
    }

    // Validate image file exists
    if (!_checkOutPhoto!.existsSync()) {
      _showError("Checkout photo file not found. Please try again.");
      return;
    }

    final service = AttendanceOutService ();

    final response = await service.submitAttendance(
      employeeId: _employeeId!.trim(),
      mobile: _userMobile!.trim(),
      type: "CheckOut",
      address: (_currentAddress != null && _currentAddress!.trim().isNotEmpty)
          ? _currentAddress!.trim()
          : "Location unavailable",
      timestamp: _checkOutTime!,
      imageFile: _checkOutPhoto,
      lat: _currentPosition?.latitude ?? 0.0,
      lng: _currentPosition?.longitude ?? 0.0,
    );


    // Handle response - always navigate regardless of API response
    if (response == null || response.status == false) {
      final errorMsg = response?.message?.isNotEmpty == true 
          ? response!.message! 
          : "Checkout API failed";
      
      // Log error but don't block navigation
      debugPrint('Checkout API warning: $errorMsg');
      
      // Show a subtle warning but still proceed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Checkout saved. ${errorMsg.isNotEmpty ? errorMsg : ''}"),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show success message only if API succeeded
      _showSuccess("Check-out Completed Successfully");
    }

    // Clear check-in data from storage (checkout completed)
    try {
      final storageService = SecureStorageService();
      await storageService.clearCheckInData();
      debugPrint('Check-in data cleared after checkout');
    } catch (e) {
      debugPrint('Error clearing check-in data: $e');
      // Continue even if clear fails
    }

    // Navigate to StaffPage immediately (don't wait for success message)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _navigateToAgentStaffHomePage();

    });
  }

  /// Navigate to StaffPage with credentials
  Future<void> _navigateToAgentStaffHomePage() async {
    if (!mounted) return;

    try {
      final storageService = SecureStorageService();
      final credentials = await storageService.getStaffCredentials();

      final agentName = credentials['agentName'] ?? _userName ?? '';
      final employeeType = credentials['employeeType'] ?? 'AGENT';
      final email = credentials['email'] ?? '';
      final password = credentials['password'] ?? '';

      // 🔐 Always use stored mobile first
      final mobile =
          await storageService.getStaffMobileNo() ??
              credentials['username'] ??
              _userMobile ??
              '';

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const agentStaffHomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error navigating to agentStaffHomePage: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    }
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

  /// Calculate worked duration with real-time updates
  Duration get _workedDuration {
    final end = _checkOutTime ?? (_lastUpdateTime ?? DateTime.now());
    return end.difference(widget.checkInTime);
  }

  /// Format duration in a user-friendly way
  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00h 00m 00s';
    }

    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    // Format based on duration length
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h '
          '${minutes.toString().padLeft(2, '0')}m '
          '${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}m '
          '${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds.toString().padLeft(2, '0')}s';
    }
  }

  /// Get formatted time difference for display
  String get _formattedWorkDuration {
    return _formatDuration(_workedDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B46FF)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => agentStaffHomePage(), // Your staff page widget
              ),
            );
          },
        ),
        title: const Text(
          'IT Attendance Checkout',
          style: TextStyle(color: Color(0xFF6B46FF)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B46FF)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isCheckingOut ? null : _initLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            _buildLocationCard(),
            const SizedBox(height: 20),
            _buildCheckOutButton(),
            const SizedBox(height: 20),
            _buildCapturedPhotos(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final formatter = DateFormat('MMM d, yyyy – hh:mm a');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 8),
            blurRadius: 24,
            color: Color(0x116B46FF),
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
          _summaryRow('Check-in time', formatter.format(widget.checkInTime)),
          if ((widget.checkInAddress ?? '').isNotEmpty)
            _summaryRow('Check-in address', widget.checkInAddress!),
          _summaryRow('Current status', _checkOutTime == null ? 'Working' : 'Completed'),
          _summaryRow('Worked duration', _formattedWorkDuration),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    // Check if value is likely to overflow (addresses are usually long)
    final isLongText = value.length > 30 || label.toLowerCase().contains('address');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: isLongText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: null,
                  softWrap: true,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: null,
                    softWrap: true,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLocationCard() {
    final labelStyle = TextStyle(
      color: _currentPosition != null ? const Color(0xFF0F9D58) : Colors.orange.shade800,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _currentPosition != null ? Icons.check_circle : Icons.location_searching,
                color: labelStyle.color,
              ),
              const SizedBox(width: 8),
              Text(
                _currentPosition != null ? 'Live location ready' : 'Fetching location...',
                style: labelStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _locationDetail('Latitude', _currentPosition?.latitude.toStringAsFixed(6) ?? '--'),
          _locationDetail('Longitude', _currentPosition?.longitude.toStringAsFixed(6) ?? '--'),
          const SizedBox(height: 8),
          Text(
            _currentAddress ?? 'Address will appear here once available',
            style: const TextStyle(color: Color(0xFF1D4ED8)),
            maxLines: null,
            softWrap: true,
          ),
          if (widget.checkInPosition != null) ...[
            const Divider(height: 24),
            const Text(
              'Check-in location snapshot',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            _locationDetail(
              'Latitude',
              widget.checkInPosition!.latitude.toStringAsFixed(6),
            ),
            _locationDetail(
              'Longitude',
              widget.checkInPosition!.longitude.toStringAsFixed(6),
            ),
            if ((widget.checkInAddress ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.checkInAddress!,
                  style: const TextStyle(color: Color(0xFF1D4ED8)),
                  maxLines: null,
                  softWrap: true,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _locationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutButton() {
    return Center(
      child: GestureDetector(
        onTap: _isCheckingOut ? null : _performCheckOut,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isCheckingOut ? Colors.grey : const Color(0xFF6B46FF),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B46FF).withOpacity(0.4),
                blurRadius: 22,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCheckingOut)
                const CircularProgressIndicator(color: Colors.white)
              else
                const Icon(Icons.logout, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                _isCheckingOut ? 'Processing...' : 'Check-out',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: widget.checkInPhoto != null && widget.checkInPhoto!.existsSync()
                  ? _photoCard('Check-in image', widget.checkInPhoto!)
                  : _emptyPhotoPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _checkOutPhoto == null
                  ? _emptyPhotoPlaceholder()
                  : _photoCard('Check-out photo', _checkOutPhoto!),
            ),
          ],
        ),
      ],
    );
  }

  /// Build photo card with error handling
  Widget _photoCard(String title, File photo) {
    if (!photo.existsSync()) {
      return _emptyPhotoPlaceholder();
    }

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(photo),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading image: $exception');
          },
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _emptyPhotoPlaceholder() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: const Center(
        child: Text(
          'Checkout photo\npending',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B46FF)),
        ),
      ),
    );
  }
}




