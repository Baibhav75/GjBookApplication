import 'package:flutter/material.dart';
import '/Service/staffChangePassword.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _oldPassVisible = false;
  bool _newPassVisible = false;
  bool _confirmPassVisible = false;

  bool _loading = false;

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await ChangePasswordService.changePassword(
        mobileNo: "9934206403",                    // <-- Change if dynamic
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor:
          result.status == "Success" ? Colors.green : Colors.red,
        ),
      );

      if (result.status == "Success") {
        Navigator.pop(context); // Go back after success
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Old Password
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_oldPassVisible,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _oldPassVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _oldPassVisible = !_oldPassVisible),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter old password" : null,
              ),

              const SizedBox(height: 15),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_newPassVisible,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newPassVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _newPassVisible = !_newPassVisible),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Enter new password";
                  if (value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Confirm Password
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
                    onPressed: () =>
                        setState(() => _confirmPassVisible = !_confirmPassVisible),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Re-enter new password";
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // Submit Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Change Password",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
