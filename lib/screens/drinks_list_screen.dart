import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../widgets/core_elements.dart'; 
import '../../services/analytics_service.dart';
import '../models/drink_model.dart'; 
import '../providers/drink_provider.dart'; 

class DrinkListScreen extends StatefulWidget {
  const DrinkListScreen({super.key});

  @override
  State<DrinkListScreen> createState() => _DrinkListScreenState();
}

class _DrinkListScreenState extends State<DrinkListScreen> {
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('DrinkListScreen');
    
    _searchController.addListener(_onSearchChanged);
 
    WidgetsBinding.instance.addPostFrameCallback((_) {

      Provider.of<DrinkProvider>(context, listen: false).setSearchQuery('');
      Provider.of<DrinkProvider>(context, listen: false).fetchDrinks();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<DrinkProvider>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  void _navigateToDrinkDetail(Drink drink) {
    Navigator.pushNamed(
      context,
      '/drink_detail',
      arguments: drink, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text(
          'Choose your drink',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: AppTextField(
                  controller: _searchController,
                  hintText: 'Search drinks...',
                  prefixIcon: Icons.search,
                  keyboardType: TextInputType.text,
                ),
              ),

              Expanded(
                child: Consumer<DrinkProvider>(
                  builder: (context, provider, child) {
                    
                    if (provider.isLoading) {
                     return const Center(
                        child: SpinningLoader(
                        imagePath: 'assets/images/loader.png',
                        size: 60.0,
                        ),
                        );
                    }
          
                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              text: 'Try Again',
                              onPressed: () => provider.fetchDrinks(), 
                              color: Colors.orange,
                            )
                          ],
                        ),
                      );
                    }
                    
                    final filteredDrinks = provider.filteredDrinks;
                    if (filteredDrinks.isEmpty) {
                      return Center(
                        child: Text(
                          _searchController.text.isEmpty
                            ? 'No drinks available.'
                            : 'No drinks found for "${_searchController.text}".',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        )
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredDrinks.length,
                      itemBuilder: (context, index) {
                        final drink = filteredDrinks[index];
                        return _buildDrinkTile(drink);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkTile(Drink drink) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0F8FF), 
          child: Icon(
            drink.icon,
            color: const Color(0xFF38B6FF), 
            size: 24,
          ),
        ),
        title: Text(
          drink.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          '${drink.waterPercentage.toInt()}% water',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey,
          size: 16
        ),

        onTap: () => _navigateToDrinkDetail(drink), 
      ),
    );
  }
}
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
