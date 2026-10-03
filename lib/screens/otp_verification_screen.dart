import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final int? resendToken;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    this.resendToken,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  late String _currentVerificationId;
  int? _currentResendToken;

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  String _errorMessage = '';

  Timer? _countdownTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _currentResendToken = widget.resendToken;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = 60);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code received via SMS.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      final userModel = await _authService.verifyOtpAndCompleteSignup(
        verificationId: _currentVerificationId,
        smsCode: code,
        fullName: widget.fullName,
        email: widget.email,
        phone: widget.phoneNumber,
        password: widget.password,
      );

      if (!mounted) return;

      if (userModel != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Welcome, ${userModel.fullName}',
            ),
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
      setState(() {
        _errorMessage = _authService.getFirebaseErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Incorrect OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = '';
    });

    await _authService.sendPhoneOtp(
      phoneNumber: widget.phoneNumber,
      resendToken: _currentResendToken,
      onCodeSent: (newVerificationId, newToken) {
        if (!mounted) return;
        setState(() {
          _currentVerificationId = newVerificationId;
          _currentResendToken = newToken;
          _isResending = false;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new 6-digit OTP has been sent via SMS.'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onVerificationFailed: (error) {
        if (!mounted) return;
        setState(() {
          _isResending = false;
          _errorMessage = _authService.getFirebaseErrorMessage(error);
        });
      },
      onVerificationCompleted: (credential) async {
        // Automatic verification (on Android instant retrieval)
        if (credential.smsCode != null) {
          for (int i = 0; i < credential.smsCode!.length && i < 6; i++) {
            _controllers[i].text = credential.smsCode![i];
          }
          await _verifyOtp();
        }
      },
      onCodeAutoRetrievalTimeout: (_) {
        if (mounted) setState(() => _isResending = false);
      },
    );
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // User pasted full code
      final digits = value.replaceAll(RegExp(r'[^\d]'), '');
      for (int i = 0; i < digits.length && i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].unfocus();
        _verifyOtp();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          _verifyOtp();
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // SMS Icon
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Dynamic phone target info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sent 6-digit SMS code to ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Edit Phone Number'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 6-digit OTP Box row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: index == 0,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) => _onDigitChanged(index, val),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Error display
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.dangerRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.dangerRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Verify Button
              AppButton(
                label: 'Verify & Create Account',
                isLoading: _isVerifying,
                onPressed: _verifyOtp,
              ),

              const SizedBox(height: 24),

              // 60s Resend Timer & Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_secondsRemaining > 0) ...[
                    const Icon(Icons.timer_outlined,
                        size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Resend OTP in ${_secondsRemaining.toString().padLeft(2, '0')}s',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      child: Text(
                        _isResending ? 'Sending...' : 'Resend OTP',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
