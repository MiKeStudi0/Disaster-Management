import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disaster_management/firebase_options.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disaster_management/app/controller/controller.dart';
import 'package:disaster_management/app/data/db.dart';
import 'package:disaster_management/app/ui/geolocation.dart';
import 'package:disaster_management/app/ui/home.dart';
import 'package:disaster_management/app/ui/onboarding.dart';
import 'package:disaster_management/theme/theme.dart';
import 'package:disaster_management/theme/theme_controller.dart';
import 'package:disaster_management/translation/translation.dart';
import 'package:disaster_management/app/utils/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore1;
// If there's another Firestore-like package, import it with an alias.

late Isar isar;
late Settings settings;
late LocationCache locationCache;
final ValueNotifier<Future<bool>> isOnline =
    ValueNotifier(InternetConnection().hasInternetAccess);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool amoledTheme = false;
bool materialColor = false;
bool roundDegree = false;
bool largeElement = false;
Locale locale = const Locale('en', 'US');
int timeRange = 1;
String timeStart = '09:00';
String timeEnd = '21:00';
String widgetBackgroundColor = '';
String widgetTextColor = '';

final List appLanguages = [
  {'name': 'বাংলা', 'locale': const Locale('bn', 'IN')},
  {'name': 'Čeština', 'locale': const Locale('cs', 'CZ')},
  {'name': 'Dansk', 'locale': const Locale('da', 'DK')},
  {'name': 'Deutsch', 'locale': const Locale('de', 'DE')},
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Español', 'locale': const Locale('es', 'ES')},
  {'name': 'Français', 'locale': const Locale('fr', 'FR')},
  // {'name': 'Gaeilge', 'locale': const Locale('ga', 'IE')},
  {'name': 'हिन्दी', 'locale': const Locale('hi', 'IN')},
  {'name': 'Magyar', 'locale': const Locale('hu', 'HU')},
  {'name': 'Italiano', 'locale': const Locale('it', 'IT')},
  {'name': '한국어', 'locale': const Locale('ko', 'KR')},
  {'name': 'فارسی', 'locale': const Locale('fa', 'IR')},
  {'name': 'ქართული', 'locale': const Locale('ka', 'GE')},
  {'name': 'Nederlands', 'locale': const Locale('nl', 'NL')},
  {'name': 'Polski', 'locale': const Locale('pl', 'PL')},
  {'name': 'Português (Brasil)', 'locale': const Locale('pt', 'BR')},
  {'name': 'Română', 'locale': const Locale('ro', 'RO')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
  {'name': 'Slovenčina', 'locale': const Locale('sk', 'SK')},
  {'name': 'Türkçe', 'locale': const Locale('tr', 'TR')},
  {'name': 'اردو', 'locale': const Locale('ur', 'PK')},
  {'name': '中文(简体)', 'locale': const Locale('zh', 'CN')},
  {'name': '中文(繁體)', 'locale': const Locale('zh', 'TW')},
  {'name': 'മലയാളം', 'locale': const Locale('ml', 'IN')}, // Added Malayalam
];

const String appGroupId = 'DARK NIGHT';
const String androidWidgetName = 'OreoWidget';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return WeatherController().updateWidget();
  });
}

void main() async {
  //await dotenv.load(fileName: ".env");
  final String timeZoneName;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.instance.subscribeToTopic('all');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Connectivity()
      .onConnectivityChanged
      .listen((List<ConnectivityResult> result) {
    result.contains(ConnectivityResult.none)
        ? isOnline.value = Future(() => false)
        : isOnline.value = InternetConnection().hasInternetAccess;
  });
  DeviceFeature().init();
  if (Platform.isAndroid) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
    await setOptimalDisplayMode();
  }
  if (Platform.isAndroid || Platform.isIOS) {
    timeZoneName = await FlutterTimezone.getLocalTimezone();
  } else {
    timeZoneName = '${DateTimeZone.local}';
  }
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  await isarInit();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'DisasterRelief');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> _saveNotification(RemoteMessage message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? notifications = prefs.getStringList('notifications') ?? [];

  String notification =
      "${message.notification?.title ?? 'No Title'}::${message.notification?.body ?? 'No Body'}::${message.notification?.android?.imageUrl ?? ''}";

  // Add image URL to the notification if available

  // Store both notification and image URL
  notifications.add(notification);

  await prefs.setStringList('notifications', notifications);
}

void _showNotification(RemoteMessage message) {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'Disaster Relief',
    'Alerts',
    importance: Importance.max,
    priority: Priority.high,
    // If an image URL is available, set the style to BigPictureStyle
    styleInformation: message.notification?.android?.imageUrl != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(message.notification!.android!.imageUrl!),
            contentTitle: message.notification?.title,
            summaryText: message.notification?.body,
          )
        : null,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;
  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));
  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> isarInit() async {
  isar = await Isar.open([
    SettingsSchema,
    MainWeatherCacheSchema,
    LocationCacheSchema,
    WeatherCardSchema,
  ], directory: (await getApplicationSupportDirectory()).path);
  settings = isar.settings.where().findFirstSync() ?? Settings();
  locationCache =
      isar.locationCaches.where().findFirstSync() ?? LocationCache();

  if (settings.language == null) {
    settings.language = '${Get.deviceLocale}';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  if (settings.theme == null) {
    settings.theme = 'system';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newRoundDegree,
    bool? newLargeElement,
    Locale? newLocale,
    int? newTimeRange,
    String? newTimeStart,
    String? newTimeEnd,
    String? newWidgetBackgroundColor,
    String? newWidgetTextColor,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;

    if (newAmoledTheme != null) {
      state.changeAmoledTheme(newAmoledTheme);
    }
    if (newMaterialColor != null) {
      state.changeMarerialTheme(newMaterialColor);
    }
    if (newRoundDegree != null) {
      state.changeRoundDegree(newRoundDegree);
    }
    if (newLargeElement != null) {
      state.changeLargeElement(newLargeElement);
    }
    if (newLocale != null) {
      state.changeLocale(newLocale);
    }
    if (newTimeRange != null) {
      state.changeTimeRange(newTimeRange);
    }
    if (newTimeStart != null) {
      state.changeTimeStart(newTimeStart);
    }
    if (newTimeEnd != null) {
      state.changeTimeEnd(newTimeEnd);
    }
    if (newWidgetBackgroundColor != null) {
      state.changeWidgetBackgroundColor(newWidgetBackgroundColor);
    }
    if (newWidgetTextColor != null) {
      state.changeWidgetTextColor(newWidgetTextColor);
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());

  void changeAmoledTheme(bool newAmoledTheme) {
    setState(() {
      amoledTheme = newAmoledTheme;
    });
  }

  void saveTokenToDatabase(String userId, [String? newToken]) async {
    String? token = newToken ?? await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await firestore1.FirebaseFirestore.instance
          .collection('userTokens')
          .doc(userId)
          .set({
        'token': token,
      });
    }
  }

  void changeMarerialTheme(bool newMaterialColor) {
    setState(() {
      materialColor = newMaterialColor;
    });
  }

  void changeRoundDegree(bool newRoundDegree) {
    setState(() {
      roundDegree = newRoundDegree;
    });
  }

  void changeLargeElement(bool newLargeElement) {
    setState(() {
      largeElement = newLargeElement;
    });
  }

  void changeTimeRange(int newTimeRange) {
    setState(() {
      timeRange = newTimeRange;
    });
  }

  void changeTimeStart(String newTimeStart) {
    setState(() {
      timeStart = newTimeStart;
    });
  }

  void changeTimeEnd(String newTimeEnd) {
    setState(() {
      timeEnd = newTimeEnd;
    });
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  void changeWidgetBackgroundColor(String newWidgetBackgroundColor) {
    setState(() {
      widgetBackgroundColor = newWidgetBackgroundColor;
    });
  }

  void changeWidgetTextColor(String newWidgetTextColor) {
    setState(() {
      widgetTextColor = newWidgetTextColor;
    });
  }

  @override
  void initState() {
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    roundDegree = settings.roundDegree;
    largeElement = settings.largeElement;
    locale = Locale(
        settings.language!.substring(0, 2), settings.language!.substring(3));
    timeRange = settings.timeRange ?? 1;
    timeStart = settings.timeStart ?? '09:00';
    timeEnd = settings.timeEnd ?? '21:00';
    widgetBackgroundColor = settings.widgetBackgroundColor ?? '';
    widgetTextColor = settings.widgetTextColor ?? '';
    if (Platform.isAndroid) {
      HomeWidget.setAppGroupId(appGroupId);
    }
    super.initState();
    _saveUserToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveUserToken(newToken);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _saveNotification(message); // Save the notification
      _showNotification(message); // Display the notification
    });
  }

  void _saveUserToken([String? newToken]) async {
    // Get the currently signed-in user.
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in.
    if (user != null) {
      String userId = user.uid; // Get the user ID.
      String? token = newToken ?? await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await firestore1.FirebaseFirestore.instance
            .collection('userTokens')
            .doc(userId)
            .set({
          'token': token,
        });
        print('Token saved for user: $userId');
      }
    } else {
      print('User is not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final lightMaterialTheme = lightTheme(
              lightColorScheme?.surface, lightColorScheme, edgeToEdgeAvailable);
          final darkMaterialTheme = darkTheme(
              darkColorScheme?.surface, darkColorScheme, edgeToEdgeAvailable);
          final darkMaterialThemeOled =
              darkTheme(oledColor, darkColorScheme, edgeToEdgeAvailable);

          return GetMaterialApp(
            themeMode: themeController.theme,
            theme: materialColor
                ? lightColorScheme != null
                    ? lightMaterialTheme
                    : lightTheme(
                        lightColor, colorSchemeLight, edgeToEdgeAvailable)
                : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable),
            darkTheme: amoledTheme
                ? materialColor
                    ? darkColorScheme != null
                        ? darkMaterialThemeOled
                        : darkTheme(
                            oledColor, colorSchemeDark, edgeToEdgeAvailable)
                    : darkTheme(oledColor, colorSchemeDark, edgeToEdgeAvailable)
                : materialColor
                    ? darkColorScheme != null
                        ? darkMaterialTheme
                        : darkTheme(
                            darkColor, colorSchemeDark, edgeToEdgeAvailable)
                    : darkTheme(
                        darkColor, colorSchemeDark, edgeToEdgeAvailable),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            translations: Translation(),
            locale: locale,
            fallbackLocale: const Locale('en', 'US'),
            supportedLocales:
                appLanguages.map((e) => e['locale'] as Locale).toList(),
            debugShowCheckedModeBanner: false,
            home: settings.onboard
                ? (locationCache.city == null) ||
                        (locationCache.district == null) ||
                        (locationCache.lat == null) ||
                        (locationCache.lon == null)
                    ? const SelectGeolocation(isStart: true)
                    : const HomePage()
                : const OnBording(),
            title: 'Rain',
          );
        },
      ),
    );
  }
}
