import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/profile_image_picker.dart';
import '../../core/widgets/avatar_image.dart';
import '../../services/auth_service.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/mongodb_service.dart';
import '../../core/utils/navigation_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final MockDataService mockData;
  final int initialTabIndex;

  const EditProfileScreen({
    super.key,
    required this.mockData,
    this.initialTabIndex = 0,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _gender;
  late String _avatarSeed;
  Uint8List? _imageBytes;
  String? _uploadedFileName;
  String? _r2ProfileImageUrl;
  bool _isUploadingToR2 = false;

  @override
  void initState() {
    super.initState();
    final user = widget.mockData.currentUser;
    final authUser = AuthService().currentUser;

    final initialName = (authUser?.name.isNotEmpty ?? false)
        ? authUser!.name
        : (user.name.isNotEmpty ? user.name : '');
    final rawPhone = (authUser?.phone.isNotEmpty ?? false)
        ? authUser!.phone
        : (user.phone.isNotEmpty ? user.phone : '');
    final cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final initialPhone = cleanDigits.length == 10
        ? cleanDigits
        : (cleanDigits.length > 10 && cleanDigits.startsWith('91') && cleanDigits.length == 12
            ? cleanDigits.substring(2)
            : (cleanDigits.length > 10 ? cleanDigits.substring(0, 10) : cleanDigits));
    final initialEmail = (authUser?.email.isNotEmpty ?? false)
        ? authUser!.email
        : (user.email.isNotEmpty ? user.email : '');
    final initialGender = (authUser?.gender.isNotEmpty ?? false)
        ? authUser!.gender
        : (user.gender.isNotEmpty ? user.gender : 'Groom');

    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: initialPhone);
    _emailController = TextEditingController(text: initialEmail);
    _gender = initialGender;
    _avatarSeed = user.avatarSeed.isNotEmpty ? user.avatarSeed : (initialName.isNotEmpty ? initialName : 'User');
    _imageBytes = user.imageBytes ?? authUser?.imageBytes;
    _r2ProfileImageUrl = user.profileImageUrl ?? authUser?.profileImageUrl;
  }

  String? get _phoneError {
    final text = _phoneController.text.trim();
    if (text.isEmpty) return null;
    final clean = text.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10) {
      return "10-இலக்க கைபேசி எண் தேவை (${clean.length}/10) / 10-digit mobile number required";
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
      return "கைபேசி எண் 6, 7, 8 அல்லது 9-ல் தொடங்க வேண்டும் / Must start with 6, 7, 8 or 9";
    }
    return null;
  }

  String? get _emailError {
    final email = _emailController.text.trim();
    if (email.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return "சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும் / Please enter valid email";
    }
    return null;
  }

  String get _genderDisplayLabel {
    final g = _gender.toLowerCase().trim();
    if (g.contains('searching for groom') || g == 'bride' || g.contains('female')) {
      return 'மணமகள் (Bride)';
    }
    return 'மணமகன் (Groom)';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePickImage() async {
    final result = await pickProfileImage();
    if (result != null) {
      setState(() {
        _imageBytes = result.bytes;
        _uploadedFileName = result.fileName;
        _isUploadingToR2 = true;
      });

      // Immediately apply image bytes to active user so it renders instantly
      final user = widget.mockData.currentUser;
      final instantUpdated = user.copyWith(imageBytes: result.bytes);
      widget.mockData.updateUserProfile(instantUpdated);
      AuthService().updateCurrentUserAccount(
        name: user.name,
        phone: user.phone,
        email: user.email,
        gender: user.gender,
        imageBytes: result.bytes,
      );

      // Upload directly to Cloudflare R2 bucket matrimony-profile-images / profiles/
      try {
        final r2Url = await CloudflareR2Service().uploadProfileImage(
          imageBytes: result.bytes,
          fileName: result.fileName,
          userId: user.id.isNotEmpty ? user.id : (user.phone.isNotEmpty ? user.phone : 'user'),
          oldImageUrl: _r2ProfileImageUrl ?? user.profileImageUrl,
        );

        setState(() {
          _r2ProfileImageUrl = r2Url;
          _isUploadingToR2 = false;
        });

        // Store Cloudflare R2 URL on the active user profile
        final r2Updated = widget.mockData.currentUser.copyWith(
          imageBytes: result.bytes,
          profileImageUrl: r2Url,
        );
        widget.mockData.updateUserProfile(r2Updated);
        AuthService().updateCurrentUserAccount(
          name: user.name,
          phone: user.phone,
          email: user.email,
          gender: user.gender,
          imageBytes: result.bytes,
          profileImageUrl: r2Url,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${result.fileName} வெற்றிகரமாக சேமிக்கப்பட்டது! ✓',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1B6B38),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() => _isUploadingToR2 = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('படப் பதிவேற்றம் பிழை / Upload error: $e'),
              backgroundColor: const Color(0xFFC81E1E),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('உங்கள் பெயரை உள்ளிடவும் / Please enter your name'),
          backgroundColor: Color(0xFFC81E1E),
        ),
      );
      return;
    }

    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('கைபேசி எண்ணை உள்ளிடவும் / Please enter mobile number'),
          backgroundColor: Color(0xFFC81E1E),
        ),
      );
      return;
    }

    if (cleanPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'சரியான 10-இலக்க கைபேசி எண்ணை உள்ளிடவும் (${cleanPhone.length}/10) / Please enter a valid 10-digit mobile number',
          ),
          backgroundColor: const Color(0xFFC81E1E),
        ),
      );
      return;
    }

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'கைபேசி எண் 6, 7, 8 அல்லது 9-ல் தொடங்க வேண்டும் / Mobile number must start with 6, 7, 8 or 9',
          ),
          backgroundColor: Color(0xFFC81E1E),
        ),
      );
      return;
    }

    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும் / Please enter a valid email address'),
            backgroundColor: Color(0xFFC81E1E),
          ),
        );
        return;
      }
    }

    final current = widget.mockData.currentUser;

    // Safety check: if image was picked but not yet uploaded to R2, upload now
    if (_imageBytes != null && _r2ProfileImageUrl == null) {
      setState(() => _isUploadingToR2 = true);
      try {
        final r2Url = await CloudflareR2Service().uploadProfileImage(
          imageBytes: _imageBytes!,
          fileName: _uploadedFileName ?? "profile.jpg",
          userId: current.id.isNotEmpty ? current.id : (cleanPhone.isNotEmpty ? cleanPhone : 'user'),
          oldImageUrl: _r2ProfileImageUrl ?? current.profileImageUrl,
        );
        _r2ProfileImageUrl = r2Url;
      } catch (_) {}
      setState(() => _isUploadingToR2 = false);
    }

    final updated = current.copyWith(
      name: name,
      nameTamil: name,
      phone: cleanPhone,
      whatsapp: cleanPhone,
      email: email,
      gender: _gender,
      avatarSeed: name.isNotEmpty ? name : _avatarSeed,
      imageBytes: _imageBytes,
      profileImageUrl: _r2ProfileImageUrl,
    );

    // 1. Update in MockDataService (active session & profiles store)
    widget.mockData.updateUserProfile(updated);

    // 2. Update in AuthService (user account credentials)
    await AuthService().updateCurrentUserAccount(
      name: name,
      phone: cleanPhone,
      email: email,
      gender: _gender,
      imageBytes: _imageBytes,
      profileImageUrl: _r2ProfileImageUrl,
    );

    // 3. Reflect and persist directly in MongoDB Database
    final dbSuccess = await MongoDBService().updateUserProfile(updated.toMap());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dbSuccess
                    ? 'விவரங்கள் மாற்றப்பட்டு தரவுத்தளத்தில் சேமிக்கப்பட்டது! ✓ (Database Updated)'
                    : 'சுயவிவரம் வெற்றிகரமாக சேமிக்கப்பட்டது! ✓',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B6B38),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () => SafeNavigation.safePop(context, initialIndex: 4),
          tooltip: 'பின்செல்க',
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'சுயவிவரம் திருத்துதல்',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Edit Profile Details',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFF3E5AB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Profile Photo & Image Upload Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _isUploadingToR2 ? null : _handlePickImage,
                      child: Stack(
                        children: [
                          AvatarImage(
                            seed: _avatarSeed,
                            name: _nameController.text.trim().isNotEmpty
                                ? _nameController.text.trim()
                                : 'User',
                            size: 110,
                            isVerified: true,
                            gender: _gender,
                            imageBytes: _imageBytes,
                            imageUrl: _r2ProfileImageUrl,
                          ),
                          if (_isUploadingToR2)
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7A132B),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'சுயவிவரப் படம் / Profile Photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C161A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_isUploadingToR2)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD54F)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFFF57C00)),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'புகைப்படம் பதிவேற்றப்படுகிறது...',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8D6E63)),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      'புகைப்படத்தைத் தொட்டு மாற்றிக்கொள்ளலாம்',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B5458),
                      ),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _isUploadingToR2 ? null : _handlePickImage,
                    icon: _isUploadingToR2
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF7A132B)),
                          )
                        : const Icon(Icons.cloud_upload_rounded, size: 18),
                    label: Text(
                      _isUploadingToR2
                          ? 'பதிவேற்றப்படுகிறது...'
                          : 'புகைப்படம் மாற்றவும் / Upload Photo',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7A132B),
                      side: const BorderSide(color: Color(0xFF7A132B), width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Signup Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_ind_rounded,
                            color: Color(0xFF7A132B), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'பதிவு விவரங்கள்',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: Color(0xFF2C161A),
                            ),
                          ),
                          Text(
                            'Signup Account Details',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B5458),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF0E5DC)),
                  const SizedBox(height: 14),

                  // 1. Full Name
                  _buildModernTextField(
                    label: 'முழு பெயர் (Full Name)',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'உங்கள் பெயரை உள்ளிடவும்',
                  ),
                  const SizedBox(height: 14),

                  // 2. Mobile Number
                  _buildModernTextField(
                    label: 'கைபேசி எண் (Mobile / WhatsApp Number)',
                    controller: _phoneController,
                    icon: Icons.phone_iphone_rounded,
                    keyboardType: TextInputType.phone,
                    hint: '6381180488',
                    prefixText: '+91 ',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    errorText: _phoneError,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),

                  // 3. Email Address
                  _buildModernTextField(
                    label: 'மின்னஞ்சல் முகவரி (Email Address)',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    hint: 'example@gmail.com',
                    errorText: _emailError,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),

                  // 4. Gender / Role (Fixed to what was selected during signup)
                  _buildFixedField(
                    label: 'பாலினம் / பங்கு (Gender / Profile Role)',
                    icon: Icons.wc_rounded,
                    value: _genderDisplayLabel,
                    subtitle: 'பதிவின் போது தேர்ந்தெடுக்கப்பட்ட பங்கு (Fixed at registration)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text(
                'மாற்றங்களைச் சேமிக்கவும் / Save Profile',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A132B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    String? helperText,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C3E41),
              ),
            ),
            if (helperText != null)
              Text(
                helperText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: helperText.contains('✓') ? const Color(0xFF1B6B38) : const Color(0xFF8C7A7E),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFC81E1E)
                  : const Color(0xFFE4D6CB),
              width: errorText != null ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF2C161A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF7A132B), size: 19),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A132B),
              ),
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFFA09496)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFC81E1E)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFC81E1E), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFixedField({
    required String label,
    required IconData icon,
    required String value,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4C3E41),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4D6CB)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF7A132B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2C161A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEADBCE)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF7A132B)),
                    SizedBox(width: 4),
                    Text(
                      "உறுதிப்படுத்தப்பட்டது",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A132B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF8C7A7E)),
          ),
        ],
      ],
    );
  }
}
