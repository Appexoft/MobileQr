// ignore_for_file: constant_identifier_names

enum ClockStatus {
  CLOCK_IN(0, "Clock In"),
  CLOCK_OUT(1, "Clock Out");

  const ClockStatus(this.value, this.text);

  final int value;
  final String text;
}
