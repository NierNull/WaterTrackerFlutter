import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; 
import '../models/drink_record_model.dart'; 
import '../providers/drink_records_provider.dart'; 
import '../providers/user_profile_provider.dart'; 
import '../../widgets/core_elements.dart';

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


class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedTabIndex = 0;
  DateTime _selectedDate = DateTime.now(); 
  int _selectedIndex = 1;

 @override
  void initState() {
    super.initState();
    final recordsProvider =
        Provider.of<DrinkRecordsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedDate(DateTime.now(), recordsProvider);
    });
  }

  void _updateSelectedDate(DateTime newDate, DrinkRecordsProvider provider) {
    setState(() {
      _selectedDate = newDate;
    });
    provider.getRecordsForDate(newDate);
  }

Future<void> _showEditDrinkDialog(DrinkRecord record) async {

    final TextEditingController amountController =
        TextEditingController(text: record.amount.toString());
    
    final newAmount = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${record.drinkName}'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter new amount (in ml)'),
              const SizedBox(height: 16),
              AppTextField(
                controller: amountController,
                hintText: 'Amount',
                prefixIcon: Icons.local_drink_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            PrimaryButton(
              text: 'Save',
              onPressed: () {

                final int? amount = int.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.of(dialogContext).pop(amount); 
                } else {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number')),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (newAmount != null) {
      final updatedRecord = DrinkRecord(
        id: record.id, 
        amount: newAmount,
        drinkName: record.drinkName,
        timestamp: record.timestamp, 
      );
      
      await context.read<DrinkRecordsProvider>().updateDrinkRecord(updatedRecord);
    }
  }


  @override
  Widget build(BuildContext context) {
    const Color screenBlue = Color(0xFF62A8E5);
    const Color cardBlue = Color(0xFF7BC0F7);

    final recordsProvider = context.watch<DrinkRecordsProvider>();
    final profileProvider = context.watch<UserProfileProvider>();

    final int goalMl = profileProvider.dailyGoal;

    return Scaffold(
      backgroundColor: screenBlue,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildTopTabBar(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDateSelector(recordsProvider),
            Padding(
              padding: const EdgeInsets.all(20.0),

              child: StreamBuilder<List<DrinkRecord>>(
                  stream: recordsProvider.recordsStream,
                  builder: (context, snapshot) {

                    int totalMl = 0;
                    if (snapshot.hasData) {
                      totalMl = snapshot.data!
                          .fold(0, (sum, item) => sum + item.amount);
                    }
                    return _buildChartCard(cardBlue, totalMl, goalMl);
                  }),
            ),

            Expanded(
              child: StreamBuilder<List<DrinkRecord>>(
                stream: recordsProvider.recordsStream,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinningLoader(
                        imagePath:
                            'assets/images/loader.png', 
                        size: 60,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No records for this day.',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                    );
                  }

                  final records = snapshot.data!; 
                  return _buildHistoryList(cardBlue, records);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopTabBar(BuildContext context) {
    const Color tabBlue = Color(0xFF4A90E2);
    return Container(
      color: tabBlue,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem("DAY", 0),
            _buildTabItem("WEEK", 1),
            _buildTabItem("MONTH", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String text, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        decoration: isSelected
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 3),
                ),
              )
            : null,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
Widget _buildDateSelector(DrinkRecordsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => _updateSelectedDate(
                _selectedDate.subtract(const Duration(days: 1)), provider),
          ),
          Text(
            DateFormat('yyyy-MM-dd').format(_selectedDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => _updateSelectedDate(
                _selectedDate.add(const Duration(days: 1)), provider),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(Color cardBlue, int totalMl, int goalMl) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          _buildStatsHeader(totalMl, goalMl),
          const SizedBox(height: 20),
          _buildSimplifiedChart(totalMl, goalMl),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(int totalMl, int goalMl) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              '$totalMl ml',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Goal',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              '$goalMl ml',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimplifiedChart(int totalMl, int goalMl) {

    final int effectiveGoal = goalMl > 0 ? goalMl : 2000;
    final int maxY = (effectiveGoal > totalMl ? effectiveGoal : totalMl) + 200;
    
    final yLabels = [
      (maxY).round().toString(),
      (maxY * 0.75).round().toString(),
      (maxY * 0.5).round().toString(),
      (maxY * 0.25).round().toString(),
      '0'
    ];
    final xLabels = ['0', '4', '8', '12', '16', '20', '24'];

    double linePosition =
        (totalMl > 0 && maxY > 0) ? (1.0 - (totalMl / maxY)) : 1.0;
    if (linePosition < 0) linePosition = 0.0;
    if (linePosition > 1) linePosition = 1.0;

    const double chartHeight = 155.0;
    double lineTopPosition = (linePosition * (chartHeight - 20)) + 10;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: yLabels
              .map((label) => Padding(
                    padding: const EdgeInsets.only(bottom: 25.0, right: 8.0),
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ))
              .toList(),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: chartHeight,
                child: Stack(
                  children: [
                    for (int i = 0; i < yLabels.length; i++)
                      Positioned(
                        top: (i * 31.0) + 10,
                        left: 0,
                        right: 0,
                        child: Container(
                            height: 1, color: Colors.white.withOpacity(0.2)),
                      ),
                    Positioned(
                      top: lineTopPosition,
                      left: 0,
                      right: 15,
                      child: Row(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dashWidth = 4.0;
                                final dashSpace = 4.0;
                                final dashCount = (constraints.maxWidth /
                                        (dashWidth + dashSpace))
                                    .floor();
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(dashCount, (_) {
                                    return Container(
                                      width: dashWidth,
                                      height: 2,
                                      color: Colors.white,
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: xLabels
                    .map((label) => Text(label,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(Color cardBlue, List<DrinkRecord> records) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final item = records[index];
        return _buildHistoryItem(item, cardBlue);
      },
    );
  }

  Widget _buildHistoryItem(DrinkRecord item, Color cardBlue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.amount}ml',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(item.timestamp.toDate()),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.drinkName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {

              _showEditDrinkDialog(item);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              if (item.id != null) {
                context.read<DrinkRecordsProvider>().deleteDrink(item.id!);
              }
            },
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
    final color = isSelected ? const Color(0xFF38B6FF) : Colors.black;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/main');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        } else if (index != 1) {
          // TODO: Навігація для Settings (2)
          print('Navigate to $label');
        }

      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}