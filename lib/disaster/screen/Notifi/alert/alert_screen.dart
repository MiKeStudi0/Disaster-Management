import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notifications = prefs.getStringList('notifications') ?? [];

    setState(() {
      _notifications = notifications.map((notification) {
        List<String> parts = notification.split('::');
        return {
          'title': parts.length > 0 ? parts[0] : 'No Title',
          'body': parts.length > 1 ? parts[1] : 'No Body',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(_notifications[index]['title'] ?? 'No Title'),
              subtitle: Text(_notifications[index]['body'] ?? 'No Body'),
            ),
          );
        },
      ),
    );
  }
}
