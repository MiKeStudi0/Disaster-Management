import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertBox extends StatefulWidget {
  const AlertBox({super.key});

  @override
  _AlertBoxState createState() => _AlertBoxState();
}

class _AlertBoxState extends State<AlertBox> {
  late Timer _timer;
  int _currentIndex = 0;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications') // Firestore collection name
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _notifications = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['title'] ?? 'No Title',
            'body': data['body'] ?? 'No Body',
          };
        }).toList();

        if (_notifications.isNotEmpty) {
          _setupTimer();
        }
      });
    } catch (e) {
      print('Error loading notifications from Firestore: $e');
    }
  }

  void _setupTimer() {
    if (_notifications.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _notifications.length;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width - 32.0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFBBDEFB), // Brighter background for visibility
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Soft shadow color
              blurRadius: 10,
              offset: const Offset(0, 4), // Slightly shifted downward
            ),
          ],
          border: Border.all(
              color: const Color.fromARGB(255, 244, 63, 63), width: 0.4),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notifications,
              color: Color.fromARGB(255, 244, 63, 63), // Alert icon color
              size: 30,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: _notifications.isNotEmpty
                    ? Column(
                        key: ValueKey<int>(_currentIndex),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              _notifications[_currentIndex]['title'] ??
                                  'No Title',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              _notifications[_currentIndex]['body'] ??
                                  'No Body',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(
                        child: Text(
                          'No Notification Alert',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
