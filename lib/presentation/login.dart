// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/presentation/home.dart';
import 'package:timeaccess_qrcode/presentation/loading.dart';
import 'package:timeaccess_qrcode/presentation/sync_widget.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';
import 'package:timeaccess_qrcode/utils/http_helper.dart';
import 'package:timeaccess_qrcode/widgets/app_info.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _key_1_Controller = TextEditingController();
  final TextEditingController _key_2_Controller = TextEditingController();
  final TextEditingController _key_3_Controller = TextEditingController();
  final TextEditingController _key_4_Controller = TextEditingController();

  final FocusNode _key_1_Node = FocusNode();
  final FocusNode _key_2_Node = FocusNode();
  final FocusNode _key_3_Node = FocusNode();
  final FocusNode _key_4_Node = FocusNode();

  bool otpValidate = false;
  String otpValidateMessage = "";

  bool sending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _key_1_Controller.dispose();
    _key_2_Controller.dispose();
    _key_3_Controller.dispose();
    _key_4_Controller.dispose();
    _key_1_Node.dispose();
    _key_2_Node.dispose();
    _key_3_Node.dispose();
    _key_4_Node.dispose();
    super.dispose();
  }

  Future login() async {
    FocusScope.of(context).requestFocus(FocusNode());
    String key1 = _key_1_Controller.text.trim();
    String key2 = _key_2_Controller.text.trim();
    String key3 = _key_3_Controller.text.trim();
    String key4 = _key_4_Controller.text.trim();

    bool isError = false;
    if (key1.isEmpty || key2.isEmpty || key3.isEmpty || key4.isEmpty) {
      if (!isError) {
        isError = true;
      }
      otpValidate = true;
      otpValidateMessage = "Please insert the activate code";
    } else {
      otpValidate = false;
      otpValidateMessage = "";
    }

    setState(() {});
    if (isError) {
      return;
    }
    setState(() {
      sending = true;
    });
    final List<String> ipAddresses = [];
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        ipAddresses.add(addr.address);
      }
    }
    String activateCode = "$key1-$key2-$key3-$key4";
    debugPrint("Send Activate Code: $activateCode for $deviceCode");
    String url = "${Constants.URL}/login";
    var params = {
      "device_product_key": activateCode,
      "device_id": deviceCode,
      "mac_address": "",
      "ip_address": ipAddresses.join(", "),
      "gps_location": geoLocation,
    };
    var response = await HttpHelper.post(url, params, {}, false);
    if (mounted) {
      if (response != null) {
        setState(() {
          sending = false;
        });
        if (response.statusCode == 200 || response.statusCode == 201) {
          userSettingBox.put(Constants.sharePreferencesKey, activateCode);
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
        } else {
          if (response.statusCode < 200 || response.statusCode > 400) {
            setState(() {
              otpValidate = true;
              otpValidateMessage = "Error while fetching data";
            });
          }
          if (response.statusCode == 400) {
            otpValidate = true;
            otpValidateMessage = jsonDecode(response.body)["message"];
          }
        }
      } else {
        setState(() {
          otpValidate = true;
          otpValidateMessage = "Internal Server Error";
          sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset("assets/logo.png", fit: BoxFit.contain, height: 52),
        ),
        body: Container(
          padding: const EdgeInsets.all(25.0),
          alignment: Alignment.center,
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            direction: Axis.vertical,
            children: <Widget>[
              const SizedBox(height: 40),
              SelectableText(
                "Device ID: ${deviceCode.toUpperCase()}",
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _key_1_Controller,
                      focusNode: _key_1_Node,
                      maxLength: 5,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      onChanged: (term) {
                        if (term.length == 5) {
                          _key_1_Node.unfocus();
                          FocusScope.of(context).requestFocus(_key_2_Node);
                        }
                      },
                      onSubmitted: (_) {
                        _key_1_Node.unfocus();
                        FocusScope.of(context).requestFocus(_key_2_Node);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  Container(
                    width: 10.w,
                    height: 2.h,
                    decoration: const BoxDecoration(color: Colors.black),
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _key_2_Controller,
                      focusNode: _key_2_Node,
                      maxLength: 5,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      onChanged: (term) {
                        if (term.length == 5) {
                          _key_2_Node.unfocus();
                          FocusScope.of(context).requestFocus(_key_3_Node);
                        }
                      },
                      onSubmitted: (_) {
                        _key_2_Node.unfocus();
                        FocusScope.of(context).requestFocus(_key_3_Node);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  Container(
                    width: 10.w,
                    height: 2.h,
                    decoration: const BoxDecoration(color: Colors.black),
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _key_3_Controller,
                      focusNode: _key_3_Node,
                      maxLength: 5,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      onChanged: (term) {
                        if (term.length == 5) {
                          _key_3_Node.unfocus();
                          FocusScope.of(context).requestFocus(_key_4_Node);
                        }
                      },
                      onSubmitted: (_) {
                        _key_3_Node.unfocus();
                        FocusScope.of(context).requestFocus(_key_4_Node);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  Container(
                    width: 10.w,
                    height: 2.h,
                    decoration: const BoxDecoration(color: Colors.black),
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _key_4_Controller,
                      focusNode: _key_4_Node,
                      maxLength: 5,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      onChanged: (term) {
                        if (term.length == 5) {
                          _key_4_Node.unfocus();
                        }
                      },
                      onSubmitted: (_) {
                        _key_4_Node.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              otpValidate
                  ? Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        otpValidateMessage,
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: sending
                    ? null
                    : () {
                        login();
                      },
                child: sending
                    ? const SpinKitDualRing(
                        color: Colors.white,
                        size: 20,
                        lineWidth: 3,
                      )
                    : const Text(
                        "Activate",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              Expanded(child: Container()),
              AppInfo(parent: context),
            ],
          ),
        ),
      ),
    );
  }
}
