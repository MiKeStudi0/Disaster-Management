import 'package:disaster_management/app/ui/settings/widgets/setting_card.dart';
import 'package:disaster_management/disaster/screen/google_map/danger_zoes.dart';
import 'package:disaster_management/disaster/screen/google_map/google_map.dart';
import 'package:disaster_management/disaster/screen/google_map/rescuemap.dart';
import 'package:disaster_management/disaster/screen/google_map/updatelocation.dart';
import 'package:disaster_management/disaster/screen/volunteer/volunteer_list.dart';
import 'package:disaster_management/disaster/screen/volunteer/volunteer_reg.dart';
import 'package:disaster_management/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class NavMapScreen extends StatefulWidget {
  const NavMapScreen({super.key});

  @override
  State<NavMapScreen> createState() => _NavMapScreenState();
}

class _NavMapScreenState extends State<NavMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Navigation Routes'.tr),
              const Divider(
                color: divider,
                thickness: 1,
                endIndent: 10,
              ),
              _buildRescueTeamList(),
              const Divider(
                color: divider,
                thickness: 1,
                endIndent: 10,
              ),
              _buildSectionTitle('Volunteer Services'.tr),
              SettingCard(
                icon: const Icon(IconsaxPlusLinear.archive_book),
                text: 'Volunteer Services'.tr,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom),
                        child: StatefulBuilder(
                          builder: (BuildContext context, setState) {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Text(
                                      'Volunteer Services'.tr,
                                      style: context.textTheme.titleLarge
                                          ?.copyWith(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  SettingCard(
                                    elevation: 4,
                                    icon: const Icon(
                                        LineAwesomeIcons.person_booth_solid),
                                    text: 'Volunteer Registration'.tr,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const VolunteerReg()));
                                    },
                                  ),
                                  SettingCard(
                                    elevation: 4,
                                    icon: const Icon(
                                        LineAwesomeIcons.people_carry_solid),
                                    text: 'Volunteer List'.tr,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VolunteerList()));
                                    },
                                  ),
                                  const Gap(10),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.people_carry_solid),
                text: 'Share Tracking'.tr,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationTrackingPage()));
                },
              ),
              SettingCard(
                elevation: 4,
                icon: const Icon(Icons.dangerous),
                text: 'Danger Zones'.tr,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DangerZoneMap()));
                },
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (context) => ShakeLocationPage(),
      //     //   ),
      //     // );
      //   },
      //   child: const Icon(Icons.crisis_alert_sharp),
      //   backgroundColor: Colors.red,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRescueTeamList() {
    return SizedBox(
      height: 420,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          _builSafeLocationCard('Safe Location'.tr, 'Kozhikode', 'Koyilandy'),
          _buildRescueTeamCard('Rescue Camp'.tr, 'Kozhikode', 'Ulliyeri'),
          const SizedBox(height: 10),
          _buildSectionTitle('Emergency Services'.tr),
          const Divider(
            color: divider,
            thickness: 1,
            endIndent: 10,
          ),
          _buildPoliceStationCard(), // Add police station block
          _buildHospitalCard(), // Add hospital block
          _fireforcecard(), // Add fire force block
        ],
      ),
    );
  }

  Widget _buildRescueTeamCard(String teamName, String location, String area) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'school'),
          ),
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamInfo(teamName, location, area),
              const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _builSafeLocationCard(String teamName, String location, String area) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RescueMap(),
          ),
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamInfo(teamName, location, area),
              const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, String location, String area) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on,
                color: Colors.blue), // Changed color to blue
            const SizedBox(width: 4),
            Text(location,
                style: const TextStyle(fontSize: 14.0, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.track_changes_outlined, color: Colors.grey),
            const SizedBox(width: 4),
            Text(area,
                style: const TextStyle(fontSize: 14.0, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildPoliceStationCard() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.call_missed_outgoing),
      text: 'Police Station'.tr,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'police'),
          ),
        );
      },
    );
  }

  Widget _buildHospitalCard() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.plus_square),
      text: 'Hospital'.tr,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'hospital'),
          ),
        );
      },
    );
  }

  Widget _fireforcecard() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.fire_solid),
      text: 'Fire Force',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'fire_station'),
          ),
        );
      },
    );
  }
}
