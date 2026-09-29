import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 1;
  final int _totalSteps = 6;

  // Step 1 Controllers
  final _fullNameController = TextEditingController();
  String _selectedGender = 'Groom';
  final _dobController = TextEditingController(text: '15/08/1996');
  final _ageController = TextEditingController(text: '28');
  final _heightController = TextEditingController(text: "5'10\"");
  String _selectedMaritalStatus = 'Never Married';

  // Step 2 Controllers
  final String _communityName = AppConstants.communityName;
  String _selectedMotherTongue = 'Tamil';
  String _selectedReligion = 'Hindu';

  // Step 3 Controllers
  final _educationController = TextEditingController(text: 'B.E Computer Science');
  final _occupationController = TextEditingController(text: 'Software Engineer');
  final _companyController = TextEditingController(text: 'Tech Mahindra');
  final _incomeController = TextEditingController(text: '₹10 - ₹12 Lakhs');
  final _locationController = TextEditingController(text: 'Coimbatore, Tamil Nadu');

  // Step 4 Controllers
  final _fatherNameController = TextEditingController(text: 'M. Sundaram');
  final _motherNameController = TextEditingController(text: 'S. Lakshmi');
  final _siblingsController = TextEditingController(text: '1 Younger Sister');
  final _familyLocationController = TextEditingController(text: 'Coimbatore');
  final _familyDetailsController = TextEditingController(text: 'Upper Middle Class Nuclear Family');

  // Step 5 Controllers
  final _prefAgeController = TextEditingController(text: '23 - 27 Yrs');
  final _prefLocationController = TextEditingController(text: 'Coimbatore, Chennai');
  final _prefEducationController = TextEditingController(text: "Bachelor's Degree");
  final _prefOccupationController = TextEditingController(text: 'IT / Private Sector');

  // Step 6 Photos
  bool _hasUploadedPhoto = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _incomeController.dispose();
    _locationController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _siblingsController.dispose();
    _familyLocationController.dispose();
    _familyDetailsController.dispose();
    _prefAgeController.dispose();
    _prefLocationController.dispose();
    _prefEducationController.dispose();
    _prefOccupationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _createProfile();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      if (Navigator.canPop(context) && !(ModalRoute.of(context)?.isFirst ?? true)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _createProfile() {
    final name = _fullNameController.text.trim();
    if (name.isNotEmpty) {
      final newId = "PM${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
      final isGroom = _selectedGender.toLowerCase().contains('groom') || _selectedGender.toLowerCase().contains('male');
      final newProfile = ProfileModel(
        id: newId,
        name: name,
        nameTamil: name,
        gender: isGroom ? 'Groom' : 'Bride',
        age: int.tryParse(_ageController.text.trim()) ?? 26,
        height: _heightController.text.trim(),
        maritalStatus: _selectedMaritalStatus,
        motherTongue: _selectedMotherTongue,
        motherTongueTamil: 'தமிழ்',
        religion: _selectedReligion,
        community: _communityName,
        subSect: "பண்டாரத்தார் (Pandarathar)",
        education: _educationController.text.trim(),
        occupation: _occupationController.text.trim(),
        company: _companyController.text.trim(),
        annualIncome: _incomeController.text.trim(),
        location: _locationController.text.trim(),
        about: "Looking for an understanding partner from Pandarathar community.",
        fatherName: _fatherNameController.text.trim(),
        motherName: _motherNameController.text.trim(),
        siblings: _siblingsController.text.trim(),
        familyLocation: _familyLocationController.text.trim(),
        familyDetails: _familyDetailsController.text.trim(),
        preferredAge: _prefAgeController.text.trim(),
        preferredLocation: _prefLocationController.text.trim(),
        preferredEducation: _prefEducationController.text.trim(),
        preferredOccupation: _prefOccupationController.text.trim(),
        phone: "+91 98421 00000",
        whatsapp: "+91 98421 00000",
        email: "${name.toLowerCase().replaceAll(' ', '')}@pandarathar.com",
        isOnline: true,
        isVerified: true,
        imageAsset: null,
        avatarSeed: name,
      );

      AuthService().register(
        name: name,
        usernameOrPhone: name.toLowerCase().replaceAll(' ', ''),
        phone: '9842100000',
        password: 'password123',
        gender: isGroom ? 'Groom' : 'Bride',
      );
      MockDataService().updateUserProfile(newProfile);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Created Successfully! Welcome to Pandarathar Matrimony.'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Text(
          'Step $_currentStep of $_totalSteps',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "பின்செல்க / Back",
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepTitle(),
                    const SizedBox(height: 24),
                    _buildStepForm(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: _currentStep == _totalSteps ? 'Create Profile' : 'Continue',
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle() {
    String title = '';
    String subtitle = '';

    switch (_currentStep) {
      case 1:
        title = 'Basic Details';
        subtitle = 'Tell us about yourself to find your life partner.';
        break;
      case 2:
        title = 'Community Details';
        subtitle = 'Verified single-community matrimonial profile.';
        break;
      case 3:
        title = 'Education & Career';
        subtitle = 'Share your professional background.';
        break;
      case 4:
        title = 'Family Details';
        subtitle = 'Information about your family background.';
        break;
      case 5:
        title = 'Partner Preferences';
        subtitle = 'What are you looking for in a partner?';
        break;
      case 6:
        title = 'Profile Photos';
        subtitle = 'Profiles with photos get up to 5x more responses!';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepForm() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Basic();
      case 2:
        return _buildStep2Community();
      case 3:
        return _buildStep3Education();
      case 4:
        return _buildStep4Family();
      case 5:
        return _buildStep5Preferences();
      case 6:
        return _buildStep6Photos();
      default:
        return Container();
    }
  }

  // STEP 1: BASIC DETAILS
  Widget _buildStep1Basic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _fullNameController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),

        const Text(
          'Gender / Profile For',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Groom (Male)')),
                selected: _selectedGender == 'Groom',
                selectedColor: AppColors.primaryContainer,
                labelStyle: TextStyle(
                  color: _selectedGender == 'Groom' ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) => setState(() => _selectedGender = 'Groom'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Bride (Female)')),
                selected: _selectedGender == 'Bride',
                selectedColor: AppColors.primaryContainer,
                labelStyle: TextStyle(
                  color: _selectedGender == 'Bride' ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) => setState(() => _selectedGender = 'Bride'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Date of Birth',
                controller: _dobController,
                prefixIcon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Age',
                controller: _ageController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        CustomTextField(
          label: 'Height',
          hint: "e.g. 5'8\"",
          controller: _heightController,
          prefixIcon: Icons.height_rounded,
        ),

        const SizedBox(height: 18),
        const Text(
          'Marital Status',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMaritalStatus,
          decoration: const InputDecoration(),
          items: ['Never Married', 'Divorced', 'Widowed', 'Awaiting Divorce']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedMaritalStatus = val);
          },
        ),
      ],
    );
  }

  // STEP 2: COMMUNITY DETAILS
  Widget _buildStep2Community() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Community Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Exclusive Community App',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Community: $_communityName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'This application is exclusively for members of our community. No caste selection required.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Mother Tongue',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMotherTongue,
          decoration: const InputDecoration(),
          items: ['Tamil', 'Telugu', 'Malayalam', 'Kannada', 'English', 'Hindi']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedMotherTongue = val);
          },
        ),

        const SizedBox(height: 18),
        const Text(
          'Religion',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedReligion,
          decoration: const InputDecoration(),
          items: ['Hindu', 'Christian', 'Muslim', 'Jain', 'Other']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedReligion = val);
          },
        ),
      ],
    );
  }

  // STEP 3: EDUCATION & CAREER
  Widget _buildStep3Education() {
    return Column(
      children: [
        CustomTextField(
          label: 'Highest Education',
          hint: 'e.g. B.E. Computer Science, MBA',
          controller: _educationController,
          prefixIcon: Icons.school_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Occupation',
          hint: 'e.g. Software Engineer, Bank Manager',
          controller: _occupationController,
          prefixIcon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Company Name',
          hint: 'e.g. TCS, Government Service',
          controller: _companyController,
          prefixIcon: Icons.business_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Annual Income',
          hint: 'e.g. ₹10 - ₹12 Lakhs',
          controller: _incomeController,
          prefixIcon: Icons.payments_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Current Location',
          hint: 'e.g. Coimbatore, Tamil Nadu',
          controller: _locationController,
          prefixIcon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  // STEP 4: FAMILY DETAILS
  Widget _buildStep4Family() {
    return Column(
      children: [
        CustomTextField(
          label: "Father's Name & Occupation",
          hint: "e.g. K. Sundaram (Business)",
          controller: _fatherNameController,
          prefixIcon: Icons.face_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: "Mother's Name & Occupation",
          hint: "e.g. S. Lakshmi (Homemaker)",
          controller: _motherNameController,
          prefixIcon: Icons.face_3_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Siblings',
          hint: 'e.g. 1 Brother (Married), 1 Sister',
          controller: _siblingsController,
          prefixIcon: Icons.group_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Native Family Location',
          hint: 'e.g. Coimbatore, Tamil Nadu',
          controller: _familyLocationController,
          prefixIcon: Icons.home_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Family Details / Values',
          hint: 'e.g. Upper Middle Class Nuclear Family',
          controller: _familyDetailsController,
          prefixIcon: Icons.info_outline_rounded,
        ),
      ],
    );
  }

  // STEP 5: PARTNER PREFERENCES
  Widget _buildStep5Preferences() {
    return Column(
      children: [
        CustomTextField(
          label: 'Preferred Age Group',
          hint: 'e.g. 23 - 27 Yrs',
          controller: _prefAgeController,
          prefixIcon: Icons.cake_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Preferred Location',
          hint: 'e.g. Coimbatore, Chennai, Bengaluru',
          controller: _prefLocationController,
          prefixIcon: Icons.map_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Preferred Education',
          hint: "e.g. Bachelor's or Master's Degree",
          controller: _prefEducationController,
          prefixIcon: Icons.school_outlined,
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Preferred Occupation',
          hint: 'e.g. IT Professional, Govt Employee, Teacher',
          controller: _prefOccupationController,
          prefixIcon: Icons.work_outline_rounded,
        ),
      ],
    );
  }

  // STEP 6: PROFILE PHOTOS
  Widget _buildStep6Photos() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 54,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Upload Profile Picture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Photo will be visible to matched profiles.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _hasUploadedPhoto = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mock Photo Selected!')),
                  );
                },
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text(_hasUploadedPhoto ? 'Change Photo' : 'Upload Photo'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Additional Photos Placeholders
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryLight, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Photo ${index + 2}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
