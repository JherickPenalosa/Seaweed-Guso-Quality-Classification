import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../screens/seaweed_guide/seaweed_guide_screen.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

import '../../widgets/landing/landing_about.dart';
import '../../widgets/landing/landing_footer.dart';
import '../../widgets/landing/landing_hero.dart';
import '../../widgets/landing/landing_how_it_works.dart';
import '../../widgets/landing/landing_navbar.dart';
import '../../widgets/landing/landing_seaweed_guide_preview.dart';

import 'forgot_password_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const double _desktopBreakpoint = 1200;
  static const double _mobileBreakpoint = 768;
  static const double _maxContentWidth = 1440;
  static const double _navbarHeight = 92;

  final AuthService _authService = const AuthService();
  bool _authRequestInProgress = false;

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _seaweedGuideKey = GlobalKey();

  LandingHeroView _authView = LandingHeroView.preview;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 3, 78, 3),
              Color(0xFF0B2D0D),
              Color(0xFF001000),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: _navbarHeight),
                  child: Column(
                    children: [
                      KeyedSubtree(
                        key: _homeKey,
                        child: LandingHero(
                          desktopBreakpoint: _desktopBreakpoint,
                          mobileBreakpoint: _mobileBreakpoint,
                          maxContentWidth: _maxContentWidth,

                          onGetStartedPressed: _openRegisterPanel,

                          onExploreGuidePressed: _openSeaweedGuide,

                          authView: _authView,

                          onLoginSubmitted: (identifier, password) {
                            _handleLoginSubmission(identifier, password);
                          },

                          onRegisterSubmitted:
                              (
                                firstName,
                                lastName,
                                email,
                                contactNumber,
                                password,
                                confirmPassword,
                              ) {
                                _handleRegisterSubmission(
                                  firstName,
                                  lastName,
                                  email,
                                  contactNumber,
                                  password,
                                  confirmPassword,
                                );
                              },

                          onShowLogin: _showLoginPanel,

                          onForgotPasswordPressed: _openForgotPassword,

                          onShowRegister: _showRegisterPanel,

                          onBackToPreview: _showPreviewPanel,
                        ),
                      ),

                      KeyedSubtree(
                        key: _aboutKey,
                        child: const LandingAbout(
                          desktopBreakpoint: _desktopBreakpoint,
                          mobileBreakpoint: _mobileBreakpoint,
                          maxContentWidth: _maxContentWidth,
                        ),
                      ),

                      KeyedSubtree(
                        key: _howItWorksKey,
                        child: const LandingHowItWorks(
                          desktopBreakpoint: _desktopBreakpoint,
                          mobileBreakpoint: _mobileBreakpoint,
                          maxContentWidth: _maxContentWidth,
                        ),
                      ),

                      KeyedSubtree(
                        key: _seaweedGuideKey,
                        child: LandingSeaweedGuidePreview(
                          desktopBreakpoint: _desktopBreakpoint,
                          mobileBreakpoint: _mobileBreakpoint,
                          maxContentWidth: _maxContentWidth,
                          onExploreGuidePressed: _openSeaweedGuide,
                        ),
                      ),

                      LandingFooter(
                        desktopBreakpoint: _desktopBreakpoint,
                        mobileBreakpoint: _mobileBreakpoint,
                        maxContentWidth: _maxContentWidth,

                        onHomePressed: _returnToHome,

                        onAboutPressed: () {
                          _scrollToSection(_aboutKey);
                        },

                        onHowItWorksPressed: () {
                          _scrollToSection(_howItWorksKey);
                        },

                        onSeaweedGuidePressed: () {
                          _scrollToSection(_seaweedGuideKey);
                        },

                        onGetStartedPressed: _openRegisterPanel,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.disabled.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  child: LandingNavbar(
                    desktopBreakpoint: _desktopBreakpoint,
                    mobileBreakpoint: _mobileBreakpoint,
                    maxContentWidth: _maxContentWidth,

                    onHomePressed: _returnToHome,

                    onAboutPressed: () {
                      _scrollToSection(_aboutKey);
                    },

                    onHowItWorksPressed: () {
                      _scrollToSection(_howItWorksKey);
                    },

                    onSeaweedGuidePressed: () {
                      _scrollToSection(_seaweedGuideKey);
                    },

                    onLoginPressed: _openLoginPanel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLoginPanel() {
    _setAuthView(LandingHeroView.login);
  }

  void _openRegisterPanel() {
    _setAuthView(LandingHeroView.register);
  }

  void _showLoginPanel() {
    _setAuthView(LandingHeroView.login);
  }

  void _showRegisterPanel() {
    _setAuthView(LandingHeroView.register);
  }

  void _showPreviewPanel() {
    if (_authView == LandingHeroView.preview) {
      return;
    }

    setState(() {
      _authView = LandingHeroView.preview;
    });
  }

  void _setAuthView(LandingHeroView view) {
    if (_authView != view) {
      setState(() {
        _authView = view;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _scrollToSection(_homeKey);
    });
  }

  void _returnToHome() {
    if (_authView != LandingHeroView.preview) {
      setState(() {
        _authView = LandingHeroView.preview;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _scrollToSection(_homeKey);
    });
  }

  Future<void> _handleLoginSubmission(
    String identifier,
    String password,
  ) async {
    if (_authRequestInProgress) return;

    if (identifier.trim().isEmpty || password.isEmpty) {
      _showMessage('Please enter your email or contact number and password.');
      return;
    }

    setState(() => _authRequestInProgress = true);
    try {
      // FastAPI authenticates this account and returns a JWT.
      // AuthService stores it for later session restoration.
      await _authService.login(
        identifier: identifier.trim(),
        password: password,
      );

      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      // A registered but unverified user can resume OTP verification from
      // Login. This also helps when OTP sending failed at registration.
      if (message.toLowerCase().contains('not verified')) {
        // An existing unverified account can resume either verification
        // method. If login used a phone, the user may enter their registered
        // email in the dialog; if login used email, they may enter their phone.
        final verified = await _openAccountVerification(
          initialEmail: identifier.contains('@') ? identifier.trim() : '',
          initialPhone: identifier.contains('@') ? '' : identifier.trim(),
          password: password,
          allowEmail: true,
        );
        if (!mounted) return;
        if (verified) {
          _setAuthView(LandingHeroView.login);
          _showMessage('Account verified successfully. Please log in.');
        } else {
          _showMessage('Verify your email or phone before logging in.');
        }
      } else {
        _showMessage(message);
      }
    } finally {
      if (mounted) setState(() => _authRequestInProgress = false);
    }
  }

  Future<void> _handleRegisterSubmission(
    String firstName,
    String lastName,
    String email,
    String contactNumber,
    String password,
    String confirmPassword,
  ) async {
    if (_authRequestInProgress) return;

    if (firstName.trim().isEmpty) {
      _showMessage('Please enter your first name.');
      return;
    }
    if (lastName.trim().isEmpty) {
      _showMessage('Please enter your last name.');
      return;
    }
    if (contactNumber.trim().isEmpty) {
      _showMessage('Please enter your contact number.');
      return;
    }
    if (email.trim().isNotEmpty && !_looksLikeEmail(email.trim())) {
      _showMessage('Please enter a valid email address or leave it blank.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must contain at least 8 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _authRequestInProgress = true);
    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        contactNumber: contactNumber,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;
      // The account exists in PostgreSQL but still needs verification.
      // Email is optional. If supplied, the user may choose email or SMS;
      // otherwise only the existing SMS method is available.
      final verified = await _openAccountVerification(
        initialEmail: email.trim(),
        initialPhone: contactNumber.trim(),
        password: password,
        allowEmail: email.trim().isNotEmpty,
      );
      if (!mounted) return;
      _setAuthView(LandingHeroView.login);
      _showMessage(
        verified
            ? 'Registration and verification successful. Please log in.'
            : 'Account created but not verified. Log in to retry verification.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _authRequestInProgress = false);
    }
  }

  Future<bool> _openAccountVerification({
    required String initialEmail,
    required String initialPhone,
    required String password,
    required bool allowEmail,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AccountVerificationDialog(
        authService: _authService,
        initialEmail: initialEmail,
        initialPhone: initialPhone,
        accountPassword: password,
        allowEmail: allowEmail,
      ),
    );
    return result == true;
  }

  bool _looksLikeEmail(String email) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return emailPattern.hasMatch(email);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final sectionContext = key.currentContext;

    if (sectionContext == null || !_scrollController.hasClients) {
      return;
    }

    final renderObject = sectionContext.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final sectionPosition = renderObject.localToGlobal(Offset.zero).dy;

    final targetOffset =
        _scrollController.offset + sectionPosition - _navbarHeight - 12;

    final safeOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      safeOffset,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openSeaweedGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(routeContext).pop();
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back to Landing Page'),
                      ),
                    ),
                  ),
                  const Expanded(child: SeaweedGuideScreen()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleRecoverySubmission(String identifier) {
    if (identifier.isEmpty) {
      _showMessage('Please enter your email or contact number.');
      return;
    }

    _showMessage('Password recovery backend will be connected next.');
  }

  Future<void> _openForgotPassword() async {
    final result = await Navigator.of(context).push<ForgotPasswordReturnAction>(
      MaterialPageRoute(
        builder: (_) {
          return ForgotPasswordScreen(
            onRecoverySubmitted: (identifier) {
              _handleRecoverySubmission(identifier);
            },
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == ForgotPasswordReturnAction.register) {
      _setAuthView(LandingHeroView.register);
      return;
    }

    _setAuthView(LandingHeroView.login);
  }
}

/// This dialog is deliberately contained in landing_screen.dart so existing
/// LandingHero registration callbacks and page design remain unchanged.
/// The backend verifies account ownership using the user's password and
/// validates a separate OTP purpose for each contact method.
enum _VerificationChannel { email, sms }

class _AccountVerificationDialog extends StatefulWidget {
  const _AccountVerificationDialog({
    required this.authService,
    required this.initialEmail,
    required this.initialPhone,
    required this.accountPassword,
    required this.allowEmail,
  });

  final AuthService authService;
  final String initialEmail;
  final String initialPhone;
  final String accountPassword;
  final bool allowEmail;

  @override
  State<_AccountVerificationDialog> createState() =>
      _AccountVerificationDialogState();
}

class _AccountVerificationDialogState
    extends State<_AccountVerificationDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _codeController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _sendingCode = false;
  bool _verifyingCode = false;
  bool _codeRequested = false;
  String? _requestedDestination;
  String? _message;
  String? _error;
  late _VerificationChannel _channel;

  bool get _busy => _sendingCode || _verifyingCode;

  String get _destination => _channel == _VerificationChannel.email
      ? _emailController.text.trim().toLowerCase()
      : _phoneController.text.trim();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _channel = widget.allowEmail
        ? _VerificationChannel.email
        : _VerificationChannel.sms;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _resetCodeRequest() {
    _resendTimer?.cancel();
    _codeController.clear();
    setState(() {
      _codeRequested = false;
      _requestedDestination = null;
      _resendSeconds = 0;
      _error = null;
      _message = null;
    });
  }

  void _selectChannel(_VerificationChannel channel) {
    if (_busy || channel == _channel) return;
    setState(() => _channel = channel);
    _resetCodeRequest();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  Future<void> _sendCode() async {
    if (_busy || _resendSeconds > 0) return;
    final destination = _destination;
    if (_channel == _VerificationChannel.email) {
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(destination)) {
        setState(() => _error = 'Enter the email registered to this account.');
        return;
      }
    } else if (destination.isEmpty) {
      setState(() => _error = 'Enter the registered mobile number.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _sendingCode = true;
      _error = null;
      _message = null;
      _codeRequested = false;
      _requestedDestination = null;
      _codeController.clear();
    });

    try {
      if (_channel == _VerificationChannel.email) {
        await widget.authService.sendEmailOtp(
          email: destination,
          password: widget.accountPassword,
        );
      } else {
        await widget.authService.sendRegistrationOtp(
          contactNumber: destination,
          password: widget.accountPassword,
        );
      }
      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _requestedDestination = destination;
        _message = _channel == _VerificationChannel.email
            ? 'Email code requested. Check your inbox and Spam folder. '
                  'The code expires in 5 minutes.'
            : 'SMS OTP requested. Check your phone if real SMS delivery is '
                  'enabled, or your private FastAPI terminal in local test '
                  'mode. The code expires in 5 minutes.';
      });
      _startResendCooldown();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _cleanError(error));
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_busy) return;
    final destination = _destination;
    final code = _codeController.text.trim();
    if (!_codeRequested || destination != _requestedDestination) {
      setState(() => _error = 'Request a new OTP for this contact method.');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter exactly six digits from your OTP.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _verifyingCode = true;
      _error = null;
      _message = null;
    });

    try {
      final result = _channel == _VerificationChannel.email
          ? await widget.authService.verifyEmailOtp(
              email: destination,
              password: widget.accountPassword,
              code: code,
            )
          : await widget.authService.verifyRegistrationOtp(
              contactNumber: destination,
              password: widget.accountPassword,
              code: code,
            );
      if (!mounted) return;
      final verifiedKey = _channel == _VerificationChannel.email
          ? 'email_verified'
          : 'contact_verified';
      if (result['is_verified'] != true || result[verifiedKey] != true) {
        setState(() => _error = 'The server did not confirm verification.');
        return;
      }
      _codeController.clear();
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _cleanError(error));
    } finally {
      if (mounted) setState(() => _verifyingCode = false);
    }
  }

  Widget _channelChoice({
    required _VerificationChannel channel,
    required IconData icon,
    required String label,
  }) {
    final selected = _channel == channel;
    return OutlinedButton.icon(
      onPressed: _busy ? null : () => _selectChannel(channel),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? AppColors.primary : AppColors.textSecondary,
        backgroundColor: selected ? AppColors.primaryDark : AppColors.surface,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.disabled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = _channel == _VerificationChannel.email;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.borderPrimary),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verify your gUSo account',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose one verification method. We will send a six-digit '
                'code to the email address or phone number registered with '
                'your account.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              if (widget.allowEmail)
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _channelChoice(
                      channel: _VerificationChannel.email,
                      icon: Icons.email_outlined,
                      label: 'Verify via Email',
                    ),
                    _channelChoice(
                      channel: _VerificationChannel.sms,
                      icon: Icons.sms_outlined,
                      label: 'Verify via SMS',
                    ),
                  ],
                )
              else
                const Text(
                  'No email was provided during registration. '
                  'Only mobile verification is available for this account.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              const SizedBox(height: 18),
              TextField(
                controller: isEmail ? _emailController : _phoneController,
                enabled: !_busy,
                keyboardType: isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: isEmail
                      ? 'Registered email address'
                      : 'Registered mobile number',
                  prefixIcon: Icon(
                    isEmail
                        ? Icons.alternate_email_rounded
                        : Icons.phone_android_outlined,
                  ),
                ),
                onChanged: (_) => _resetCodeRequest(),
              ),
              if (!isEmail) ...[
                const SizedBox(height: 8),
                const Text(
                  'Real SMS requires an active provider and credits. '
                  'Development mode prints the OTP only in the private '
                  'FastAPI terminal for the designated test number.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy || _resendSeconds > 0 ? null : _sendCode,
                  icon: _sendingCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isEmail ? Icons.send_outlined : Icons.sms_outlined,
                        ),
                  label: Text(
                    _sendingCode
                        ? 'Requesting code...'
                        : _resendSeconds > 0
                        ? 'Resend in ${_resendSeconds}s'
                        : _codeRequested
                        ? 'Resend OTP'
                        : 'Send OTP',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                enabled: !_busy && _codeRequested,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                maxLength: 6,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Six-digit verification code',
                  hintText: '000000',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  counterText: '',
                ),
                onSubmitted: (_) => _verifyCode(),
              ),
              if (_message != null) ...[
                const SizedBox(height: 6),
                Text(
                  _message!,
                  style: const TextStyle(color: AppColors.primary, height: 1.4),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, height: 1.4),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Verify later'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _busy || !_codeRequested ? null : _verifyCode,
                    icon: _verifyingCode
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_verifyingCode ? 'Verifying...' : 'Verify OTP'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
