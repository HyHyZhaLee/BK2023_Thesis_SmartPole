import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class GlobalHelper {
  // Global key to access the Navigator's context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Retrieve the current BuildContext
  static BuildContext? getContext() {
    return navigatorKey.currentContext;
  }
}

String getCurrentTimestamp() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 7)); // GMT+7
  final formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  return '${formatter.format(now)} GMT+0700';
}
