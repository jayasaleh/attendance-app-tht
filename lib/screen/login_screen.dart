// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    // Cek credential dummy
    final email = _emailCtrl.text.trim();
    final password = _pwdCtrl.text.trim();

    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 1));

    if (email == "jayasaleh@gmail.com" && password == "jayasaleh123") {
      await StorageService().saveUserName("Jaya Saleh");
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/attendance');
    } else {
      setState(() {
        _errorMsg = "Email atau password salah!";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ganti warna background agar tidak terlalu polos
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding * 1.5),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding * 1.5),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- NEW: Logo/Icon Aplikasi ---
                    const Text('Selamat Datang', style: kTitleStyle),
                    const Text(
                      'Silakan login untuk melanjutkan',
                      style: TextStyle(color: kMutedColor),
                    ),
                    const SizedBox(height: kDefaultPadding * 1.5),

                    // --- Email ---
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined), // <-- NEW
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                    ),
                    kGap,

                    // --- Password ---
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline), // <-- NEW
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    if (_errorMsg != null)
                      Text(
                        _errorMsg!,
                        style: const TextStyle(color: kErrorColor),
                      ),

                    if (_errorMsg != null) kGap,

                    // --- Tombol Login ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: kBorderRadius,
                          ),
                        ),
                        onPressed: _loading ? null : _onSubmit,
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'MASUK',
                                style: TextStyle(fontSize: 16),
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
