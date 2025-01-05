import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertBox extends StatefulWidget {
  const AlertBox({super.key});

  @override
  _AlertBoxState createState() => _AlertBoxState();
}

class _AlertBoxState extends State<AlertBox> {
  late SharedPreferences _prefs;
  late Timer _timer;
  int _currentIndex = 0;
  List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadNotifications();
    _setupTimer();
  }

  Future<void> _loadNotifications() async {
    List<String> notifications = _prefs.getStringList('notifications') ?? [];

    setState(() {
      _notifications = notifications.map((notification) {
        List<String> parts = notification.split('::');
        return {
          'title': parts.isNotEmpty ? parts[0] : 'No Title',
          'body': parts.length > 1 ? parts[1] : 'No Body',
        };
      }).toList();
    });
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
            // const SizedBox(height: 30),
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
                              _notifications[_currentIndex]['body'] ?? 'No Body',
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
                      child: Text('No Notification Alert',
                        style:  TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),), // Empty if no notifications
                    ), // Empty if no notifications
              ),
            ),
          ],
        ),
      ),
    );
  }
}
