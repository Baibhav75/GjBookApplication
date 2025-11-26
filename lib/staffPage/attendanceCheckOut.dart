import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// Checkout screen that completes the attendance flow.
class AttendanceCheckOut extends StatefulWidget {
  const AttendanceCheckOut({
    super.key,
    required this.checkInTime,
    required this.checkInPhoto,
    required this.checkInPosition,
    required this.checkInAddress,
  });

  final DateTime checkInTime;
  final File checkInPhoto;
  final Position? checkInPosition;
  final String? checkInAddress;

  @override
  State<AttendanceCheckOut> createState() => _AttendanceCheckOutState();
}

class _AttendanceCheckOutState extends State<AttendanceCheckOut> {
  final ImagePicker _picker = ImagePicker();

  bool _isCheckingOut = false;
  File? _checkOutPhoto;
  DateTime? _checkOutTime;

  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationFailure('Location service disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _handleLocationFailure('Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _fetchAddress(pos);

      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
      });
    } catch (e) {
      _handleLocationFailure('Unable to fetch current location');
      debugPrint('Checkout location error: $e');
    }
  }

  void _handleLocationFailure(String message) {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = false;
      _currentAddress = message;
    });
  }

  Future<void> _fetchAddress(Position pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isEmpty || !mounted) return;

      final p = placemarks.first;
      final parts = <String?>[
        p.name,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.postalCode,
        p.country,
      ].whereType<String>().where((value) => value.isNotEmpty).toList();

      setState(() {
        _currentAddress = parts.join(', ');
        _isLoadingLocation = false;
      });
    } catch (e) {
      _handleLocationFailure('Address unavailable');
      debugPrint('Checkout geocoding error: $e');
    }
  }

  Future<void> _performCheckOut() async {
    if (_isCheckingOut) return;

    setState(() => _isCheckingOut = true);

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked == null) {
        setState(() => _isCheckingOut = false);
        return;
      }

      final checkoutPhoto = File(picked.path);
      final checkoutTime = DateTime.now();

      if (!mounted) return;
      setState(() {
        _checkOutPhoto = checkoutPhoto;
        _checkOutTime = checkoutTime;
      });

      // TODO: send to backend / persist locally.
      debugPrint(
        'Check-out captured at $checkoutTime from ${_currentAddress ?? 'unknown'}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Check-out completed successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-out failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  Duration get _workedDuration {
    final end = _checkOutTime ?? DateTime.now();
    return end.difference(widget.checkInTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h '
        '${minutes.toString().padLeft(2, '0')}m '
        '${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Attendance Checkout',
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
          _summaryRow('Worked duration', _formatDuration(_workedDuration)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
            Expanded(child: _photoCard('Check-in photo', widget.checkInPhoto)),
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

  Widget _photoCard(String title, File photo) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: FileImage(photo), fit: BoxFit.cover),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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