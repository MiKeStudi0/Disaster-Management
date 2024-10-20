import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class VolunteerReg extends StatefulWidget {
  const VolunteerReg({Key? key}) : super(key: key);

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers Registration'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
        child: SingleChildScrollView(
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
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  controller: _controllerCnumber,
                  hint: 'Enter Your Contact No',
                  icon: Icons.phone,
                  validatorMessage: 'Please enter your Contact No',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  controller: _controllerState,
                  hint: 'Enter State',
                  icon: Icons.location_on_outlined,
                  validatorMessage: 'Please enter state',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  controller: _controllerDistrict,
                  hint: 'Enter District',
                  icon: Icons.location_on_outlined,
                  validatorMessage: 'Please enter district',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  controller: _controllerAddress,
                  hint: 'Enter your Address',
                  icon: Icons.location_on,
                  validatorMessage: 'Please enter your address',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  controller: _controllerInterests,
                  hint: 'Your interests to work in',
                  icon: Icons.handshake_sharp,
                  validatorMessage: 'Please enter your interests',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
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
                      _reference.add(dataToSend);
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Success"),
                            content:
                                const Text("Volunteer Registered Successfully"),
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
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Submit',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25.7),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: colorScheme.primary),
          hintText: hint,
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 16.0,
          ),
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return validatorMessage;
          }
          return null;
        },
      ),
    );
  }
}
