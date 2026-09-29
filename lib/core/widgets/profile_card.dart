import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../features/main_navigation_screen.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final VoidCallback onShortlistToggle;
  final VoidCallback onSendInterest;
  final VoidCallback? onUnlockContact;
  final MockDataService? mockData;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onShortlistToggle,
    required this.onSendInterest,
    this.onUnlockContact,
    this.mockData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A132B).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Photo & Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Candidate Photo Portrait
                    _buildCandidatePhoto(),
                    const SizedBox(width: 12),

                    // Candidate Information Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: ID + Badges + Heart
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBF4ED),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2CA7E)),
                                ),
                                child: Text(
                                  profile.id,
                                  style: const TextStyle(
                                    color: Color(0xFF7A132B),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (profile.isContactUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'தொடர்பு திறக்கப்பட்டது ✓',
                                    style: TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else if (profile.specialBadge != null && profile.specialBadge!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF9E6),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: const Color(0xFFF0D68A)),
                                  ),
                                  child: Text(
                                    profile.specialBadge!,
                                    style: const TextStyle(
                                      color: Color(0xFF8C7355),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              // Circular Heart Action Button
                              InkWell(
                                onTap: onShortlistToggle,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: profile.isShortlisted ? const Color(0xFFFFF0F3) : const Color(0xFFFAF7F5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: profile.isShortlisted ? const Color(0xFFFFC1CC) : const Color(0xFFEDE0D5),
                                    ),
                                  ),
                                  child: Icon(
                                    profile.isShortlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: profile.isShortlisted ? const Color(0xFFFF3366) : const Color(0xFF9E8F92),
                                    size: 19,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // Name
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E151A),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Age & Height
                          Text(
                            "${profile.age} வயது • ${profile.height}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A132B),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Education & Occupation
                          Row(
                            children: [
                              const Icon(Icons.school_outlined, size: 13, color: Color(0xFF8C7355)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  profile.degree != null && profile.degree!.isNotEmpty
                                      ? "${profile.degree} • ${profile.occupation}"
                                      : "${profile.education} • ${profile.occupation}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF5C474B),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Star & Location
                          Row(
                            children: [
                              if (profile.star != null) ...[
                                const Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  profile.star!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF580B23),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              const Icon(Icons.location_on_outlined, color: Color(0xFF8C1D38), size: 13),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  profile.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B5458),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0E5DB)),
                const SizedBox(height: 10),

                // Bottom Actions: Fixed Height (38px) & Perfectly Aligned
                Row(
                  children: [
                    // 1. View Option (Fixed Height 38px)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.visibility_outlined, size: 15, color: Color(0xFF7A132B)),
                          label: const Text(
                            'விவரம் / View',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A132B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDFBF9),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            side: const BorderSide(color: Color(0xFF7A132B), width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 2. Payment Option (Fixed Height 38px)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 38,
                        child: _buildPaymentButton(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCandidatePhoto() {
    final hasImage = profile.imageAsset != null && profile.imageAsset!.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 74,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.5),
            child: hasImage
                ? Image.asset(
                    profile.imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(74, 92),
                  )
                : _buildFallbackAvatar(74, 92),
          ),
        ),
        if (profile.isOnline)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        if (profile.isVerified)
          Positioned(
            top: 3,
            left: 3,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 13,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackAvatar(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8C2C41), Color(0xFF580B23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
          color: const Color(0xFFF3E5AB),
          size: 34,
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    if (profile.isContactUnlocked) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check_circle_rounded, size: 14),
        label: const Text(
          'தொடர்பு எண் ✓',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B6B38),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        // Like the profile if not already liked
        if (mockData != null && !profile.isShortlisted) {
          mockData!.toggleShortlist(profile.id);
        }
        // Navigate to the liked / shortlist page (tab index 3)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(initialIndex: 3),
          ),
          (route) => false,
        );
      },
      icon: const Icon(
        Icons.favorite_rounded,
        size: 14,
        color: Color(0xFFF0D68A),
      ),
      label: const Text(
        'விருப்பம் ₹25',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A132B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        shadowColor: const Color(0xFF7A132B).withValues(alpha: 0.3),
      ),
    );
  }
}
