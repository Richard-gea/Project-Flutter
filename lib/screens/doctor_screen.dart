import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consultation_provider.dart';
import 'package:email_validator/email_validator.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedMaladyId;
  String? _selectedMedicamentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize consultation provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consultationProvider =
          Provider.of<ConsultationProvider>(context, listen: false);
      consultationProvider.initialize();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  void _onMaladyChanged(String? maladyId) {
    if (maladyId != null) {
      setState(() {
        _selectedMaladyId = maladyId;
        
        _selectedMedicamentId = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMaladyId == null) {
      _showErrorDialog('Please select a malady (sickness type)');
      return;
    }

    if (_selectedMedicamentId == null) {
      _showErrorDialog('Please select a medicament');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final consultationProvider =
          Provider.of<ConsultationProvider>(context, listen: false);

     
      final patient = await consultationProvider.createPatient(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (patient == null) {
        throw Exception('Failed to create patient');
      }

      // Then create the consultation with the patient ID
      final consultationSuccess = await consultationProvider.createConsultation(
        patientId: patient.id!,
        maladyId: _selectedMaladyId!,
        medicamentId: _selectedMedicamentId!,
      );

      if (!consultationSuccess) {
        throw Exception('Failed to create consultation');
      }

      if (mounted) {
       

        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to save patient information';
        
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('email already exists') || 
            errorString.contains('duplicate') || 
            errorString.contains('e11000')) {
          errorMessage = 'This email is already registered in the system. Please use a different email.';
        } else {
          errorMessage = 'Failed to save patient information: ${e.toString()}';
        }
        
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Success'),
        content: const Text(
            'Patient information and consultation saved successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.error,
          color: Colors.red,
          size: 48,
        ),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_add,
                            size: 48,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Add New Patient',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter patient information below',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                 
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),

    
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter first name';
                              }
                              if (value.trim().length < 3) {
                                return 'First name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter last name';
                              }
                              if (value.trim().length < 3) {
                                return 'Last name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter email address';
                              }
                            
                              if (!EmailValidator.validate(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null; 
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Medical Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Malady (Sickness Type) Dropdown
                          Consumer<ConsultationProvider>(
                            builder: (context, consultationProvider, child) {
                              return DropdownButtonFormField<String>(
                                value: _selectedMaladyId,
                                decoration: const InputDecoration(
                                  labelText: 'Type of Illness',
                                  prefixIcon: Icon(Icons.local_hospital),
                                ),
                                items:
                                    consultationProvider.maladies.map((malady) {
                                  return DropdownMenuItem<String>(
                                    value: malady.id,
                                    child: Text(malady.maladyName),
                                  );
                                }).toList(),
                                onChanged: _onMaladyChanged,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a type of illness';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Medicament Dropdown
                          Consumer<ConsultationProvider>(
                            builder: (context, consultationProvider, child) {
                              return DropdownButtonFormField<String>(
                                value: _selectedMedicamentId,
                                decoration: const InputDecoration(
                                  labelText: 'Prescribed Medication',
                                  prefixIcon: Icon(Icons.medical_services),
                                ),
                                items: consultationProvider
                                    .getMedicamentsForMalady(
                                        _selectedMaladyId ?? '')
                                    .map((medicament) {
                                  return DropdownMenuItem<String>(
                                    value: medicament.id,
                                    child: Text(medicament.medicamentName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedMedicamentId = value;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a medication';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),

                         

                          // Notes
                          
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Adding Patient...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text('Add Patient'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
