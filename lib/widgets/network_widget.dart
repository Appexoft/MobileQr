import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeaccess_qrcode/value_notifier/network_notifier.dart';

class NetworkWidget extends StatelessWidget {
  const NetworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkNotifier>(
      builder: (_, network, __) {
        return SizedBox(
          width: 20,
          height: 20,
          child: Icon(
            network.connected ? Icons.wifi : Icons.wifi_off,
            color: network.connected ? Colors.black : Colors.red,
            size: 18,
          ),
        );
      },
    );
  }
}
