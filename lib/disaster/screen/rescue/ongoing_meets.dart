  import 'dart:ui';

  import 'package:disaster_management/disaster/screen/google_map/google_map.dart';
import 'package:disaster_management/disaster/screen/google_map/track.dart';
import 'package:disaster_management/disaster/screen/rescue/vedioconf.dart';
import 'package:disaster_management/disaster/screen/sos_screen/alert_sos.dart';
import 'package:flutter/material.dart';

  class OngoingScreen extends StatefulWidget {
    const OngoingScreen({super.key});

    @override
    State<OngoingScreen> createState() => _OngoingScreenState();
  }

  class _OngoingScreenState extends State<OngoingScreen> {
    int index = 0;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 70), // Space for Divider and List
                _buildRescueTeamList(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShakeLocationPage(),
                      ),
                    );
                  },
                  child: const Text('Join Rescue Team'),
                ),
                  ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(),
                      ),
                    );
                  },
                  child: const Text('Navigation Map'),
                ),
                 ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationTrackingScreen(),
                      ),
                    );
                  },
                  child: const Text('track Map'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildHeader() {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Rescue Teams',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            color: Colors.white,
            thickness: 1,
            endIndent: 30,
          ),
        ],
      );
    }

    Widget _buildRescueTeamList() {
      return SizedBox(
        height: 300, // Adjust height as needed
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            _buildRescueTeamCard('Rescue Team S1', 'Kozhikode', 'Koyilandy'),
            const SizedBox(height: 8),
            _buildRescueTeamCard('Rescue Team S2', 'Kozhikode', 'Ulliyeri'),
          ],
        ),
      );
    }

    Widget _buildRescueTeamCard(String teamName, String location, String area) {
      return GestureDetector(
        onTap: () {
          _showCodeInputDialog(context, index);
          setState(() {
            index += 1;
          });
        },
        child: InkWell(
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: .0, vertical: .0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamInfo(teamName, location, area),
                  const SizedBox(width: 12.0),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildTeamInfo(String teamName, String location, String area) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.call,
                color: Color.fromARGB(255, 75, 77, 76),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                child: Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 195, 17, 4),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color.fromARGB(255, 75, 77, 76),
              ),
              const SizedBox(width: 10.0),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5.0),
              const Icon(
                Icons.track_changes_outlined,
                color: Color.fromARGB(255, 75, 77, 76),
              ),
              Text(
                area,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }

    Future<void> _showCodeInputDialog(BuildContext context, int index) async {
      String enteredCode = '';
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Code to verify'),
            content: TextField(
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Enter code'),
              onChanged: (value) {
                enteredCode = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _codeConfirm(enteredCode, context, index);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }

    void _codeConfirm(String enteredCode, BuildContext context, int index) {
      if (enteredCode == '1234') {
        // Navigate to VolunteerList page
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoConferencePage(conferenceID: 1234.toString() + index.toString()),
  ),
);

      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect code')),
        );
      }
    }
  }
