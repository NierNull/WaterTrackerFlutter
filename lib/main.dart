import 'package:flutter/material.dart';
import 'package:water_tracker/screens/signup_screen.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart'; 
import 'screens/main_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/water_amount_screen.dart';
import 'screens/drinks_list_screen.dart';
import 'screens/drink_detail_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/analytics_screen.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';


import 'package:firebase_auth/firebase_auth.dart'; 

import 'providers/drink_provider.dart'; 
import 'providers/drink_records_provider.dart';
import 'providers/user_profile_provider.dart';


import 'models/drink_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
await FirebaseAppCheck.instance.activate(

    androidProvider: AndroidProvider.playIntegrity,

  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runZonedGuarded<Future<void>>(() async {
    runApp(

    MultiProvider(
      providers: [ 
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        
        ChangeNotifierProvider(create: (_) => DrinkProvider()),

        ChangeNotifierProxyProvider<User?, UserProfileProvider>(
          create: (_) => UserProfileProvider(null), 
          update: (_, user, previousProvider) => 
              UserProfileProvider(user?.uid, previousProvider), 
        ),

        ChangeNotifierProxyProvider<User?, DrinkRecordsProvider>(
          create: (_) => DrinkRecordsProvider(null),
          update: (_, user, previousProvider) => 
              DrinkRecordsProvider(user?.uid, previousProvider),
        ),
      ], 
      child: const MyApp(),
    ),
  );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H2Meow water tracker',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', 
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/preview': (context) => const PreviewScreen(),
        '/login': (context) => const LoginScreen(),
        '/user_info':(context) => const UserInfoScreen(),
        '/main': (context) => const MainScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/analytics': (context) => const AnalysisScreen(),
        '/signup': (context)=> const SignUpScreen(),
        '/water_amount': (context)=> const AddDrinkScreen(),
        '/drinks_list': (context)=> const DrinkListScreen(),
        '/drink_detail': (context) {
          final drink = ModalRoute.of(context)!.settings.arguments as Drink;
          return DrinkDetailScreen(drink: drink);
        }
      },
    );
  }
}