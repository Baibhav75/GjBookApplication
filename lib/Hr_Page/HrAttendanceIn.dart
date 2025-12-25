import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'HrAttendanceOut.dart';
import '../Service/hr_attendance_service.dart';
import '../Model/hr_attendance_in_model.dart';

class HrAttendanceIn extends StatefulWidget {
  final String guardName;

  const HrAttendanceIn({Key? key, required this.guardName}) : super(key: key);

  @override
  State<HrAttendanceIn> createState() => _HrAttendanceInState();
}

class _HrAttendanceInState extends State<HrAttendanceIn> {
  final ImagePicker _picker = ImagePicker();

  Position? _position;
  String? _address;

  bool _loadingLocation = false;
  bool _checkingIn = false;

  String get _time => DateFormat.jm().format(DateTime.now());
  String get _date => DateFormat('EEE, MMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  // ================= LOCATION =================
  Future<void> _fetchLocation() async {
    try {
      setState(() => _loadingLocation = true);

      if (!await Geolocator.isLocationServiceEnabled()) {
        _showError('Please enable GPS');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showError('Location permission required');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);

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
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
      }

      setState(() {
        _position = pos;
        _address = fullAddress;
      });
    } catch (e) {
      debugPrint('LOCATION ERROR: $e');
      _showError('Failed to get location');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // ================= CHECK-IN =================
  Future<void> _checkIn() async {
    if (_position == null || _address == null) {
      _showError('Location not ready');
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() => _checkingIn = true);

    try {
      final HrAttendanceInResponse response =
      await HrAttendanceService.markCheckIn(
        employeeId: 'GJ1', // TODO: get from SecureStorage
        mobile: '8840624361', // TODO: get from SecureStorage
        employeeName: widget.guardName,
        position: _position!,
        address: _address!,
        image: File(picked.path),
      );

      if (!mounted) return;

      // ❌ BACKEND BUSINESS FAILURE
      // We allow navigation IF the user is "Already Checked-In/Out" to let them see status
      final bool isAlreadyChecked =
          response.message.toLowerCase().contains('already checked');

      if (!response.status && !isAlreadyChecked) {
        _showError(response.message);
        return;
      }

      // ✅ SUCCESS (or Already Checked)
      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(response.message),
          ),
        );
      } else {
        // Show the info message (e.g. "Already Checked-Out")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.amber[700],
            content: Text(response.message),
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HrAttendanceOut(
            // If API didn't return time (failure case), use Now
            checkInTime: response.checkInTime ?? DateTime.now(),
            checkInPhoto: File(picked.path),
            checkInPosition: _position!,
            checkInAddress: _address!,
          ),
        ),
      );
    } catch (e) {
      debugPrint('CHECK-IN ERROR: $e');
      _showError(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Color(0xFF6B46FF),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B46FF)),
            onPressed: _fetchLocation,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Welcome, ${widget.guardName}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B46FF),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _time,
              style:
              const TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
            ),
            Text(_date, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // CHECK-IN BUTTON
            GestureDetector(
              onTap: _checkingIn ? null : _checkIn,
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6B46FF),
                    ),
                    child: _checkingIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            color: Colors.white, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'CHECK-IN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Tap to take photo for check-in',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

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
                            color: Color(0xFF2B6CB0)),
                      ),
                      Chip(
                        label: Text(
                          _position != null ? 'Acquired' : 'Loading',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                        _position != null ? Colors.green : Colors.orange,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _position != null
                        ? 'Lat: ${_position!.latitude}, Lng: ${_position!.longitude}'
                        : '--',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _address ?? 'Fetching address...',
                    style: const TextStyle(color: Color(0xFF2B6CB0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }
}
