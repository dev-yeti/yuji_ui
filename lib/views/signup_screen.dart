import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _mobileController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isSendingOtp = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _generatedOtp; // dev fallback

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify OTP before registering')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _apiService.register(
        _userNameController.text,
        _lastNameController.text,
        _emailController.text,
        _mobileController.text,
        _userIdController.text,
        _passwordController.text,
      );

      final success = result['success'] == true;
      final message = result['message']?.toString() ?? (success ? 'Registration successful' : 'Registration failed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: success ? Colors.green : Colors.redAccent),
      );

      if (success) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email first')),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      final serverResult = await _apiService.sendOtp(email);
      final success = serverResult is Map ? (serverResult['success'] == true) : false;
      if (success) {
        setState(() {
          _isOtpSent = true;
          _isOtpVerified = false;
        });
        return;
      }
    } finally {
      setState(() => _isSendingOtp = false);
    }

    // dev fallback
    _generatedOtp = DateTime.now().millisecondsSinceEpoch.remainder(1000000).toString().padLeft(6, '0');
    setState(() {
      _isOtpSent = true;
      _isOtpVerified = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP (dev): $_generatedOtp')),
    );
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    final serverVerified = await _apiService.verifyOtp(email, otp);
    if (serverVerified) {
      setState(() => _isOtpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified')),
      );
      return;
    }

    if (_generatedOtp != null && otp == _generatedOtp) {
      setState(() => _isOtpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified (dev)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSendingOtp ? null : _sendOtp,
                      child: _isSendingOtp
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white))
                          : const Text('Send OTP'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isOtpSent) Icon(_isOtpVerified ? Icons.check_circle : Icons.lock, color: _isOtpVerified ? Colors.green : Colors.grey),
                ],
              ),
              if (_isOtpSent) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'Enter OTP', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!_isOtpVerified && (value == null || value.isEmpty)) return 'Please enter OTP';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify OTP')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(onPressed: _isSendingOtp ? null : _sendOtp, child: const Text('Resend')),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter mobile number';
                  if (!RegExp(r'^\d{10,}$').hasMatch(value)) return 'Enter a valid mobile number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(labelText: 'User Id', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your user id' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white)) : const Text('Register'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _mobileController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
