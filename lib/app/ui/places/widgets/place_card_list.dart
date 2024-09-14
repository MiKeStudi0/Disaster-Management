import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:rain/app/controller/controller.dart';
import 'package:rain/app/ui/places/view/place_info.dart';
import 'package:rain/app/ui/places/widgets/place_card.dart';

class PlaceCardList extends StatefulWidget {
  const PlaceCardList({
    super.key,
    required this.searchCity,
  });
  final String searchCity;

  @override
  State<PlaceCardList> createState() => _PlaceCardListState();
}

class _PlaceCardListState extends State<PlaceCardList> {
  final weatherController = Get.put(WeatherController());

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final titleMedium = textTheme.titleMedium;

    var weatherCards = weatherController.weatherCards
        .where((weatherCard) => (widget.searchCity.isEmpty ||
            weatherCard.city!.toLowerCase().contains(widget.searchCity)))
        .toList()
        .obs;

    return ReorderableListView(
      onReorder: (oldIndex, newIndex) =>
          weatherController.reorder(oldIndex, newIndex),
      children: [
        ...weatherCards.map(
          (weatherCardList) => Dismissible(
            key: ValueKey(weatherCardList),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(
                  IconsaxPlusLinear.trash_square,
                  color: Colors.red,
                ),
              ),
            ),
            confirmDismiss: (DismissDirection direction) async {
              return await showAdaptiveDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog.adaptive(
                    title: Text(
                      'deletedCardWeather'.tr,
                      style: textTheme.titleLarge,
                    ),
                    content: Text(
                      'deletedCardWeatherQuery'.tr,
                      style: titleMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'cancel'.tr,
                          style: titleMedium?.copyWith(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text(
                          'delete'.tr,
                          style: titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (DismissDirection direction) async {
              await weatherController.deleteCardWeather(weatherCardList);
            },
            child: GestureDetector(
              onTap: () => Get.to(
                () => PlaceInfo(
                  weatherCard: weatherCardList,
                ),
                transition: Transition.downToUp,
              ),
              child: PlaceCard(
                time: weatherCardList.time!,
                timeDaily: weatherCardList.timeDaily!,
                timeDay: weatherCardList.sunrise!,
                timeNight: weatherCardList.sunset!,
                weather: weatherCardList.weathercode!,
                degree: weatherCardList.temperature2M!,
                district: weatherCardList.district!,
                city: weatherCardList.city!,
                timezone: weatherCardList.timezone!,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
