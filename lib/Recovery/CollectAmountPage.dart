import 'package:flutter/material.dart';
import '../Service/recover_collect_amount_service.dart';
import '../Model/recover_collect_amount_model.dart';
import '../Service/send_payment_otp_service.dart';
import '../Service/verify_payment_otp_service.dart';

class CollectAmountPage extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const CollectAmountPage({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<CollectAmountPage> createState() => _CollectAmountPageState();
}

class _CollectAmountPageState extends State<CollectAmountPage> {
  int _currentStep = 0;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final RecoverCollectAmountService _dueService =
  RecoverCollectAmountService();

  final SendPaymentOtpService _otpService =
  SendPaymentOtpService();

  RecoverCollectAmountModel? _model;

  final VerifyPaymentOtpService _verifyService =
  VerifyPaymentOtpService();

  int? _enteredAmount;
  bool _isVerifying = false;


  bool _isLoading = true;
  bool _isSendingOtp = false;

  String maskedNumber = "OK";

  @override
  void initState() {
    super.initState();
    _fetchDueAmount();
  }

  Future<void> _fetchDueAmount() async {
    final data =
    await _dueService.fetchDueAmount(widget.schoolId);

    if (!mounted) return;

    setState(() {
      _model = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // 🔥 UPDATED SEND OTP FUNCTION
  Future<void> _sendOtp() async {
    final enteredAmount =
        int.tryParse(_amountController.text) ?? 0;

    if (enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    if (enteredAmount >
        (_model?.data?.dueAmount ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amount exceeds due amount")),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    final success = await _otpService.sendOtp(
      widget.schoolId,
      enteredAmount,
    );

    if (!mounted) return;

    setState(() {
      _isSendingOtp = false;
    });

    if (success) {

      _enteredAmount = enteredAmount;   // ✅ ADD THIS LINE HERE

      setState(() {
        _currentStep = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Sent Successfully")),
      );
    }else {
      // The service already prints the error message, but we should show it in UI if possible
      // For now, let's just use a more descriptive generic message or the one from the service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send OTP. Please check if school has a valid email.")),
      );
    }
  }

  Future<void> _verifyOtp() async {

    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final result = await _verifyService.verifyOtp(
      widget.schoolId,
      otp,
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (result != null &&
        result.status?.toLowerCase() == "success") {
      await _fetchDueAmount(); // refresh balance

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Payment Successful"),
          content: Text(result.message ?? "Success"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back
              },
              child: const Text("OK"),
            )
          ],
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?.message ?? "Verification failed. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xff1F4BA5),
        title: Text(
          widget.schoolName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme:
        const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator())
          : AnimatedSwitcher(
        duration:
        const Duration(milliseconds: 300),
        child: _currentStep == 0
            ? _buildPaymentStep()
            : _buildOtpStep(),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            "School: ${widget.schoolName}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _infoTile(
            "Pending Balance",
            "₹ ${_model?.data?.dueAmount ?? 0}",
            Colors.red,
          ),

          const SizedBox(height: 8),

          _infoTile(
            "Total Sale",
            "₹ ${_model?.data?.totalSale ?? 0}",
            Colors.green,
          ),

          const SizedBox(height: 8),

          _infoTile(
            "Total Payment",
            "₹ ${_model?.data?.totalPayment ?? 0}",
            Colors.blue,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _amountController,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
              labelText:
              "Enter Received Amount",
              prefixText: "₹ ",
              filled: true,
              fillColor:
              Color(0xffFFF6E0),
              border:
              OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSendingOtp
                  ? null
                  : _sendOtp,
              style: ElevatedButton
                  .styleFrom(
                backgroundColor:
                const Color(
                    0xff1F4BA5),
                padding:
                const EdgeInsets
                    .symmetric(
                    vertical: 14),
              ),
              child: _isSendingOtp
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                "Send OTP",
                style: TextStyle(
                    color:
                    Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          Text(
            "OTP sent to $maskedNumber",
            style:
            const TextStyle(
                fontSize: 16),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _otpController,
            keyboardType:
            TextInputType.number,
            maxLength: 6,
            textAlign:
            TextAlign.center,
            decoration:
            const InputDecoration(
              hintText:
              "Enter OTP",
              border:
              OutlineInputBorder(),
              counterText: "",
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,   // ✅ UPDATE THIS LINE
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1F4BA5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isVerifying
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                "Verify & Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
      String title,
      String value,
      Color color) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
              fontWeight:
              FontWeight.bold,
              color: color),
        ),
      ],
    );
  }
}