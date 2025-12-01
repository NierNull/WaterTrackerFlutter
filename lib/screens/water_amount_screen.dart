import 'package:flutter/material.dart';
import '../../widgets/core_elements.dart'; 
import '../../services/analytics_service.dart';
import 'package:provider/provider.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/drink_model.dart';
import '../models/drink_record_model.dart';
import '../providers/drink_records_provider.dart';

class AddDrinkScreen extends StatefulWidget {
  const AddDrinkScreen({super.key});

  @override
  State<AddDrinkScreen> createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends State<AddDrinkScreen> {

  int _currentAmountMl = 200;
  
  bool _isLoading = false;
  Drink? _selectedDrink;
  bool _didLoadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
if (!_didLoadArgs) {
      try {
        final drink = ModalRoute.of(context)!.settings.arguments as Drink?;
        if (drink != null) {
          setState(() {
            _selectedDrink = drink;
          });
        }
      } catch (e) {
      }
      _didLoadArgs = true; 
    }
  }


  Future<void> _addDrink() async {
    setState(() => _isLoading = true);

    final newRecord = DrinkRecord(
      amount: _currentAmountMl,

      drinkName: _selectedDrink?.name ?? 'Water', 
      timestamp: Timestamp.now(), 
    );

    try {

      await context.read<DrinkRecordsProvider>().addDrink(newRecord);

      Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false, 
        );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add drink: $e')),
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
    AnalyticsService.logScreenView('AddDrinkScreen');
    
    final String drinkName = _selectedDrink?.name ?? 'Water';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
          iconSize: 30,
          splashRadius: 30,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      drinkName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/water.png',
                          width: 500, 
                          height: 500,
                          fit: BoxFit.contain,
                          semanticLabel: 'Glass of water',
                        ),
                        
                      ],
                    ),
                    Text(
                      '${_currentAmountMl}ml',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        value: _currentAmountMl.toDouble(),
                        min: 50,  
                        max: 1000, 
                        divisions: 38,
                        label: '${_currentAmountMl.round()} ml',
                        onChanged: (newValue) {
                          setState(() {
                            _currentAmountMl = (newValue / 25).round() * 25;
                            if (_currentAmountMl < 50) _currentAmountMl = 50;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    _buildIconButton(
                      icon: Icons.free_breakfast_outlined,
                      onPressed: () {
                        Navigator.pushNamed(context, '/drinks_list');
                      },
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: PrimaryButton(
                          text: '+DRINK',

                          onPressed: _isLoading ? () {} : () => _addDrink(),

                        ),
                      ),
                    ),

                    _buildIconButton(
                      icon: Icons.alarm_outlined,
                      onPressed: () {
                        // TODO: Обробка натискання на годинник
                        print('Alarm button pressed');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 28),
        onPressed: onPressed,
        iconSize: 32,
        padding: const EdgeInsets.all(16), 
        splashRadius: 28,
      ),
    );
  }
}