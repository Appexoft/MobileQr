import 'package:flutter/material.dart';
import 'dart:math';
import 'package:page_transition/page_transition.dart';

import 'constants.dart';

extension IntExtensions on int {
  Widget get height => SizedBox(height: toDouble());

  Widget get width => SizedBox(width: toDouble());
}

extension StringExtensions on String {
  int get parseToInt => int.parse(this);

  String get overflow => Characters(this).replaceAll(Characters(''), Characters('\u{200B}')).toString();

  bool get isNullOrEmpty => ["", null, false, 0].contains(this) ? true : false;

  String get capitalize => "${this[0].toUpperCase()}${substring(1)}";
}

extension DoubleExtensions on double? {
  /// Validate given double is not null and returns given value if null.
  double validate({double value = 0.0}) => this ?? value;

  /// 100.0.isBetween(50.0, 150.0) // true;
  /// 100.0.isBetween(100.0, 100.0) // true;
  /// ```
  bool isBetween(num first, num second) {
    final lower = min(first, second);
    final upper = max(first, second);
    return validate() >= lower && validate() <= upper;
  }

  /// Returns Size
  Size get size => Size(this!, this!);
}

extension BooleanExtensions on bool? {
  /// Validate given bool is not null and returns given value if null.
  bool validate({bool value = false}) => this ?? value;
}

extension ContextExtensions on BuildContext {
  /// return screen size
  Size size() => MediaQuery.of(this).size;

  /// return screen width
  double width() => MediaQuery.of(this).size.width;

  /// return screen height
  double height() => MediaQuery.of(this).size.height;

  /// return screen devicePixelRatio
  double pixelRatio() => MediaQuery.of(this).devicePixelRatio;

  /// returns brightness
  Brightness platformBrightness() => MediaQuery.of(this).platformBrightness;

  /// Return the height of status bar
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  /// Return the height of navigation bar
  double get navigationBarHeight => MediaQuery.of(this).padding.bottom;

  /// Returns Theme.of(context)
  ThemeData get theme => Theme.of(this);

  /// Returns primaryColor Color
  Color get primaryColor => theme.primaryColor;

  /// Returns scaffoldBackgroundColor Color
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  /// Returns cardColor Color
  Color get cardColor => theme.cardColor;

  /// Returns dividerColor Color
  Color get dividerColor => theme.dividerColor;

  /// Returns dividerColor Color
  Color get iconColor => theme.iconTheme.color!;

  /// Request focus to given FocusNode
  void requestFocus(FocusNode focus) {
    FocusScope.of(this).requestFocus(focus);
  }

  bool isPhone() => MediaQuery.of(this).size.width < 600;

  bool isTablet() => MediaQuery.of(this).size.width < 720 && MediaQuery.of(this).size.width >= 600;

  bool isDesktop() => MediaQuery.of(this).size.width >= 720;
}

extension WidgetExtension on Widget? {
  Future<T?> launch<T>(BuildContext context, {bool isNewTask = false, PageTransitionType type = PageTransitionType.rightToLeft}) async {
    if (isNewTask) {
      return await Navigator.of(context).pushAndRemoveUntil(PageTransition(child: this!, curve: Curves.easeIn, type: type, duration: Constants.pageTransitionTime), (route) => false);
    } else {
      return await Navigator.of(context).push(PageTransition(child: this!, curve: Curves.easeIn, type: type, duration: Constants.pageTransitionTime));
    }
  }

  Future<T?> launchAndFinish<T>(BuildContext context, {PageTransitionType type = PageTransitionType.rightToLeft}) async {
    return await Navigator.of(context).pushReplacement(PageTransition(
      child: this!,
      type: type,
      curve: Curves.easeIn,
      duration: Constants.pageTransitionTime,
    ));
  }
}
