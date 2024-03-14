import 'package:flutter/material.dart';

class NetworkNotifier with ChangeNotifier {
  bool _connected = false;

  bool get connected => _connected;

  set connected(bool value) {
    _connected = value;
    notifyListeners();
  }

  enable() {
    _connected = true;
    notifyListeners();
  }

  disable() {
    _connected = false;
    notifyListeners();
  }
}
