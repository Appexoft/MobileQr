import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(minutes: 1)),
      builder: (context, snapshot) {
        return Text(
          DateFormat('E dd MMM yyyy hh:mm a').format(DateTime.now()),
          style: const TextStyle(fontSize: 22),
        );
      },
    );
  }
}
