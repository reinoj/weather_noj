import 'package:flutter/material.dart';
import 'package:path/path.dart';

enum WeatherException {
  cityInfoEmpty,
  cityForecastEmpty,
  nonUniqueId,
  non200Response,
  failedToInsert,
}

void exceptionSnackBar(
  BuildContext context,
  WeatherException we,
  String functionName,
) {
  final SnackBar snackBar = SnackBar(
    content: Text('$functionName: Error - ${we.toString()}'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
