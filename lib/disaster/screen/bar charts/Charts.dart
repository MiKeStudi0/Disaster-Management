import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Charts extends StatefulWidget {
  @override
  _ChartsState createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  final _formKey = GlobalKey<FormState>();
  final _availableQuantityController = TextEditingController();

  String? _selectedName;
  List<String> _names = [];

  // Fixed required quantity for the donation unit
  final int requiredQuantity = 100;

  @override
  void initState() {
    super.initState();
    _fetchNames();
  }

  Future<void> _fetchNames() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('units').get();

      setState(() {
        _names = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching names: ${error.toString()}')),
      );
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      try {
        int availableQuantity = int.parse(_availableQuantityController.text.trim());

        if (_selectedName == null || _selectedName!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a name')),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('units')
            .doc(_selectedName)
            .set({
          'name': _selectedName,
          'totalQuantity': availableQuantity + requiredQuantity, // Total quantity is sum of available and required
          'availableQuantity': availableQuantity,
          'requiredQuantity': requiredQuantity,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation data updated successfully')),
        );

        _clearForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _selectedName = null;
    });
    _availableQuantityController.clear();
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String validatorMessage,
    required ColorScheme colorScheme,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Model - Resource Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Dropdown for selecting donation unit name
                  DropdownButtonFormField<String>(
                    value: _selectedName,
                    decoration: InputDecoration(
                      labelText: 'Select Donation Unit',
                      prefixIcon: Icon(Icons.local_shipping, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    items: _names
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedName = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a donation unit';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  buildTextFormField(
                    controller: _availableQuantityController,
                    hint: 'Available Quantity for Donation',
                    icon: Icons.check_circle,
                    validatorMessage: 'Please enter available quantity for donation',
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: Text('Update Donation Data'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Filter by Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedName = value;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('units').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final allData = snapshot.data!.docs
                      .map((doc) => doc.data())
                      .toList();

                  return ListView.builder(
                    itemCount: allData.length,
                    itemBuilder: (context, index) {
                      final data = allData[index];
                      final total = data['totalQuantity'] as int;
                      final available = data['availableQuantity'] as int;
                      final required = data['requiredQuantity'] as int;

                      final availablePercentage =
                          (available / total * 100).toStringAsFixed(1);
                      final requiredPercentage =
                          (required / total * 100).toStringAsFixed(1);
                      final remainingPercentage =
                          ((total - available - required) / total * 100)
                              .toStringAsFixed(1);

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Donation Unit: ${data['name']}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: available.toDouble(),
                                        color: Colors.green,
                                        title: 'Available\n$availablePercentage%',
                                      ),
                                      PieChartSectionData(
                                        value: required.toDouble(),
                                        color: Colors.orange,
                                        title: 'Required\n$requiredPercentage%',
                                      ),
                                      PieChartSectionData(
                                        value: (total - available - required)
                                            .toDouble(),
                                        color: Colors.blue,
                                        title: 'Remaining\n$remainingPercentage%',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
