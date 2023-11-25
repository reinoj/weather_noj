import 'package:flutter/material.dart';

enum WeatherException {
  cityInfoEmpty,
  cityForecastEmpty,
  nonUniqueId,
  non200Response,
  failedToInsert,
  dateFormatError,
}

void exceptionSnackBar(
  BuildContext context,
  String exception,
  String functionName,
) {
  final SnackBar snackBar = SnackBar(
    content: Text('$functionName: Error - $exception'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
