import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/presentation/home.dart';
import 'package:timeaccess_qrcode/presentation/login.dart';
import 'package:timeaccess_qrcode/presentation/sync_widget.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';
import 'package:timeaccess_qrcode/utils/helper.dart';
import 'package:timeaccess_qrcode/widgets/network_widget.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () => loadApp());
  }

  Future<void> loadApp() async {
    geoLocation = await getLocation();
    if (mounted) {
      if (!Helper.isSignIn()) {
        const LoginScreen().launch(
          context,
          isNewTask: true,
          type: PageTransitionType.rightToLeft,
        );
      } else {
        bool synced = userSettingBox.get(Constants.synced_employees) ?? false;
        if (synced) {
          const HomeScreen().launch(
            context,
            isNewTask: true,
            type: PageTransitionType.rightToLeft,
          );
        } else {
          Navigator.of(context).push(
            SyncWorkOverlay(onSuccess: () {
              const HomeScreen().launch(
                context,
                isNewTask: true,
                type: PageTransitionType.rightToLeft,
              );
            }, onFailed: () {
              const LoadingScreen().launch(
                context,
                isNewTask: true,
                type: PageTransitionType.rightToLeft,
              );
            }),
          );
        }
      }
    }
  }

  Future<String> getLocation() async {
    LocationPermission permission;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return "Location services are disabled.";
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permissions are denied";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permissions are permanently denied, we cannot request permissions.";
    }

    var currentPosition = await Geolocator.getCurrentPosition();

    return "${currentPosition.latitude},${currentPosition.longitude}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.zero,
                color: Colors.white,
                child: Image.asset("assets/logo.png"),
              ),
            ),
            const Positioned(left: 10, top: 10, child: NetworkWidget()),
          ],
        ),
      ),
    );
  }
}
