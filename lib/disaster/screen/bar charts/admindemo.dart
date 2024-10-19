import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController foodNeededController = TextEditingController();
  final TextEditingController foodAvailableController = TextEditingController();
  final TextEditingController waterNeededController = TextEditingController();
  final TextEditingController waterAvailableController = TextEditingController();
  final TextEditingController clothesNeededController = TextEditingController();
  final TextEditingController clothesAvailableController = TextEditingController();

  final CollectionReference resources = FirebaseFirestore.instance.collection('resources');

  Future<void> pushDataToFirebase() async {
    await resources.doc('Food').set({
      'needed': double.parse(foodNeededController.text),
      'available': double.parse(foodAvailableController.text),
    });

    await resources.doc('Water').set({
      'needed': double.parse(waterNeededController.text),
      'available': double.parse(waterAvailableController.text),
    });

    await resources.doc('Clothes').set({
      'needed': double.parse(clothesNeededController.text),
      'available': double.parse(clothesAvailableController.text),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data successfully uploaded')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Food Input
            TextField(
              controller: foodNeededController,
              decoration: InputDecoration(labelText: "Food Needed"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: foodAvailableController,
              decoration: InputDecoration(labelText: "Food Available"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Water Input
            TextField(
              controller: waterNeededController,
              decoration: InputDecoration(labelText: "Water Needed"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: waterAvailableController,
              decoration: InputDecoration(labelText: "Water Available"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Clothes Input
            TextField(
              controller: clothesNeededController,
              decoration: InputDecoration(labelText: "Clothes Needed"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: clothesAvailableController,
              decoration: InputDecoration(labelText: "Clothes Available"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: pushDataToFirebase,
              child: Text("Submit Data"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    foodNeededController.dispose();
    foodAvailableController.dispose();
    waterNeededController.dispose();
    waterAvailableController.dispose();
    clothesNeededController.dispose();
    clothesAvailableController.dispose();
    super.dispose();
  }
}
