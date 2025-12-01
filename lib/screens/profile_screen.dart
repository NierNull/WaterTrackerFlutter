import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import '../models/user_settings_model.dart' as AppUser;
import '../providers/user_profile_provider.dart'; 

import 'package:image_picker/image_picker.dart'; 
import 'dart:io';


class SpinningLoader extends StatefulWidget {
  final String imagePath;
  final double size;
  const SpinningLoader({
    super.key,
    required this.imagePath,
    this.size = 80.0,
  });
  @override
  State<SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<SpinningLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        widget.imagePath,
        width: widget.size,
        height: widget.size,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  final ImagePicker _picker = ImagePicker();
  
Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return; 

    try {

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, 
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        
        final provider = context.read<UserProfileProvider>();

        await provider.updateProfileImage(imageFile);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile photo updated!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update photo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    final profileProvider = context.watch<UserProfileProvider>();
    final settings = profileProvider.userSettings; 

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 254, 255),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF38B6FF), size: 28),
            onPressed: () {

              Navigator.pushNamed(context, '/user_info');
              print('Edit profile tapped');
            },
            splashRadius: 24,
          ),
        ],
      ),

      body: SafeArea(
        child: profileProvider.isLoading
            ? Center(

                child: SpinningLoader(
                  imagePath: 'assets/images/loader.png', 
                  size: 60,
                ),
              )
            : settings == null
                ? Center(

                    child: Text(
                      'Could not load profile.\nPlease log in again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700], fontSize: 16),
                    ),
                  )
                : _buildProfileBody(settings), 
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Будує тіло профілю, використовуючи завантажені [settings]
  Widget _buildProfileBody(AppUser.UserSettings settings) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Stack(
                clipBehavior: Clip.none, 
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 3, 21, 41),
                child: settings.profileImageUrl != null
                    ? ClipOval(

                        child: Image.network(
                          settings.profileImageUrl!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,

                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : const CircularProgressIndicator();
                          },

                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Colors.white, size: 50),
                        ),
                      )
                    : Padding(

                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          settings.gender == AppUser.Gender.male
                              ? 'assets/images/boy.png'
                              : 'assets/images/girl.png',
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 4,
                             offset: const Offset(1, 1),
                           )
                        ]
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Color(0xFF38B6FF), size: 20),
                        onPressed: () {

                          _pickImage(context);
                        },
                        splashRadius: 20,
                      ),
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(height: 32),

            _buildReadOnlyTextField('Your Name', settings.displayName),
            const SizedBox(height: 5),
            _buildReadOnlyTextField('Email Address', settings.email),
            const SizedBox(height: 5),
            _buildReadOnlyTextField('Age', settings.age.toString()),
            const SizedBox(height: 5),
            _buildReadOnlyTextField('Weight (kg)', settings.weight.toString()),
            const SizedBox(height: 5),
            _buildReadOnlyTextField('Height (cm)', settings.height.toString()),
            const SizedBox(height: 5),

            _buildSectionTitle('Gender'),
            const SizedBox(height: 12),
            _buildGenderSelector(settings.gender), 
            const SizedBox(height: 15),

            _buildSectionTitle('Sleep time'),
            const SizedBox(height: 5),
            _buildReadOnlyTimePickers(settings.wakeTime, settings.sleepTime),
            const SizedBox(height: 15),

            _buildSectionTitle('Climate'),
            const SizedBox(height: 5),
            _buildReadOnlyChip(settings.climate),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color.fromARGB(255, 15, 14, 14),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 219, 240, 253),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(255, 219, 240, 253)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(AppUser.Gender currentGender) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildGenderOption(currentGender, AppUser.Gender.male, 'Male'),
        const SizedBox(width: 5),
        _buildGenderOption(currentGender, AppUser.Gender.female, 'Female'),
        const SizedBox(width: 5),
        _buildGenderOption(currentGender, AppUser.Gender.other, 'Other'),
      ],
    );
  }

  Widget _buildGenderOption(
      AppUser.Gender groupValue, AppUser.Gender genderValue, String label) {
    return Row(
      children: [
        Radio<AppUser.Gender>(
          value: genderValue,
          groupValue: groupValue,
          onChanged: null, 
          activeColor: const Color(0xFF38B6FF),
        ),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
      ],
    );
  }

  Widget _buildReadOnlyTimePickers(TimeOfDay wakeTime, TimeOfDay sleepTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBox(wakeTime),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            ':',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        _buildTimeBox(sleepTime),
      ],
    );
  }

  Widget _buildTimeBox(TimeOfDay time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 219, 240, 253),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 219, 240, 253)),
      ),
      child: Text(
        time.format(context),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReadOnlyChip(String climate) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(Icons.wb_sunny_outlined, color: const Color.fromARGB(255, 219, 240, 253)),
        label: Text(
          'Climat: $climate',
          style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 27, 27, 27), fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 219, 240, 253),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.analytics_outlined, 'Analysis', 1),
          _buildNavItem(Icons.settings_outlined, 'Setting', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected ? const Color.fromARGB(255, 43, 171, 245) : Colors.black;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/main');
        } else if (index == 1) {

          Navigator.pushReplacementNamed(context, '/analytics');
        } else if (index != 3) {
          // TODO: Додати навігацію для 'Setting' (2)
          print('Navigate to $label');
        }

      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}