import 'package:flutter/material.dart';

bool _isLoaderShowing = false;

void showLoader(BuildContext context) {
  if (_isLoaderShowing) return; // Prevent showing twice

  _isLoaderShowing = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        color: Color.fromARGB(255, 51, 24, 11),
      ),
    ),
  );
}

void hideLoader(BuildContext context) {
  if (_isLoaderShowing) {
    _isLoaderShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
