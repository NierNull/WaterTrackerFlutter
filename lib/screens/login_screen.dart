
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/core_elements.dart'; 
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/google_auth_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey =  GlobalKey<FormState>();
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  bool _isLoading = false; //// 


void _submit() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithEmailAndPassword(
      context,
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      AnalyticsService.logLogin('By email');
      Navigator.pushReplacementNamed(context, '/main');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logScreenView('LoginScreen');
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to your account to start in H2Meow',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),

                   
                     Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _emailController,
                              hintText: 'Email address',
                              prefixIcon: Icons.email_outlined,
                              keyboardType:TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter email';
                                }
                                final emailRegex =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Invalid email format';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            AppPasswordTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter password';
                                }
                                if (value.trim().length < 6) {
                                  return 'Should be minimum 6 chracters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              text: 'LOG IN',
                              onPressed: _isLoading ? () {} : () => _submit(),
                            ),
                          ]
                        ),
                      ),
                        const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    const OrDivider(),
                    const SizedBox(height: 20),

                    GoogleSignInButton(
                      onPressed: () async {
                        final user = await _googleAuthService.signInWithGoogleAndOfferPassword(context);
                        if (user != null && mounted) {
                          AnalyticsService.logLogin('By google');
                          Navigator.pushNamed(context, '/main');
                        }
                      },
                    ),
                    const SizedBox(height: 40),

                    SignUpLink(
                      onSignUpTapped: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseCrashlytics.instance.crash();
                      },
                      child: const Text("Test Crash"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

@override
 void dispose(){
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}

}