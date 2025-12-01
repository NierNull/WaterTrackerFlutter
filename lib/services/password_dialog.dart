import 'package:flutter/material.dart';
import '../../widgets/core_elements.dart';

Future<String?> showPasswordSetupDialog(BuildContext context, String? email) async {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Set a password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (email != null) Text('Email: $email'),
              const SizedBox(height: 12),
              AppPasswordTextField(
                controller: _passwordController,
                hintText: 'Password',
              ),
              const SizedBox(height: 12),
              AppPasswordTextField(
                controller: _confirmController,
                hintText: 'Confirm password',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text != _confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              if (_passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              Navigator.pop(context, _passwordController.text);
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}
