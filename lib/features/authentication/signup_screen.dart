import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();
  final _profileRepository = ProfileRepository();

  bool isWorker = false;
  bool _loading = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _skill = TextEditingController();
  final _experience = TextEditingController();
  final _contact = TextEditingController();
  final _availability = TextEditingController();
  final _location = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _skill.dispose();
    _experience.dispose();
    _contact.dispose();
    _availability.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final profile = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text.trim(),
      'isWorker': isWorker,
      'skill': isWorker ? _skill.text.trim() : '',
      'experience': isWorker ? _experience.text.trim() : '',
      'contact': isWorker ? _contact.text.trim() : '',
      'availability': isWorker ? _availability.text.trim() : '',
      'location': isWorker ? _location.text.trim() : '',
    };

    try {
      final email = _email.text.trim();

      final existing = await _profileRepository.findByEmail(email);
      if (existing != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account already exists. Please login.')),
        );
        setState(() => _loading = false);
        return;
      }

      await _profileRepository.saveProfile(profile);

      final cleanProfile = Map<String, dynamic>.from(profile)
        ..removeWhere((key, value) => value == null);

      await _authRepository.saveActiveProfile(
        role: isWorker ? 'worker' : 'user',
        profile: cleanProfile,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: _name.text.trim(),
            email: _email.text.trim(),
            skill: isWorker ? _skill.text.trim() : null,
            experience: isWorker ? _experience.text.trim() : null,
            contact: isWorker ? _contact.text.trim() : null,
            availability: isWorker ? _availability.text.trim() : null,
            location: isWorker ? _location.text.trim() : null,
            isWorker: isWorker,
          ),
        ),
      );
    } catch (e, st) {
      print('❌ Signup error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text('Create an Account'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ToggleButtons(
                      isSelected: [!isWorker, isWorker],
                      onPressed: (i) => setState(() => isWorker = (i == 1)),
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: Colors.deepPurple,
                      color: Colors.deepPurple,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('User'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Worker'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField(_name, Icons.person, 'Name'),
                  _buildField(_email, Icons.email, 'Email'),
                  _buildField(_password, Icons.lock, 'Password', obscure: true),
                  if (isWorker) ...[
                    _buildField(_skill, Icons.star, 'Skill'),
                    _buildField(_experience, Icons.work, 'Experience'),
                    _buildField(_contact, Icons.phone, 'Contact Number'),
                    _buildField(_availability, Icons.access_time,
                        'Availability (e.g. 9AM-5PM)'),
                    _buildField(_location, Icons.location_on, 'Location'),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        : Text(isWorker ? 'Sign up as Worker' : 'Sign up as User'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, IconData icon, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: label == 'Contact Number'
            ? TextInputType.phone
            : (label == 'Email' ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Enter $label';
          final value = v.trim();

          if (label == 'Name' && !RegExp(r'^[a-zA-Z ]{3,}$').hasMatch(value)) {
            return 'Enter a valid name (only letters, min 3 chars)';
          }
          if (label == 'Email' &&
              !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
            return 'Enter a valid email address';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (label == 'Contact Number' && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
            return 'Enter a valid 10-digit contact number';
          }
          if (label == 'Skill' && !RegExp(r'^[a-zA-Z ]{2,30}$').hasMatch(value)) {
            return 'Enter a valid skill name (only letters)';
          }
          if (label == 'Experience' &&
              !RegExp(r'^[a-zA-Z0-9 ]{1,20}$').hasMatch(value)) {
            return 'Enter a valid experience (e.g. 2 years)';
          }
          if (label == 'Availability (e.g. 9AM-5PM)' &&
              !RegExp(r'^[a-zA-Z0-9:\- ]{4,20}$').hasMatch(value)) {
            return 'Enter valid availability (e.g. 9AM-5PM)';
          }
          if (label == 'Location' && !RegExp(r'^[a-zA-Z ]{2,30}$').hasMatch(value)) {
            return 'Enter a valid location name';
          }
          return null;
        },
      ),
    );
  }
}
