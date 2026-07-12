import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workers_campe/screens/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  String? _selectTrainingStatus;
  int? age;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _dateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final sp = await SharedPreferences.getInstance();

    setState(() {
      _nameController.text = sp.getString('name') ?? '';
      _surnameController.text = sp.getString('surname') ?? '';
      _dateController.text = sp.getString('dob') ?? '';
      _selectedGender = sp.getString('gender');
      _weightController.text = sp.getString('weight') ?? '';
      _heightController.text = sp.getString('height') ?? '';
      _selectTrainingStatus = sp.getString('trainingstat');
      age = sp.getInt('age') ?? -1;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        // computing the current age of the subject:
        age = DateTime.now().year - picked.year;
        if (DateTime.now().month < picked.month && DateTime.now().day < picked.day) {
          age = age! - 1;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final sp = await SharedPreferences.getInstance();

      await sp.setString('name', _nameController.text.trim());
      await sp.setString('surname', _surnameController.text.trim());
      await sp.setString('gender', _selectedGender!);
      await sp.setString('dob', _dateController.text);
      await sp.setBool('onboarding_completed', true);
      await sp.setString('weight', _weightController.text);
      await sp.setString('height', _heightController.text);
      await sp.setString('trainingstat', _selectTrainingStatus!);
      await sp.setInt('age', age!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary) : null,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logoproject.png',
                height: 90,
              ),
              
              const SizedBox(height: 24),

              Text(
                'Let’s know you better',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'We need a few details to personalize your riding experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            label: 'Name',
                            hint: 'Enter your name',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _surnameController,
                          decoration: _inputDecoration(
                            label: 'Surname',
                            hint: 'Enter your surname',
                            icon: Icons.badge_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your surname';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: _inputDecoration(
                            label: 'Sex',
                            hint: 'Choose your sex',
                            icon: Icons.wc_outlined,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please choose an option';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          decoration: _inputDecoration(
                            label: 'Weight',
                            hint: 'Enter your weight (kg)',
                            icon: Icons.scale_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your weight';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          decoration: _inputDecoration(
                            label: 'Height',
                            hint: 'Enter your height (cm)',
                            icon: Icons.straighten_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your height';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid height';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: 'Date of birth',
                            hint: 'Select your date of birth',
                            icon: Icons.calendar_today_outlined,
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please pick a date';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectTrainingStatus,
                          decoration: _inputDecoration(
                            label: 'Training Status',
                            hint: 'Choose your level of fitness',
                            icon: Icons.directions_run_outlined,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Beginner',
                              child: Text('Beginner'),
                            ),
                            DropdownMenuItem(
                              value: 'Intermediate',
                              child: Text('Intermediate'),
                            ),
                            DropdownMenuItem(
                              value: 'Advanced',
                              child: Text('Advanced'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectTrainingStatus = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please choose an option';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}