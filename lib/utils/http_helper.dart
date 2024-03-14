import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:timeaccess_qrcode/main.dart';
import 'package:timeaccess_qrcode/presentation/loading.dart';
import 'package:timeaccess_qrcode/utils/constants.dart';
import 'package:timeaccess_qrcode/utils/extensions.dart';

import 'helper.dart';

class HttpHelper {
  static Future<http.Response?> post(String url, Map<String, dynamic> params, Map<String, String> headers, bool isJson) async {
    http.Client client = http.Client();
    headers.addAll({"accept": "application/json"});
    try {
      var response = await client.post(Uri.parse(url), headers: headers, body: isJson ? json.encode(params) : params);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (socketErr) {
      if (kDebugMode) {
        print("SocketException: $socketErr");
      }
      return null;
    } on TimeoutException catch (timeErr) {
      if (kDebugMode) {
        print("TimeOutException : $timeErr");
      }
      return null;
    } on Exception catch (err) {
      if (kDebugMode) {
        print("Error: $err");
      }
      return null;
    } catch (catchErr) {
      if (kDebugMode) {
        print("Error: $catchErr");
      }
      return null;
    }
  }

  static Future<http.Response?> authGet(String url, Map<String, String> headers) async {
    if (!Helper.isSignIn()) {
      const LoadingScreen().launch(appContext, isNewTask: true, type: PageTransitionType.fade);
      return null;
    }
    String deviceProductKey = userSettingBox.get(Constants.sharePreferencesKey) ?? "";

    http.Client client = http.Client();
    headers.addAll({"accept": "application/json", "device_product_key": deviceProductKey, "device_code": deviceCode});
    try {
      var response = await client.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401) {
        Helper.clearToken();
        if (appContext.mounted) {
          const LoadingScreen().launch(appContext, isNewTask: true, type: PageTransitionType.fade);
        }
        return null;
      } else {
        return null;
      }
    } on SocketException catch (socketErr) {
      if (kDebugMode) {
        print("SocketException: $socketErr");
      }
      return null;
    } on TimeoutException catch (timeErr) {
      if (kDebugMode) {
        print("TimeOutException : $timeErr");
      }
      return null;
    } on Exception catch (err) {
      if (kDebugMode) {
        print("Error: $err");
      }
      return null;
    } catch (catchErr) {
      if (kDebugMode) {
        print("Error: $catchErr");
      }
      return null;
    }
  }

  static Future<http.Response?> authPost(
    String url,
    Map<String, dynamic> params,
    Map<String, String> headers,
    bool isJSON, {
    bool force = false,
  }) async {
    if (!Helper.isSignIn()) {
      const LoadingScreen().launch(appContext, isNewTask: true, type: PageTransitionType.fade);
      return null;
    }
    String deviceProductKey = userSettingBox.get(Constants.sharePreferencesKey) ?? "";
    http.Client client = http.Client();
    headers.addAll({"accept": "application/json", "device_product_key": deviceProductKey, "device_code": deviceCode});
    if (isJSON) {
      headers.addAll({"Content-type": "application/json"});
    }
    try {
      var response = await client.post(Uri.parse(url), headers: headers, body: isJSON ? json.encode(params) : params);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401) {
        Helper.clearToken();
        if (appContext.mounted) {
          const LoadingScreen().launch(appContext, isNewTask: true, type: PageTransitionType.fade);
        }
        return null;
      } else if (force) {
        return response;
      } else {
        var data = json.decode(response.body);
        String message = data["message"].toString();
        throw Exception(message);
      }
    } on SocketException catch (socketErr) {
      if (kDebugMode) {
        print("SocketException: $socketErr");
      }
      return null;
    } on TimeoutException catch (timeErr) {
      if (kDebugMode) {
        print("TimeOutException : $timeErr");
      }
      return null;
    } on Exception catch (err) {
      if (kDebugMode) {
        print("Error: $err");
      }
      return null;
    } catch (catchErr) {
      if (kDebugMode) {
        print("Error: $catchErr");
      }
      return null;
    }
  }
}
