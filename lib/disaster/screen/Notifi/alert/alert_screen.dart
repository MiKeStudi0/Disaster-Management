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
          'title': parts.isNotEmpty ? parts[0] : 'No Title',
          'body': parts.length > 1 ? parts[1] : 'No Body',
          'imageUrl':
              parts.length > 2 ? parts[2] : '', // Get image URL if available
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading bell icon
                  Icon(
                    Icons.notifications,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 12), // Space between icon and content

                  // Notification content in Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _notifications[index]['title'] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_notifications[index]['imageUrl']!.isNotEmpty)
                          Image.network(
                            _notifications[index]['imageUrl']!,
                            height: 150, // Adjust height as needed
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image,
                                  color: Colors.grey); // Fallback icon
                            },
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _notifications[index]['body'] ?? 'No Body',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
