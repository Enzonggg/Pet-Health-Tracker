import 'package:flutter/material.dart';

// Global navigation key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Helper function to show SnackBar inside the phone frame
void showSnackBarInPhoneFrame({
  required String message,
  Color backgroundColor = Colors.green,
  Duration duration = const Duration(seconds: 2),
}) {
  if (navigatorKey.currentContext != null) {
    // Remove any existing SnackBars to prevent queuing
    ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();

    // Show the new SnackBar
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating, // Use floating to allow margins
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ), // Add margins to keep inside phone frame
      ),
    );
  }
}
