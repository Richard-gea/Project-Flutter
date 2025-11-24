import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import '../providers/consultation_provider.dart';

class Consultation {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  String maladyName;
  List<String> medicaments;
  bool isDeleted;

  Consultation({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.maladyName,
    required this.medicaments,
    this.isDeleted = false,
  });
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConsultationProvider>();
      provider.loadMaladies();
      provider.loadMedicaments();
      provider.loadConsultations();
    });
  }


 

  Future<void> _showIllnessDialog({Consultation? existing}) async {
    final provider = context.read<ConsultationProvider>();
    final formKey = GlobalKey<FormState>();

    // For adding new malady
    final maladyNameController = TextEditingController();
    
    
    // For adding new medicament
    final medicamentNameController = TextEditingController();
    
    String? selectedMaladyId;

    // For editing existing
    final illnessController = TextEditingController(text: existing?.maladyName ?? "");
    final List<TextEditingController> medicamentControllers = [];

    if (existing != null && existing.medicaments.isNotEmpty) {
      for (final med in existing.medicaments) {
        medicamentControllers.add(TextEditingController(text: med));
      }
    } else {
      medicamentControllers.add(TextEditingController());
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existing == null ? "Add Illness & Medicaments" : "Edit illness"),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (existing == null) ...[
                          // Add new Malady section
                          const Text(
                            "Add New Malady (Illness Type)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: maladyNameController,
                            decoration: const InputDecoration(
                              labelText: "Malady Name",
                              border: OutlineInputBorder(),
                              hintText: "e.g., Flu, Headache, Diabetes",
                            ),
                          ),
                          
                         
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (maladyNameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill in malady name '),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              
                              final success = await provider.createMalady(
                                maladyName: maladyNameController.text.trim(),
                                
                              );

                              if (success) {
                                maladyNameController.clear();
                                ;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Malady added to database!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                setStateDialog(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to add malady'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Malady to Database'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Display existing maladies with delete buttons
                          if (provider.maladies.isNotEmpty) ...[
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text(
                              "Existing Maladies:",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.maladies.length,
                                itemBuilder: (context, index) {
                                  final malady = provider.maladies[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(malady.maladyName),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      tooltip: 'Delete malady',
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogCtx) => AlertDialog(
                                            title: const Text("Delete Malady"),
                                            content: Text(
                                              "Are you sure you want to delete '${malady.maladyName}'?\n\nThis will also delete all related medicaments."
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(dialogCtx).pop(false),
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => Navigator.of(dialogCtx).pop(true),
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirmed == true && malady.id != null) {
                                          final success = await provider.deleteMalady(malady.id!);
                                          if (success && mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Malady deleted successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            setStateDialog(() {});
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),

                          // Add new Medicament section
                          const Text(
                            "Add New Medicament",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (provider.maladies.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Add a malady first before adding medicaments',
                                style: TextStyle(color: Colors.orange),
                              ),
                            )
                          else ...[
                            DropdownButtonFormField<String>(
                              value: selectedMaladyId ?? provider.maladies.first.id,
                              decoration: const InputDecoration(
                                labelText: 'Related Malady',
                                border: OutlineInputBorder(),
                              ),
                              items: provider.maladies.map((malady) {
                                return DropdownMenuItem(
                                  value: malady.id,
                                  child: Text(malady.maladyName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedMaladyId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: medicamentNameController,
                              decoration: const InputDecoration(
                                labelText: "Medicament Name",
                                border: OutlineInputBorder(),
                                hintText: "e.g., Paracetamol, Ibuprofen",
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (medicamentNameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill in medicament name'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                final success = await provider.createMedicament(
                                  medicamentName: medicamentNameController.text.trim(),
                                  
                                  maladyId: (selectedMaladyId ?? provider.maladies.first.id)!,
                                );

                                if (success) {
                                  medicamentNameController.clear();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Medicament added to database!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  setStateDialog(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to add medicament'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Medicament to Database'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Display existing medicaments with delete buttons
                            if (provider.medicaments.isNotEmpty) ...[
                              const Divider(),
                              const SizedBox(height: 12),
                              const Text(
                                "Existing Medicaments:",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 150),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: provider.medicaments.length,
                                  itemBuilder: (context, index) {
                                    final medicament = provider.medicaments[index];
                                    final maladyName = provider.maladies
                                        .firstWhere(
                                          (m) => m.id == medicament.maladyId,
                                          orElse: () => provider.maladies.first,
                                        )
                                        .maladyName;
                                    return ListTile(
                                      dense: true,
                                      title: Text(medicament.medicamentName),
                                      subtitle: Text(
                                        'For: $maladyName',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        tooltip: 'Delete medicament',
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogCtx) => AlertDialog(
                                              title: const Text("Delete Medicament"),
                                              content: Text(
                                                "Are you sure you want to delete '${medicament.medicamentName}'?"
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );
                                          
                                          if (confirmed == true && medicament.id != null) {
                                            final success = await provider.deleteMedicament(medicament.id!);
                                            if (success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Medicament deleted successfully'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              setStateDialog(() {});
                                            }
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ] else ...[
                          // Edit existing consultation
                          TextFormField(
                            controller: illnessController,
                            decoration: const InputDecoration(
                              labelText: "Illness",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter an illness name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: List.generate(
                              medicamentControllers.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextFormField(
                                  controller: medicamentControllers[index],
                                  decoration: InputDecoration(
                                    labelText: "Medicament ${index + 1}",
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter a medicament name";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                setStateDialog(() {
                                  medicamentControllers.add(TextEditingController());
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add new field"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Close"),
                ),
                if (existing != null)
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final illness = illnessController.text.trim();
                      final meds = medicamentControllers
                          .map((c) => c.text.trim())
                          .where((m) => m.isNotEmpty)
                          .toList();

                      setState(() {
                        existing.maladyName = illness;
                        existing.medicaments = meds;
                      });

                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Update"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Portal"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () => _showIllnessDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add to Database",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.consultations.isEmpty) {
            return const Center(
              child: Text(
                "No consultations found.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Patient Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Malady")),
                    DataColumn(label: Text("Medicament")),
                    DataColumn(label: Text("Date")),
                  ],
                  rows: provider.consultations.map((consultation) {
                    final patientName = consultation.patient != null 
                        ? '${consultation.patient!['firstName'] ?? ''} ${consultation.patient!['lastName'] ?? ''}'.trim()
                        : 'N/A';
                    final patientEmail = consultation.patient?['email'] ?? 'N/A';
                    final maladyName = consultation.malady?['maladyName'] ?? 'N/A';
                    final medicamentName = consultation.medicament?['medicamentName'] ?? 'N/A';
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(patientName)),
                        DataCell(Text(patientEmail.toString())),
                        DataCell(Text(maladyName.toString())),
                        DataCell(Text(medicamentName.toString())),
                        DataCell(Text('${consultation.date.day}/${consultation.date.month}/${consultation.date.year}')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
