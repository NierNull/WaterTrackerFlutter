import 'package:flutter/material.dart';
import '../models/drink_model.dart';
import '../../services/analytics_service.dart';
import '../../widgets/core_elements.dart';

class DrinkDetailScreen extends StatelessWidget {
  final Drink drink;

  const DrinkDetailScreen({super.key, required this.drink});

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logScreenView('DrinkDetailScreen - ${drink.name}');

    return Scaffold(
       backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Text(
          drink.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    drink.icon,
                    color: const Color(0xFF38B6FF),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  drink.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 12, 25, 92),
                  ),
                ),
                const SizedBox(height: 12),
  
                Chip(
                  label: Text(
                    '${drink.waterPercentage.toInt()}% water',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  backgroundColor: const Color(0xFFE0F7FF),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  drink.description,
                  textAlign: TextAlign.justify, 
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24), 
                PrimaryButton(
                text: 'Add this drink',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/water_amount',
                    arguments: drink,
                  );
                },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
