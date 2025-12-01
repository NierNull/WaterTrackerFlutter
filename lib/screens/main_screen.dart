import 'package:flutter/material.dart';
import '../../widgets/core_elements.dart'; 
import '../../services/analytics_service.dart';
import 'package:provider/provider.dart'; 
import '../providers/user_profile_provider.dart'; 
import '../providers/drink_records_provider.dart';
import '../models/drink_record_model.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
@override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      Provider.of<DrinkRecordsProvider>(context, listen: false)
          .getRecordsForDate(DateTime.now());
    });
  }
  @override
  Widget build(BuildContext context) {
    AnalyticsService.logScreenView('HomeScreen');

    final profileProvider = context.watch<UserProfileProvider>();
    final recordsProvider = context.watch<DrinkRecordsProvider>();
    

    final int goalMl = profileProvider.dailyGoal;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 46.0, 30.0, 26.0),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 14),
              _buildReminderCard(),
              const SizedBox(height: 34),

              Expanded(
                child: _buildCatTracker(goalMl),
              ),
              
              PrimaryButton(
                text: '+DRINK',
                onPressed: () {

                  Navigator.pushNamed(context, '/water_amount', arguments: null);
                },
              ),
              const SizedBox(height: 8),

              StreamBuilder<List<DrinkRecord>>(
                stream: recordsProvider.recordsStream, 
                builder: (context, snapshot) {
                  int totalMl = 0;
                  double percentage = 0.0;

                  if (snapshot.hasData) {

                    totalMl = snapshot.data!.fold(0, (sum, item) => sum + item.amount);
                    if (goalMl > 0) {
                      percentage = (totalMl / goalMl) * 100;
                    }
                  }

                  String message = "You got ${percentage.toStringAsFixed(0)}% of today's goal, keep focus on your health!";
                  if (percentage >= 100) {
                    message = "Great job! You've reached your goal of $goalMl ml!";
                  }

                  return Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  );
                }
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black, size: 30),
                onPressed: () {},
                splashRadius: 20,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderCard() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/reminder_image.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Next reminder: 7:00', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('200ml water (2 Glass)', style: TextStyle(color: Colors.blue.shade800)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Add Your Goal'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCatTracker(int goalMl) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Image.asset(
              'assets/images/cat_image.png',
              height: 250,
            ),
          ),
          Positioned(
            top: 20,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Target', style: TextStyle(color: Colors.grey)),

                  Text(
                    '${goalMl}ml', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final color = isSelected ? Colors.blue : Colors.black;

    return GestureDetector(
     onTap: () {

        if (index == 3) {

          Navigator.pushNamed(context, '/profile');
        } else 
        if (index == 1) {

          Navigator.pushNamed(context, '/analytics');
        } else{

          setState(() {
            _selectedIndex = index;
          });

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
