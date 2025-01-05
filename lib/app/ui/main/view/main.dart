import 'package:disaster_management/disaster/screen/Notifi/alert/alert_screen.dart';
import 'package:disaster_management/disaster/screen/Notifi/alert/alertbox.dart';
import 'package:disaster_management/disaster/screen/sos_screen/alert_shake.dart';
import 'package:disaster_management/disaster/screen/sos_screen/alert_sos.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:disaster_management/app/controller/controller.dart';
import 'package:disaster_management/app/data/db.dart';
import 'package:disaster_management/app/ui/widgets/weather/daily/daily_card_list.dart';
import 'package:disaster_management/app/ui/widgets/weather/daily/daily_container.dart';
import 'package:disaster_management/app/ui/widgets/weather/desc/desc_container.dart';
import 'package:disaster_management/app/ui/widgets/weather/hourly.dart';
import 'package:disaster_management/app/ui/widgets/weather/now.dart';
import 'package:disaster_management/app/ui/widgets/shimmer.dart';
import 'package:disaster_management/app/ui/widgets/weather/sunset_sunrise.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final weatherController = Get.put(WeatherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShakeLocationPage(),
            ),
          );
        },
        child: const Icon(Icons.crisis_alert_sharp),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () async {
          await weatherController.deleteAll(false);
          await weatherController.setLocation();
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Obx(() {
            if (weatherController.isLoading.isTrue) {
              return ListView(
                children: const [
                  MyShimmer(
                    hight: 200,
                  ),
                  MyShimmer(
                    hight: 130,
                    edgeInsetsMargin: EdgeInsets.symmetric(vertical: 15),
                  ),
                  MyShimmer(
                    hight: 90,
                    edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                  ),
                  MyShimmer(
                    hight: 400,
                    edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                  ),
                  MyShimmer(
                    hight: 450,
                    edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                  )
                ],
              );
            }

            final mainWeather = weatherController.mainWeather;
            final weatherCard = WeatherCard.fromJson(mainWeather.toJson());
            final hourOfDay = weatherController.hourOfDay.value;
            final dayOfNow = weatherController.dayOfNow.value;
            final sunrise = mainWeather.sunrise![dayOfNow];
            final sunset = mainWeather.sunset![dayOfNow];
            final tempMax = mainWeather.temperature2MMax![dayOfNow];
            final tempMin = mainWeather.temperature2MMin![dayOfNow];

            return ListView(
              children: [
                Now(
                  time: mainWeather.time![hourOfDay],
                  weather: mainWeather.weathercode![hourOfDay],
                  degree: mainWeather.temperature2M![hourOfDay],
                  feels: mainWeather.apparentTemperature![hourOfDay]!,
                  timeDay: sunrise,
                  timeNight: sunset,
                  tempMax: tempMax!,
                  tempMin: tempMin!,
                ),
                GestureDetector(
                  child: AlertBox(),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ));
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: SizedBox(
                      height: 135,
                      child: ScrollablePositionedList.separated(
                        key: const PageStorageKey(0),
                        separatorBuilder: (BuildContext context, int index) {
                          return const VerticalDivider(
                            width: 10,
                            indent: 40,
                            endIndent: 40,
                          );
                        },
                        scrollDirection: Axis.horizontal,
                        itemScrollController:
                            weatherController.itemScrollController,
                        itemCount: mainWeather.time!.length,
                        itemBuilder: (ctx, i) {
                          final i24 = (i / 24).floor();

                          return GestureDetector(
                            onTap: () {
                              weatherController.hourOfDay.value = i;
                              weatherController.dayOfNow.value = i24;
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: i == hourOfDay
                                    ? context
                                        .theme.colorScheme.secondaryContainer
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Hourly(
                                time: mainWeather.time![i],
                                weather: mainWeather.weathercode![i],
                                degree: mainWeather.temperature2M![i],
                                timeDay: mainWeather.sunrise![i24],
                                timeNight: mainWeather.sunset![i24],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SunsetSunrise(
                  timeSunrise: sunrise,
                  timeSunset: sunset,
                ),
                DescContainer( //commented  p1
                  humidity: mainWeather.relativehumidity2M?[hourOfDay],
                  wind: mainWeather.windspeed10M?[hourOfDay],
                  visibility: mainWeather.visibility?[hourOfDay],
                  feels: mainWeather.apparentTemperature?[hourOfDay],
                  evaporation: mainWeather.evapotranspiration?[hourOfDay],
                  precipitation: mainWeather.precipitation?[hourOfDay],
                  direction: mainWeather.winddirection10M?[hourOfDay],
                  pressure: mainWeather.surfacePressure?[hourOfDay],
                  rain: mainWeather.rain?[hourOfDay],
                  cloudcover: mainWeather.cloudcover?[hourOfDay],
                  windgusts: mainWeather.windgusts10M?[hourOfDay],
                  uvIndex: mainWeather.uvIndex?[hourOfDay],
                  dewpoint2M: mainWeather.dewpoint2M?[hourOfDay],
                  precipitationProbability:
                      mainWeather.precipitationProbability?[hourOfDay],
                  shortwaveRadiation:
                      mainWeather.shortwaveRadiation?[hourOfDay],
                  initiallyExpanded: false,
                  title: 'hourlyVariables'.tr,
                ),
                DailyContainer(
                  weatherData: weatherCard,
                  onTap: () => Get.to(
                    () => DailyCardList(
                      weatherData: weatherCard,
                    ),
                    transition: Transition.downToUp,
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
