import 'package:flutter/material.dart';
import '../Service/counter_change_password_service.dart';
import '../Model/counter_change_password_model.dart';

class CounterChangePasswordPage extends StatefulWidget {
  final String mobileNo;

  const CounterChangePasswordPage({
    Key? key,
    required this.mobileNo,
  }) : super(key: key);

  @override
  State<CounterChangePasswordPage> createState() =>
      _CounterChangePasswordPageState();
}

class _CounterChangePasswordPageState
    extends State<CounterChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController =
  TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // ================= SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      CounterChangePasswordModel response =
      await CounterChangePasswordService.changePassword(
        mobileNo: widget.mobileNo,
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // go back after success
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError("Failed to change password. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _passwordField(
      String label,
      TextEditingController controller,
      bool obscure,
      VoidCallback toggle,
      ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Required field";
        }
        if (value.length < 6) {
          return "Minimum 6 characters required";
        }
        return null;
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.point_of_sale,
                        size: 60, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text(
                      "Counter Password Update",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    _passwordField(
                      "Old Password",
                      _oldPasswordController,
                      _obscureOld,
                          () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: 16),

                    _passwordField(
                      "New Password",
                      _newPasswordController,
                      _obscureNew,
                          () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: "Confirm New Password",
                        prefixIcon:
                        const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required field";
                        }
                        if (value != _newPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                            : const Text(
                          "UPDATE PASSWORD",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
