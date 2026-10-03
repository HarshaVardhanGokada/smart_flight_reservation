import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/country_codes.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  CountryCodeItem _selectedCountry = CountryCodes.defaultCountry;

  final _authService = AuthService();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCountries = CountryCodes.allCountries.where((c) {
              final query = searchQuery.toLowerCase().trim();
              return c.name.toLowerCase().contains(query) ||
                  c.dialCode.contains(query) ||
                  c.code.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Country Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textMuted),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search country or code (e.g. India, +91, +1)...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        fillColor: AppTheme.scaffoldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredCountries.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderColor),
                      itemBuilder: (context, index) {
                        final item = filteredCountries[index];
                        final isSelected = item.dialCode == _selectedCountry.dialCode &&
                            item.code == _selectedCountry.code;

                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: isSelected ? AppTheme.primaryNavy.withValues(alpha: 0.08) : null,
                          leading: Text(
                            item.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          trailing: Text(
                            item.dialCode,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppTheme.primaryNavy : AppTheme.textSecondary,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountry = item;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _initiateSignUpWithPhoneOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final rawPhone = _phoneController.text.trim();
    if (!CountryCodes.isValidPhoneNumber(country: _selectedCountry, rawNumber: rawPhone)) {
      _showSnackbar('Please enter a valid phone number.', isError: true);
      return;
    }

    final formattedE164Phone = CountryCodes.formatE164(
      country: _selectedCountry,
      rawNumber: rawPhone,
    );

    setState(() => _isLoading = true);

    try {
      await _authService.sendPhoneOtp(
        phoneNumber: formattedE164Phone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent successfully to $formattedE164Phone'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                verificationId: verificationId,
                resendToken: resendToken,
                phoneNumber: formattedE164Phone,
                fullName: _nameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              ),
            ),
          );
        },
        onVerificationFailed: (FirebaseAuthException error) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          if (error.code == 'operation-not-allowed') {
            _showFirebaseConfigNotice();
          } else {
            _showSnackbar(_authService.getFirebaseErrorMessage(error), isError: true);
          }
        },
        onVerificationCompleted: (PhoneAuthCredential credential) {
          // Handled if Android auto-retrieves instant verification
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackbar('Unable to send OTP. Please check the phone number and try again.', isError: true);
    }
  }

  void _showFirebaseConfigNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.primaryNavy),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Phone Auth Not Enabled',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase Phone Authentication is not toggled ON in your Firebase Console.\n\n'
              'To enable SMS OTP for any real number:\n'
              '1. Open Firebase Console -> Authentication -> Sign-in method\n'
              '2. Click "Phone" and toggle "Enable"\n'
              '3. Save changes\n\n'
              'Would you like to complete your registration now using Email Verification?',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _signUpWithEmail();
            },
            child: const Text('Create with Email'),
          ),
        ],
      ),
    );
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final rawPhone = _phoneController.text.trim();
    final formattedE164Phone = CountryCodes.formatE164(
      country: _selectedCountry,
      rawNumber: rawPhone,
    );

    setState(() => _isLoading = true);

    try {
      final userModel = await _authService.signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: formattedE164Phone,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (userModel != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Welcome, ${userModel.fullName}'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackbar(_authService.getFirebaseErrorMessage(e), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('An error occurred during account creation. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.dangerRed : AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join Smart Flight',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign up to book flights, track tickets, and receive dynamic e-tickets',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 26),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. Harsha Vardhan',
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (val.trim().length < 2) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'e.g. customer@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email address is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Dynamic Country Code & Phone Number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'e.g. 9876543210',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 6),
                      child: InkWell(
                        onTap: _showCountryPicker,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountry.flag,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedCountry.dialCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textMuted,
                              size: 18,
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: AppTheme.borderColor,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a valid phone number.';
                    }
                    if (!CountryCodes.isValidPhoneNumber(
                      country: _selectedCountry,
                      rawNumber: val.trim(),
                    )) {
                      return 'Please enter a valid phone number.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _hideConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _initiateSignUpWithPhoneOtp(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => setState(
                          () => _hideConfirmPassword = !_hideConfirmPassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Sign Up Action Button
                AppButton(
                  label: 'Verify Phone & Sign Up',
                  isLoading: _isLoading,
                  onPressed: _initiateSignUpWithPhoneOtp,
                ),

                const SizedBox(height: 12),

                // Alternative Direct Sign Up
                AppSecondaryButton(
                  label: 'Sign Up with Email & Password',
                  icon: Icons.email_outlined,
                  onPressed: _isLoading ? null : _signUpWithEmail,
                ),

                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}