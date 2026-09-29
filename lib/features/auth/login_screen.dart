import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../main_navigation_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  // Tab State: 0 = Login, 1 = Sign Up
  int _activeTab = 0;

  // Sign Up Multi-Step State (1: Purpose & Name, 2: Mobile, 3: Password)
  int _signUpStep = 1;

  // Login Controllers
  final _loginUserOrPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool _rememberMe = true;
  bool _isLoggingIn = false;
  String? _loginErrorMessage;

  // Sign Up Controllers (For Parents & Candidates searching 8000+ profiles)
  final _signUpNameController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  String _lookingFor = 'Bride'; // 'Bride' (Looking for Bride) or 'Groom' (Looking for Groom)
  bool _signUpObscurePass = true;
  bool _signUpObscureConfirm = true;
  bool _agreeTerms = true;
  bool _isSigningUp = false;
  String? _signUpStepErrorMessage;


  @override
  void dispose() {
    _loginUserOrPhoneController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loginErrorMessage = null;
      _isLoggingIn = true;
    });

    final credential = _loginUserOrPhoneController.text.trim();
    final password = _loginPasswordController.text.trim();

    // Admin login handling (Username: admin, Password: admin123)
    if (credential.toLowerCase() == 'admin') {
      if (password == 'admin123') {
        setState(() {
          _isLoggingIn = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboardScreen(mockData: MockDataService())),
        );
        return;
      } else {
        setState(() {
          _isLoggingIn = false;
          _loginErrorMessage = "தவறான நிர்வாக கடவுச்சொல் (Invalid admin password)\nAdmin Username: admin / Password: admin123";
        });
        return;
      }
    }

    final result = await _authService.login(credential, password);

    if (!mounted) return;

    setState(() {
      _isLoggingIn = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${result.message} (${result.user?.name ?? ''})",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B6B38),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Immediate synchronous sync so current user profile is populated instantly
      MockDataService().syncWithAuth(result.user);

      // Fetch fresh Atlas profile, avatar image, shortlists, and payments before navigating
      try {
        await MockDataService().syncWithAuthAsync(result.user).timeout(const Duration(seconds: 4));
      } catch (_) {}

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      setState(() {
        _loginErrorMessage = result.message;
      });
    }
  }

  void _goToStep2() {
    final name = _signUpNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _signUpStepErrorMessage = "உங்கள் பெயரை உள்ளிடவும் / Please enter name";
      });
      return;
    }
    setState(() {
      _signUpStepErrorMessage = null;
      _signUpStep = 2;
    });
  }

  void _goToStep3() {
    final rawPhone = _signUpPhoneController.text.trim();
    final cleanPhone = rawPhone.replaceAll(RegExp(r'\D'), '');

    if (cleanPhone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone)) {
      setState(() {
        _signUpStepErrorMessage =
            "சரியான 10-இலக்க கைபேசி எண்ணை உள்ளிடவும் (6, 7, 8 அல்லது 9-ல் தொடங்க வேண்டும்) / Please enter valid 10-digit mobile starting with 6, 7, 8 or 9";
      });
      return;
    }

    // Mobile number must not be repeated for one or more accounts
    if (_authService.isPhoneRegistered(cleanPhone)) {
      setState(() {
        _signUpStepErrorMessage =
            "இந்த கைபேசி எண் ($cleanPhone) ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது! தயவுசெய்து உள்நுழையவும் / Mobile number already registered. Please login.";
      });
      return;
    }

    // Validate email format and uniqueness (if provided)
    final email = _signUpEmailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _signUpStepErrorMessage =
              "சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும் / Please enter a valid email address (e.g. name@gmail.com)";
        });
        return;
      }

      if (_authService.isEmailRegistered(email)) {
        setState(() {
          _signUpStepErrorMessage =
              "இந்த மின்னஞ்சல் ($email) ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது / This email is already registered";
        });
        return;
      }
    }

    setState(() {
      _signUpStepErrorMessage = null;
      _signUpStep = 3;
    });
  }

  Future<void> _handleCompleteSignUp() async {
    setState(() {
      _signUpStepErrorMessage = null;
    });

    final pass = _signUpPasswordController.text;
    final confirmPass = _signUpConfirmPasswordController.text;

    if (pass.length < 6) {
      setState(() {
        _signUpStepErrorMessage =
            "கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும் / Min 6 characters";
      });
      return;
    }

    if (pass != confirmPass) {
      setState(() {
        _signUpStepErrorMessage =
            "கடவுச்சொற்கள் பொருந்தவில்லை / Passwords do not match";
      });
      return;
    }

    if (!_agreeTerms) {
      setState(() {
        _signUpStepErrorMessage =
            "விதிமுறைகளை ஏற்கவும் / Please accept terms & conditions";
      });
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    final result = await _authService.register(
      name: _signUpNameController.text,
      usernameOrPhone: _signUpPhoneController.text,
      phone: _signUpPhoneController.text,
      email: _signUpEmailController.text.trim(),
      password: _signUpPasswordController.text,
      gender: _lookingFor == 'Bride' ? 'Searching for Bride' : 'Searching for Groom',
    );

    if (!mounted) return;

    setState(() {
      _isSigningUp = false;
    });

    if (result.success) {
      final userName = _signUpNameController.text.trim();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF580B23).withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Celebration Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8C1D38), Color(0xFF580B23)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8C1D38).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.celebration_rounded,
                      color: Color(0xFFF3E5AB),
                      size: 34,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Greeting Title
                Text(
                  "வணக்கம் $userName!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A132B),
                  ),
                ),

                const SizedBox(height: 10),

                // Informative Message about After-Login Profile details
                const Text(
                  "உங்கள் கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டுள்ளது!\n\nஉள்நுழைந்த பிறகு, 'கணக்கு / Profile' பகுதியில் உங்கள் ஜாதகம், கல்வி, குடும்ப விவரங்கள் மற்றும் புகைப்படங்களை முழுமையாக பூர்த்தி செய்து கொள்ளலாம்.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.8,
                    color: Color(0xFF5A4448),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                // Perfectly Center-Aligned Button with Zero Overflow
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C1D38),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final registeredPhone = _signUpPhoneController.text.trim();
                      final registeredPassword = _signUpPasswordController.text;
                      Navigator.pop(ctx);
                      setState(() {
                        _activeTab = 0; // Navigate to Login Page
                        _loginUserOrPhoneController.text = registeredPhone;
                        _loginPasswordController.text = registeredPassword;
                        _loginErrorMessage = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "கணக்கு உருவாக்கப்பட்டது! உள்நுழையவும் / Account created! Tap Login.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF1B6B38),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "உள்நுழைக / Login",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      setState(() {
        _signUpStepErrorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32).clamp(0.0, double.infinity),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Founder Owner Photo (Royal Gold Medallion)
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFDF7A),
                                Color(0xFFD4AF37),
                                Color(0xFF9E6D18),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7A132B).withValues(alpha: 0.18),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2.5),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/founder_arumugam.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Owner Name in Tamil (Bold Size)
                      const Text(
                        AppConstants.founderName, // சென்னிமலை ஆறுமுகம்
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7A132B),
                          letterSpacing: 0.6,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // App Name: பண்டாரத்தார் மண மாலை
                      const Text(
                        AppConstants.appNameTamil,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B263E),
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        AppConstants.appNameEnglish,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                          color: Color(0xFFB8860B),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Main Elevated Auth Card (Forms & Tabs)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8DCD0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF580B23).withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Segmented Tab Selector: [ உள்நுழைவு / Login ] | [ பதிவு செய்க / Sign Up ]
                            Container(
                              padding: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2E7DC),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: const Color(0xFFE2D2C2)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _activeTab = 0;
                                        _loginErrorMessage = null;
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _activeTab == 0
                                              ? const Color(0xFF8C1D38)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: _activeTab == 0
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF8C1D38).withValues(alpha: 0.25),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "உள்நுழைவு / Login",
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: _activeTab == 0
                                                  ? Colors.white
                                                  : const Color(0xFF6B4E54),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _activeTab = 1;
                                        _signUpStep = 1;
                                        _signUpStepErrorMessage = null;
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _activeTab == 1
                                              ? const Color(0xFF8C1D38)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: _activeTab == 1
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF8C1D38).withValues(alpha: 0.25),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "பதிவு செய்க / Sign Up",
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: _activeTab == 1
                                                  ? Colors.white
                                                  : const Color(0xFF6B4E54),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Active Tab Form View
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _activeTab == 0 ? _buildLoginForm() : _buildStepSignUpForm(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}


  // ==========================================
  // LOGIN FORM VIEW
  // ==========================================
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey("login_form"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error message banner if login failed
        if (_loginErrorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFF8B4B4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFC81E1E), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _loginErrorMessage!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF9B1C1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Username / Phone input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _loginErrorMessage != null
                  ? const Color(0xFFF8B4B4)
                  : const Color(0xFFE4D6CB),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: _loginUserOrPhoneController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline_rounded,
                  color: Color(0xFF7E6F72), size: 19),
              hintText: "கைபேசி எண் / Mobile or Username",
              hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF9E8F92)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Password input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _loginErrorMessage != null
                  ? const Color(0xFFF8B4B4)
                  : const Color(0xFFE4D6CB),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: _loginPasswordController,
            obscureText: _loginObscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF7E6F72), size: 19),
              hintText: "கடவுச்சொல் / Password",
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9E8F92)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              suffixIcon: IconButton(
                icon: Icon(
                  _loginObscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7E6F72),
                  size: 19,
                ),
                onPressed: () => setState(
                    () => _loginObscurePassword = !_loginObscurePassword),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Remember Me & Forgot Password Row
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            InkWell(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFF8C1D38),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) =>
                          setState(() => _rememberMe = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "நினைவில் கொள்க / Remember",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4C3E41),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text("கடவுச்சொல் மீட்டெடுப்பு / Reset Password"),
                    content: const Text(
                      "தயவுசெய்து உங்கள் பதிவு செய்யப்பட்ட கைபேசி எண்ணை உள்ளிடவும். OTP அனுப்பப்படும்.\n\nPlease enter your registered mobile number for OTP reset.",
                      style: TextStyle(fontSize: 12.5, height: 1.3),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("சரி / OK"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "கடவுச்சொல் மறந்ததா?",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3868),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Login Button
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: _isLoggingIn ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C1D38),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: _isLoggingIn
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, size: 19),
                      SizedBox(width: 8),
                      Text(
                        "உள்நுழைவு / Login",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Link to Switch to Sign Up
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "புதிய பயனரா? / New here? ",
              style: TextStyle(fontSize: 12, color: Color(0xFF6B5458)),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _activeTab = 1;
                _signUpStep = 1;
                _loginErrorMessage = null;
              }),
              child: const Text(
                "பதிவு செய்க / Sign Up",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C1D38),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Admin Portal Entry Button
        Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7A132B),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDashboardScreen(mockData: MockDataService()),
                ),
              );
            },
            icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
            label: const Text(
              "நிர்வாக தளம் / Admin Portal Login",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MULTI-STEP SIGN UP WIZARD (For Parents / Candidates)
  // ==========================================
  Widget _buildStepSignUpForm() {
    return Column(
      key: const ValueKey("signup_step_form"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step Progress Bar
        _buildStepProgressBar(),

        const SizedBox(height: 12),

        // Step Error Alert Banner
        if (_signUpStepErrorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFF8B4B4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFC81E1E), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _signUpStepErrorMessage!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF9B1C1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Step 1: Name & What are you looking for
        if (_signUpStep == 1) _buildStep1Content(),

        // Step 2: Mobile Number
        if (_signUpStep == 2) _buildStep2Content(),

        // Step 3: Password & Finish
        if (_signUpStep == 3) _buildStep3Content(),

        const SizedBox(height: 14),

        // Switch back to Login footer
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "ஏற்கனவே கணக்கு உள்ளதா? ",
              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B5458)),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _activeTab = 0;
                _signUpStepErrorMessage = null;
              }),
              child: const Text(
                "உள்நுழைக / Login",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C1D38),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F0E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D7C8)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _signUpStep == 1
                      ? "படி 1/3: உங்கள் பெயர் & நோக்கம்"
                      : _signUpStep == 2
                          ? "படி 2/3: கைபேசி & மின்னஞ்சல்"
                          : "படி 3/3: கடவுச்சொல் அமைப்பு",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF580B23),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Step $_signUpStep of 3",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8C1D38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildProgressPill(stepIndex: 1),
              const SizedBox(width: 6),
              _buildProgressPill(stepIndex: 2),
              const SizedBox(width: 6),
              _buildProgressPill(stepIndex: 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPill({required int stepIndex}) {
    final isDone = _signUpStep > stepIndex;
    final isActive = _signUpStep == stepIndex;

    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFF1B6B38)
              : isActive
                  ? const Color(0xFF8C1D38)
                  : const Color(0xFFE2D0C2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  // STEP 1: Name and Looking For (Bride vs Groom)
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "உங்கள் பெயர் / Your Full Name",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3E41),
          ),
        ),
        const SizedBox(height: 8),

        // Full Name Field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE4D6CB)),
          ),
          child: TextField(
            controller: _signUpNameController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.badge_outlined,
                  color: Color(0xFF7E6F72), size: 19),
              hintText: "பெயர் (எ.கா. மு. சுந்தரம் / K. Sundaram)",
              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9E8F92)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "யாரை தேடுகிறீர்கள்? / Looking for:",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3E41),
          ),
        ),
        const SizedBox(height: 8),

        // Looking for Bride vs Groom
        Row(
          children: [
            Expanded(
              child: _buildPurposeCard(
                titleTamil: "பெண் தேடுகிறேன்",
                titleEnglish: "Looking for Bride",
                icon: Icons.person_4_rounded,
                isSelected: _lookingFor == 'Bride',
                onTap: () => setState(() => _lookingFor = 'Bride'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPurposeCard(
                titleTamil: "வரன் தேடுகிறேன்",
                titleEnglish: "Looking for Groom",
                icon: Icons.person_rounded,
                isSelected: _lookingFor == 'Groom',
                onTap: () => setState(() => _lookingFor = 'Groom'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Next Button
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: _goToStep2,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C1D38),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "அடுத்தது / Next",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeCard({
    required String titleTamil,
    required String titleEnglish,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8C1D38) : const Color(0xFFE4D6CB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8C1D38).withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? const Color(0xFF8C1D38) : const Color(0xFF7E6F72),
            ),
            const SizedBox(height: 4),
            Text(
              titleTamil,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF8C1D38) : const Color(0xFF4C3E41),
              ),
            ),
            Text(
              titleEnglish,
              style: TextStyle(
                fontSize: 10.5,
                color: isSelected ? const Color(0xFF8C1D38) : const Color(0xFF7E6F72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Mobile Number & Email (Unique mobile validation)
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mobile Number Label
        const Text(
          "கைபேசி எண் / Mobile Number *",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3E41),
          ),
        ),
        const SizedBox(height: 6),

        // Mobile Field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE4D6CB)),
          ),
          child: TextField(
            controller: _signUpPhoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone_android_rounded,
                  color: Color(0xFF7E6F72), size: 19),
              prefixText: "+91 ",
              prefixStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A132B),
                fontSize: 13,
              ),
              hintText: "10-இலக்க கைபேசி / 10-Digit Mobile Number",
              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9E8F92)),
              counterText: "",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Email Label (Optional)
        const Text(
          "மின்னஞ்சல் / Email (விருப்பத்தேர்வு / Optional)",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3E41),
          ),
        ),
        const SizedBox(height: 6),

        // Email Field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE4D6CB)),
          ),
          child: TextField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _goToStep3(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline_rounded,
                  color: Color(0xFF7E6F72), size: 19),
              hintText: "எ.கா. name@gmail.com / Optional Email",
              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9E8F92)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _signUpStep = 1;
                    _signUpStepErrorMessage = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8C1D38)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF8C1D38)),
                      SizedBox(width: 4),
                      Text(
                        "பின்செல்",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C1D38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _goToStep3,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C1D38),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "அடுத்தது / Next",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: Password & Finish
  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "கடவுச்சொல்லை அமைக்கவும் / Set Password",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C3E41),
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE4D6CB)),
          ),
          child: TextField(
            controller: _signUpPasswordController,
            obscureText: _signUpObscurePass,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF7E6F72), size: 19),
              hintText: "கடவுச்சொல் / Password (குறைந்தது 6 எழுத்து)",
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E8F92)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              suffixIcon: IconButton(
                icon: Icon(
                  _signUpObscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7E6F72),
                  size: 19,
                ),
                onPressed: () => setState(
                    () => _signUpObscurePass = !_signUpObscurePass),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE4D6CB)),
          ),
          child: TextField(
            controller: _signUpConfirmPasswordController,
            obscureText: _signUpObscureConfirm,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleCompleteSignUp(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_reset_rounded,
                  color: Color(0xFF7E6F72), size: 19),
              hintText: "கடவுச்சொல்லை உறுதிசெய் / Confirm Password",
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E8F92)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              suffixIcon: IconButton(
                icon: Icon(
                  _signUpObscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7E6F72),
                  size: 19,
                ),
                onPressed: () => setState(
                    () => _signUpObscureConfirm = !_signUpObscureConfirm),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _agreeTerms,
                activeColor: const Color(0xFF8C1D38),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "நான் சமூக விதிமுறைகளை ஏற்கிறேன் / I agree to Terms & Conditions",
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF4C3E41),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _signUpStep = 2;
                    _signUpStepErrorMessage = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8C1D38)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF8C1D38)),
                      SizedBox(width: 4),
                      Text(
                        "பின்செல்",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C1D38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSigningUp ? null : _handleCompleteSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C1D38),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: _isSigningUp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "முடிக்க / Sign Up",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
