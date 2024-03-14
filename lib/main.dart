import 'dart:async';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeaccess_qrcode/hive/employee_hive.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'hive/present_hive.dart';
import 'presentation/loading.dart';
import 'value_notifier/network_notifier.dart';

const String appName = "PNGTime";

final bool isIOS = Platform.isIOS;
final bool isAndroid = Platform.isAndroid;
bool syncInProgress = false;

late String version;
late String macAddress;
late String deviceId;
late String deviceBrand;
late String deviceInfoModel;
late String deviceInfoDeviceName;
late String deviceInfoOSName;
late String deviceInfoOSVersion;
late String deviceInfoPlatform;
late String androidId;

late String deviceCode;
String geoLocation = "";

late Box userSettingBox;
late Box presentBox;
late Box employeeBox;
NetworkNotifier networkNotifier = NetworkNotifier();
late BuildContext appContext;

Future<void> main() async {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  Hive
    ..init(appDocDirectory.path)
    ..registerAdapter(PresentHiveAdapter())
    ..registerAdapter(EmployeeHiveAdapter());

  userSettingBox = await Hive.openBox("userSettingBox");
  presentBox = await Hive.openBox("presentBox");
  employeeBox = await Hive.openBox("employeeBox");

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  version = packageInfo.version;
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
    deviceInfoModel = iosDeviceInfo.utsname.machine;
    deviceInfoDeviceName = iosDeviceInfo.name;
    deviceInfoOSName = iosDeviceInfo.systemName;
    deviceInfoOSVersion = iosDeviceInfo.systemVersion;
    deviceId = iosDeviceInfo.identifierForVendor ?? "";
    deviceBrand = iosDeviceInfo.model;
    deviceInfoPlatform = "iPhone";
    deviceCode = deviceId;
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    androidId = await const AndroidId().getId() ?? "";
    deviceInfoModel = androidDeviceInfo.manufacturer;
    deviceInfoDeviceName = androidDeviceInfo.device;
    deviceInfoOSName = androidDeviceInfo.model;
    deviceInfoOSVersion = androidDeviceInfo.version.release;
    deviceId = androidDeviceInfo.id;
    deviceBrand = androidDeviceInfo.brand;
    deviceInfoPlatform = "Android";
    deviceCode = androidId;
  }
  macAddress = "";
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NetworkNotifier>(create: (_) => networkNotifier),
      ],
      child: MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    appContext = context;
    _initNetwork();
  }

  Future<void> _initNetwork() async {
    final connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult == ConnectivityResult.none) {
      if (mounted) {
        networkNotifier.disable();
      }
    } else {
      if (mounted) {
        networkNotifier.enable();
      }
    }
    subscription = Connectivity().onConnectivityChanged.listen((connectionResult) {
      if (connectionResult == ConnectivityResult.none) {
        networkNotifier.disable();
      } else {
        networkNotifier.enable();
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      key: navigatorKey,
      useInheritedMediaQuery: true,
      designSize: const Size(375, 907),
      builder: (BuildContext context, Widget? child) => MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routes: <String, WidgetBuilder>{
          "/": (BuildContext context) => const LoadingScreen(),
          // "/": (BuildContext context) => const TestPage(),
        },
        initialRoute: "/",
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(data: data.copyWith(textScaleFactor: 1), child: child!);
        },
      ),
    );
  }
}
