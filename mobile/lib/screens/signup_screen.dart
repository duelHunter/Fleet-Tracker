import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  void signUp() {
    if (_formKey.currentState!.validate()) {
      // Handle sign-up logic
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _licenseController,
                decoration:
                    const InputDecoration(labelText: 'Driving License Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your license number' : null,
              ),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(labelText: 'Vehicle Details'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter vehicle details' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
