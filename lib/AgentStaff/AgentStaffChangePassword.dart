import 'package:flutter/material.dart';
import '/Service/staffChangePassword.dart';

class Agentstaffchangepassword extends StatefulWidget {
  final String mobileNo;

  const Agentstaffchangepassword({
    super.key,
    required this.mobileNo,
  });

  @override
  State<Agentstaffchangepassword> createState() =>
      _AgentstaffchangepasswordState();
}

class _AgentstaffchangepasswordState
    extends State<Agentstaffchangepassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController =
  TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _oldPassVisible = false;
  bool _newPassVisible = false;
  bool _confirmPassVisible = false;
  bool _loading = false;

  // ===================== CHANGE PASSWORD =====================
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Extra safety check
    if (_oldPasswordController.text.trim() ==
        _newPasswordController.text.trim()) {
      _showSnackBar(
        "New password must be different from old password",
        Colors.orange,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ChangePasswordService.changePassword(
        mobileNo: widget.mobileNo, // ✅ Dynamic mobile
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      _showSnackBar(
        result.message,
        result.status == "Success" ? Colors.green : Colors.red,
      );

      if (result.status == "Success") {
        // Clear fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Go back
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(
        "Something went wrong! Please try again.",
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===================== SNACKBAR =====================
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================== DISPOSE =====================
  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Update your password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // OLD PASSWORD
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_oldPassVisible,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _oldPassVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() =>
                      _oldPassVisible = !_oldPassVisible);
                    },
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter old password" : null,
              ),

              const SizedBox(height: 15),

              // NEW PASSWORD
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_newPassVisible,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newPassVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() =>
                      _newPassVisible = !_newPassVisible);
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Enter new password";
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPassVisible,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPassVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() =>
                      _confirmPassVisible = !_confirmPassVisible);
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Re-enter new password";
                  }
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // SUBMIT BUTTON
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
