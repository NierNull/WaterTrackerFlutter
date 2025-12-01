
import 'package:flutter/material.dart';
import 'dart:async';

import '../repositories/drink_repository.dart'; 
import '../models/drink_model.dart'; 
import '../repositories/firebase_drink_repository.dart';


class DrinkProvider extends ChangeNotifier {

  final DrinkRepository _drinkRepo = FirebaseDrinkRepository();

  List<Drink> _allDrinks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';


  List<Drink> get allDrinks => _allDrinks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Drink> get filteredDrinks {
    if (_searchQuery.isEmpty) {
      return _allDrinks;
    } else {
      return _allDrinks
          .where((drink) =>
              drink.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }


  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }


  Future<void> fetchDrinks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      _allDrinks = await _drinkRepo.getDrinkDefinitions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {

      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}