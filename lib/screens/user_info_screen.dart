import 'package:flutter/material.dart';
import '../../widgets/core_elements.dart';
import 'package:provider/provider.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/user_settings_model.dart' as AppUser; 
import '../providers/user_profile_provider.dart'; 



class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {

   AppUser.Gender? _selectedGender = AppUser.Gender.female;
  double _age = 33;
  double _weight = 57;
  double _height = 125;
  TimeOfDay _wakeTime = const TimeOfDay(hour: 9, minute: 41);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 41);
  String _selectedClimate = "hot";
  
  bool _isLoading = false;

Future<void> _saveAndContinue() async {

  if (_selectedGender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a gender')),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: No user logged in!')),
    );
    return;
  }

  setState(() => _isLoading = true);


  int _calculateDailyGoal(int weight, String climate, int age) {
    double goal = weight * 35.0; 
    if (climate == 'hot') {
      goal += 500;
    }
    if (age > 55) {
      goal *= 0.9;
    }
    return (goal / 50).round() * 50;
  }

  final int calculatedGoal = _calculateDailyGoal(
    _weight.round(),
    _selectedClimate,
    _age.round(),
  );


  final settings = AppUser.UserSettings(
    uid: user.uid,
    email: user.email ?? '', 
    displayName: user.displayName ?? 'New User',
    age: _age.round(),
    gender: _selectedGender!, 
    weight: _weight.round(),
    height: _height.round(),
    wakeTime: _wakeTime,
    sleepTime: _sleepTime,
    climate: _selectedClimate,
    profileImageUrl: user.photoURL,
    dailyGoal: calculatedGoal, 
  );

  try {

    await context.read<UserProfileProvider>().updateUserSettings(settings);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Let us now you betterrrr',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
      ),
      body: SafeArea(

        child: IgnorePointer(
          ignoring: _isLoading,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('What is your gender'),
                      const SizedBox(height: 10),
                      _buildGenderSelector(),
                      const SizedBox(height: 22),
                      
                      _buildSectionTitle('How old are you'),
                      _buildSlider(
                        value: _age,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (val) => setState(() => _age = val),
                      ),
                      const SizedBox(height: 22),
                      
                      _buildSectionTitle('What is your weight (in kg)'),
                      _buildSlider(
                        value: _weight,
                        min: 0,
                        max: 200,
                        divisions: 200,
                        onChanged: (val) => setState(() => _weight = val),
                      ),
                      const SizedBox(height: 22),
                      
                      _buildSectionTitle('What is your height (in cm)'),
                      _buildSlider(
                        value: _height,
                        min: 0,
                        max: 200,
                        divisions: 200,
                        onChanged: (val) => setState(() => _height = val),
                      ),
                      const SizedBox(height: 22),
                      
                      _buildSectionTitle('Sleep time'),
                      const SizedBox(height: 10),
                      _buildTimePickers(),
                      const SizedBox(height: 22),
                      
                      _buildClimateChip(),
                      const SizedBox(height: 38),
                      
                      _buildBottomNavigation(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(

                    child: CircularProgressIndicator(), 
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        _buildGenderCircle('assets/images/boy.png', AppUser.Gender.male),
        _buildGenderCircle('assets/images/girl.png', AppUser.Gender.female),
        _buildGenderCircle('assets/images/no_gender.png', AppUser.Gender.other),
      ],
    );
  }

  Widget _buildGenderCircle(String imagePath, AppUser.Gender gender) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender as AppUser.Gender?),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF38B6FF), width: 3),
                  )
                : null,
            child: CircleAvatar(
              radius: 47,
              backgroundColor: const Color.fromARGB(255, 21, 8, 62),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF38B6FF),
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF38B6FF),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFF38B6FF),
            overlayColor: const Color(0xFF38B6FF).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFF38B6FF),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(min.round().toString(), style: const TextStyle(color: Colors.grey)),
            Text(max.round().toString(), style: const TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildTimePickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBox(_wakeTime, () => _selectTime(context, isWakeTime: true)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            ':',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        _buildTimeBox(_sleepTime, () => _selectTime(context, isWakeTime: false)),
      ],
    );
  }

  Widget _buildTimeBox(TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          time.format(context),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, {required bool isWakeTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWakeTime ? _wakeTime : _sleepTime,
    );
    if (picked != null) {
      setState(() {
        if (isWakeTime) {
          _wakeTime = picked;
        } else {
          _sleepTime = picked;
        }
      });
    }
  }

  Widget _buildClimateChip() {
    return Center(
      child: ActionChip(
        onPressed: () {
          // TODO: Додати логіку для зміни клімату, напр. діалог
          print('Change climate tapped');
        },
        avatar: Icon(Icons.wb_sunny_outlined, color: Colors.grey[700]),
        label: Text(
          'Climat: $_selectedClimate',
          style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/main');
          },
          child: const Text(
            '← Skip',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        SizedBox(
          width: 150,
          child: PrimaryButton(
            text: 'Next →',
            onPressed: _isLoading ? null : () => _saveAndContinue(),
          ),
        ),
      ],
    );
  }
}