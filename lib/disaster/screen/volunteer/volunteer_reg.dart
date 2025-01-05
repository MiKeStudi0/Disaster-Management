import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class VolunteerReg extends StatefulWidget {
  const VolunteerReg({super.key});

  @override
  State<VolunteerReg> createState() => _VolunteerRegState();
}

class _VolunteerRegState extends State<VolunteerReg> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerCnumber = TextEditingController();
  final TextEditingController _controllerState = TextEditingController();
  final TextEditingController _controllerDistrict = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerInterests = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('volunteer');

  void clearText() {
    _controllerName.clear();
    _controllerCnumber.clear();
    _controllerState.clear();
    _controllerDistrict.clear();
    _controllerAddress.clear();
    _controllerInterests.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
     
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Lottie.asset('assets/animation/run.json', height: 200),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: key,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _controllerName,
                          hint: 'Enter Your Name',
                          icon: Icons.person,
                          validatorMessage: 'Please enter your name',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _controllerCnumber,
                          hint: 'Enter Your Contact No',
                          icon: Icons.phone,
                          validatorMessage: 'Please enter your contact number',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _controllerState,
                          hint: 'Enter State',
                          icon: Icons.location_on_outlined,
                          validatorMessage: 'Please enter your state',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _controllerDistrict,
                          hint: 'Enter District',
                          icon: Icons.location_on_outlined,
                          validatorMessage: 'Please enter your district',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _controllerAddress,
                          hint: 'Enter Your Address',
                          icon: Icons.location_on,
                          validatorMessage: 'Please enter your address',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _controllerInterests,
                          hint: 'Your Interests to Work In',
                          icon: Icons.handshake_sharp,
                          validatorMessage: 'Please enter your interests',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (key.currentState!.validate()) {
                                String vName = _controllerName.text;
                                String vNumber = _controllerCnumber.text;
                                String vState = _controllerState.text;
                                String vDistrict = _controllerDistrict.text;
                                String vAddress = _controllerAddress.text;
                                String vInterests = _controllerInterests.text;
              
                                Map<String, String> dataToSend = {
                                  'name': vName,
                                  'number': vNumber,
                                  'state': vState,
                                  'district': vDistrict,
                                  'address': vAddress,
                                  'interests': vInterests,
                                };
                                await _reference.add(dataToSend);
                                clearText();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Success"),
                                      content: const Text(
                                          "Volunteer Registered Successfully"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
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
}
