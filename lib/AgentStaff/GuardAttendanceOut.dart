import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class GuardAttendanceOut extends StatefulWidget {
  final DateTime checkInTime;
  final Position checkInPosition;
  final String checkInAddress;
  final File checkInPhoto;

  const GuardAttendanceOut({
    Key? key,
    required this.checkInTime,
    required this.checkInPosition,
    required this.checkInAddress,
    required this.checkInPhoto,
  }) : super(key: key);

  @override
  State<GuardAttendanceOut> createState() => _GuardAttendanceOutState();
}

class _GuardAttendanceOutState extends State<GuardAttendanceOut> {
  final ImagePicker _picker = ImagePicker();

  Position? _currentPosition;
  String? _currentAddress;

  File? _checkOutPhoto;
  DateTime? _checkOutTime;

  Timer? _durationTimer;
  Duration _workedDuration = Duration.zero;

  bool _isCapturing = false;
  bool _isSubmitting = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _startDurationTimer();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  // ================= LOCATION =================
  Future<void> _fetchCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = pos;
      _currentAddress = widget.checkInAddress; // formatted already
    });
  }

  // ================= TIMER =================
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _workedDuration =
            DateTime.now().difference(widget.checkInTime);
      });
    });
  }

  String get _formattedDuration {
    final h = _workedDuration.inHours;
    final m = _workedDuration.inMinutes.remainder(60);
    final s = _workedDuration.inSeconds.remainder(60);

    return '${h.toString().padLeft(2, '0')}h '
        '${m.toString().padLeft(2, '0')}m '
        '${s.toString().padLeft(2, '0')}s';
  }

  // ================= CHECK-OUT (STEP-1) =================
  Future<void> _captureCheckoutPhoto() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _checkOutPhoto = File(picked.path);
        _checkOutTime = DateTime.now();
        _durationTimer?.cancel(); // stop timer
      });
    }

    setState(() => _isCapturing = false);
  }

  // ================= SUBMIT (STEP-2) =================
  Future<void> _submitCheckout() async {
    if (_isSubmitting || _checkOutPhoto == null) return;

    setState(() => _isSubmitting = true);

    // 🔗 API CALL READY
    // submitAttendanceOut(
    //   checkInTime: widget.checkInTime,
    //   checkOutTime: _checkOutTime!,
    //   duration: _workedDuration,
    //   location: _currentAddress!,
    //   image: _checkOutPhoto!,
    // );

    await Future.delayed(const Duration(seconds: 1)); // mock delay

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-out submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _isSubmitting = false);

    Navigator.pop(context); // or navigate to dashboard
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy – hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Attendance Checkout',
          style: TextStyle(
            color: Color(0xFF6B46FF),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
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
                  _row('Check-in time', formatter.format(widget.checkInTime)),
                  _row('Check-in address', widget.checkInAddress, isAddress: true),
                  _row(
                    'Status',
                    _checkOutTime == null ? 'Working' : 'Completed',
                  ),
                  _row('Worked duration', _formattedDuration),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                      SizedBox(width: 8),
                      Text(
                        'Live location ready',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _row('Latitude',
                      _currentPosition?.latitude.toStringAsFixed(6) ?? '--'),
                  _row('Longitude',
                      _currentPosition?.longitude.toStringAsFixed(6) ?? '--'),
                  const SizedBox(height: 6),
                  Text(
                    _currentAddress ?? '',
                    style: const TextStyle(color: Color(0xFF1D4ED8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= ACTION =================
            _checkOutPhoto == null
                ? _checkoutButton()
                : _submitButton(),

            const SizedBox(height: 28),

            _photosSection(),
          ],
        ),
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _checkoutButton() {
    return _circleButton(
      icon: Icons.logout,
      label: 'Check-out',
      loading: _isCapturing,
      onTap: _captureCheckoutPhoto,
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B46FF),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isSubmitting ? null : _submitCheckout,
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Submit',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _circleButton({
    required IconData icon,
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF6B46FF),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B46FF).withOpacity(0.45),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _photoBox(widget.checkInPhoto, 'Check-in')),
            const SizedBox(width: 12),
            Expanded(
              child: _checkOutPhoto == null
                  ? _emptyPhoto()
                  : _photoBox(_checkOutPhoto!, 'Check-out'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: isAddress ? null : 2),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x116B46FF),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _photoBox(File photo, String label) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: FileImage(photo), fit: BoxFit.cover),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(8),
      child: _photoLabel(label),
    );
  }

  Widget _emptyPhoto() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
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

  Widget _photoLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
