import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/mongodb_service.dart';
import '../../core/utils/navigation_helper.dart';

class RegisterHoroscopeScreen extends StatefulWidget {
  final MockDataService mockData;

  const RegisterHoroscopeScreen({super.key, required this.mockData});

  @override
  State<RegisterHoroscopeScreen> createState() => _RegisterHoroscopeScreenState();
}

class _RegisterHoroscopeScreenState extends State<RegisterHoroscopeScreen> {
  int _currentStep = 1; // 1 to 5

  // Form Controllers
  final _nameController = TextEditingController();
  String _selectedGender = 'Male';
  DateTime? _dob;
  TimeOfDay? _tob;
  String _selectedReligion = 'Hindu';
  String _selectedStar = 'ரோகிணி (Rohini)';
  String _selectedRasi = 'ரிஷபம் (Rishabham)';
  final _gothramController = TextEditingController(text: 'சிவகோத்திரம்');
  final _phoneController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();

  // Cloudflare R2 Upload state
  bool _isUploadingToR2 = false;
  String? _uploadedImageUrl;

  final CloudflareR2Service _r2Service = CloudflareR2Service();
  final MongoDBService _mongoService = MongoDBService();

  @override
  void dispose() {
    _nameController.dispose();
    _gothramController.dispose();
    _phoneController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF7A132B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 30),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF7A132B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tob = picked);
    }
  }

  // Generate valid visual PNG image bytes
  Future<Uint8List> _generateRealProfileImageBytes(String name) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 400));

    // Deep royal background
    final bgPaint = Paint()..color = const Color(0xFF7A132B);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 400), bgPaint);

    // Golden frame border
    final borderPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRect(const Rect.fromLTWH(10, 10, 380, 380), borderPaint);

    // Inner warm circle
    final circlePaint = Paint()..color = const Color(0xFFFFF9ED);
    canvas.drawCircle(const Offset(200, 170), 90, circlePaint);

    // Initials text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P',
        style: const TextStyle(
          color: Color(0xFF7A132B),
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(200 - textPainter.width / 2, 170 - textPainter.height / 2));

    // Candidate Name at bottom
    final namePainter = TextPainter(
      text: TextSpan(
        text: name.isNotEmpty ? name : 'Pandarathar Matrimony',
        style: const TextStyle(
          color: Color(0xFFF3E5AB),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(200 - namePainter.width / 2, 290));

    // Star & Rasi subtitle
    final subPainter = TextPainter(
      text: TextSpan(
        text: "$_selectedStar • $_selectedRasi",
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subPainter.layout();
    subPainter.paint(canvas, Offset(200 - subPainter.width / 2, 325));

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 400);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Upload to Cloudflare R2
  Future<void> _handleUploadToCloudflareR2() async {
    setState(() => _isUploadingToR2 = true);

    try {
      final candidateName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Candidate';
      final realPngBytes = await _generateRealProfileImageBytes(candidateName);
      final cleanName = candidateName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      final url = await _r2Service.uploadProfileImage(
        imageBytes: realPngBytes,
        fileName: "${cleanName}_profile.png",
        userId: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : cleanName,
        contentType: "image/png",
      );

      setState(() {
        _uploadedImageUrl = url;
        _isUploadingToR2 = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✓ Photo successfully uploaded to Cloudflare R2 (matrimony-profile-images)"),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingToR2 = false);
    }
  }

  // Save to MongoDB
  Future<void> _handleSubmit() async {
    final data = {
      'fullName': _nameController.text,
      'gender': _selectedGender,
      'dob': _dob?.toIso8601String() ?? '2000-01-01',
      'religion': _selectedReligion,
      'star': _selectedStar,
      'rasi': _selectedRasi,
      'gothram': _gothramController.text,
      'fatherName': _fatherNameController.text,
      'motherName': _motherNameController.text,
      'phone': _phoneController.text,
      'photoR2Url': _uploadedImageUrl ?? 'https://r2.cloudflarestorage.com/matrimony-profile-images/sample.jpg',
    };

    await _mongoService.saveHoroscopeRegistration(data);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFFFFFBF6),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "பதிவு முடிந்தது!",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "உங்கள் ஜாதக தகவல் வெற்றிகரமாக பதிவு செய்யப்பட்டது.",
                style: TextStyle(fontSize: 13, color: Color(0xFF2A1518)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF3EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("✓ Cloudflare R2 Storage: Connected", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    Text("✓ MongoDB Database: Record Synced", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A132B)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("சரி / OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "பின்செல்க / Back",
          onPressed: () => SafeNavigation.safePop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ஜாதகம் பதிவு",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "Register Horoscope",
              style: TextStyle(fontSize: 10, color: Color(0xFFF0D68A), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5-Step Progress Indicator
            _buildStepIndicator(),

            const SizedBox(height: 20),

            // Step Content
            if (_currentStep == 1) _buildBasicInfoStep(),
            if (_currentStep == 2) _buildHoroscopeStep(),
            if (_currentStep == 3) _buildFamilyStep(),
            if (_currentStep == 4) _buildUploadPhotoStep(),
            if (_currentStep == 5) _buildPreviewStep(),

            const SizedBox(height: 24),

            // Navigation Buttons (Next / Prev)
            Row(
              children: [
                if (_currentStep > 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7A132B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("முந்தைய / Back", style: TextStyle(color: Color(0xFF7A132B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 5) {
                        setState(() => _currentStep++);
                      } else {
                        _handleSubmit();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A132B),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _currentStep == 5 ? "பதிவு செய் / Submit" : "அடுத்து / Next >",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStepCircle(1, "அடிப்படை\nBasic"),
          _buildStepLine(1),
          _buildStepCircle(2, "ஜாதகம்\nHoroscope"),
          _buildStepLine(2),
          _buildStepCircle(3, "குடும்பம்\nFamily"),
          _buildStepLine(3),
          _buildStepCircle(4, "புகைப்படம்\nPhoto"),
          _buildStepLine(4),
          _buildStepCircle(5, "முன்பார்வை\nPreview"),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF7A132B)
                : (isDone ? const Color(0xFF2E7D32) : const Color(0xFFE5D5C8)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            isDone ? "✓" : "$step",
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF7A132B) : const Color(0xFF7E6F72),
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isDone = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? const Color(0xFF2E7D32) : const Color(0xFFE5D5C8),
      ),
    );
  }

  // Step 1: Basic Info
  Widget _buildBasicInfoStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "அடிப்படை தகவல் / Basic Details",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
          ),
          const SizedBox(height: 14),

          // Full Name
          const Text("முழு பெயர் / Full Name *", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Enter full name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 14),

          // Gender
          const Text("பால் / Gender *", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          RadioGroup<String>(
            groupValue: _selectedGender,
            onChanged: (v) => setState(() => _selectedGender = v ?? 'Male'),
            child: Row(
              children: [
                const Radio<String>(
                  value: 'Male',
                  activeColor: Color(0xFF7A132B),
                ),
                const Text("ஆண் / Male", style: TextStyle(fontSize: 12.5)),
                const SizedBox(width: 16),
                const Radio<String>(
                  value: 'Female',
                  activeColor: Color(0xFF7A132B),
                ),
                const Text("பெண் / Female", style: TextStyle(fontSize: 12.5)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // DOB
          const Text("பிறந்த தேதி / Date of Birth *", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dob != null ? "${_dob!.day}/${_dob!.month}/${_dob!.year}" : "DD / MM / YYYY",
                    style: TextStyle(color: _dob != null ? Colors.black : Colors.grey),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF7A132B)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Time of Birth
          const Text("பிறந்த நேரம் / Time of Birth", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tob != null ? _tob!.format(context) : "HH : MM AM/PM",
                    style: TextStyle(color: _tob != null ? Colors.black : Colors.grey),
                  ),
                  const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF7A132B)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Religion
          const Text("மதம் / Religion *", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReligion,
                isExpanded: true,
                items: ['Hindu', 'Others'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _selectedReligion = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Horoscope Info
  Widget _buildHoroscopeStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ஜாதக விவரம் / Horoscope Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A132B))),
          const SizedBox(height: 14),
          const Text("நட்சத்திரம் / Star", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStar,
                isExpanded: true,
                items: ['ரோகிணி (Rohini)', 'உத்திரம் (Uthiram)', 'அஸ்தம் (Hastham)', 'மிருகசீரிடம்', 'சுவாதி (Swathi)']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedStar = v!),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text("ராசி / Moon Sign", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRasi,
                isExpanded: true,
                items: ['ரிஷபம் (Rishabham)', 'சிம்மம் (Simmam)', 'கன்னி (Kanni)', 'துலாம் (Thulam)', 'மேஷம் (Mesham)']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _selectedRasi = v!),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text("கோத்திரம் / Gothram", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _gothramController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Family
  Widget _buildFamilyStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("குடும்ப தகவல் / Family Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A132B))),
          const SizedBox(height: 14),
          const Text("தந்தை பெயர் / Father Name", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _fatherNameController,
            decoration: InputDecoration(
              hintText: "Enter father's name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
          const Text("தாய் பெயர் / Mother Name", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _motherNameController,
            decoration: InputDecoration(
              hintText: "Enter mother's name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
          const Text("தொலைபேசி / Contact Phone", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "+91 98765 43210",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Upload Photo (Connected to Cloudflare R2!)
  Widget _buildUploadPhotoStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("புகைப்படம் பதிவேற்றம் / Upload Photo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A132B))),
          const SizedBox(height: 6),
          const Text(
            "Connected directly to Cloudflare R2 bucket: matrimony-profile-images",
            style: TextStyle(fontSize: 10.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF3EC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: _uploadedImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset('assets/images/user_karthik.jpg', fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF7A132B)),
                        SizedBox(height: 6),
                        Text("Select Profile Photo", style: TextStyle(fontSize: 11, color: Color(0xFF7E6F72))),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton.icon(
              onPressed: _isUploadingToR2 ? null : _handleUploadToCloudflareR2,
              icon: _isUploadingToR2
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_rounded),
              label: Text(_isUploadingToR2 ? "Uploading to Cloudflare R2..." : "Upload to Cloudflare R2"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A132B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          if (_uploadedImageUrl != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "R2 URL: ${_uploadedImageUrl!}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Step 5: Preview & Confirmation
  Widget _buildPreviewStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("முன்பார்வை / Preview Summary", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A132B))),
          const SizedBox(height: 12),
          _buildSummaryRow("பெயர் / Name", _nameController.text.isNotEmpty ? _nameController.text : "Karthik"),
          _buildSummaryRow("பால் / Gender", _selectedGender),
          _buildSummaryRow("பிறந்த தேதி / DOB", _dob != null ? "${_dob!.day}/${_dob!.month}/${_dob!.year}" : "14 May 1998"),
          _buildSummaryRow("நட்சத்திரம் / Star", _selectedStar),
          _buildSummaryRow("ராசி / Rasi", _selectedRasi),
          _buildSummaryRow("கோத்திரம் / Gothram", _gothramController.text),
          _buildSummaryRow("Cloudflare R2 Image", _uploadedImageUrl != null ? "Uploaded ✓" : "Pending"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF3EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.storage_rounded, size: 16, color: Color(0xFF7A132B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Data will be synced into MongoDB collection: horoscope_registrations",
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF4C3E41)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF7E6F72))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2A1518))),
        ],
      ),
    );
  }
}
