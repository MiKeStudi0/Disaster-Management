import 'dart:core';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerList extends StatelessWidget {
  VolunteerList({Key? key}) : super(key: key) {
    _stream = _reference.snapshots();
  }

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('volunteer');

  late Stream<QuerySnapshot> _stream;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Volunteers List',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Some error occurred: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;

              List<Map> items = documents
                  .map((e) => {
                        'id': e.id,
                        'name': e['name'],
                        'number': e['number'],
                        'district': e['district'],
                        'address': e['address'],
                      })
                  .toList();

              // Sort the items by 'district'
              final sortedItems = items
                ..sort((a, b) => a['district'].compareTo(b['district']));

              return ListView.builder(
                itemCount: sortedItems.length,
                itemBuilder: (context, index) {
                  return VolunteerCard(sortedItems[index]);
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class VolunteerCard extends StatelessWidget {
  final Map volunteerData;

  VolunteerCard(this.volunteerData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.person, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    volunteerData['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone: ${volunteerData['number']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        volunteerData['district'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.track_changes_outlined,
                          color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        volunteerData['address'],
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
