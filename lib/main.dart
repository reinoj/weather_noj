import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_noj/city.dart';
import 'package:weather_noj/database.dart';
import 'package:weather_noj/exceptions.dart';
import 'package:weather_noj/forecast.dart';
import 'package:weather_noj/points.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherNoj',
      theme: ThemeData(
        colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: Colors.grey.shade900,
            onPrimary: Colors.white70,
            secondary: Colors.blue.shade900,
            onSecondary: Colors.white70,
            error: Colors.red.shade900,
            onError: Colors.white70,
            background: Colors.grey.shade800,
            onBackground: Colors.white70,
            surface: Colors.blueGrey.shade900,
            onSurface: Colors.white70),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key});

  final String title = 'WeatherNoj';
  DatabaseHelper? databaseHelper;
  SharedPreferences? prefs;
  int? currentCity;
  List<CityInfo>? allCities;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    initHelper();
    super.initState();
  }

  Future<void> initHelper() async {
    widget.databaseHelper = DatabaseHelper();
    await widget.databaseHelper!.initDB();

    await updateAllCities();
    int numCities = widget.allCities!.length;

    widget.prefs = await SharedPreferences.getInstance();
    widget.currentCity = widget.prefs!.getInt('currentCity');
    if (widget.currentCity == null) {
      widget.prefs!.setInt('currentCity', numCities - 1);
      widget.currentCity = widget.prefs!.getInt('currentCity');
    } else if (widget.currentCity == -1) {
      if (numCities > 0) {
        if (widget.allCities != null) {
          widget.currentCity = widget.allCities![0].id;
        } else {
          if (!mounted) return;
          exceptionSnackBar(
            context,
            'allCities is null, but numCities is non-zero',
            'initHelper',
          );
        }
      }
    }
    setState(() {});
  }

  bool allInitialized() {
    return (widget.databaseHelper != null &&
        widget.prefs != null &&
        widget.currentCity != null &&
        widget.allCities != null);
  }

  Future<void> newCityNavigate(BuildContext context) async {
    final List<double> result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewCityPage()),
    );

    if (!mounted) return;

    Points? points;
    WeatherException? we;
    (points, we) = await fetchPoints(result[0], result[1]);
    if (points != null) {
      int cityId = await widget.databaseHelper!.checkCityInfo(points, result);

      if (!mounted) return;

      switch (cityId) {
        case -1:
          exceptionSnackBar(
            context,
            WeatherException.nonUniqueId.toString(),
            'newCityNavigate',
          );
          break;
        case 0:
          exceptionSnackBar(
            context,
            WeatherException.failedToInsert.toString(),
            'newCityNavigate',
          );
        default:
      }

      (ForecastInfo, ForecastInfo)? forecasts;
      (forecasts, we) = await fetchForecast(widget.databaseHelper!, cityId);

      if (forecasts != null) {
        int forecastCityId = await widget.databaseHelper!.insertCityForecast(
          toCityForecast(forecasts.$1, forecasts.$2, cityId),
        );

        if (!mounted) return;
        if (forecastCityId <= 0) {
          exceptionSnackBar(context, 'City not added.', 'newCityNavigate');
        } else {
          setState(() {
            widget.currentCity = forecastCityId;
          });
        }
      } else {
        if (!mounted) return;
        exceptionSnackBar(context, we!.toString(), 'newCityNavigate');
      }
    }
  }

  Future<void> updateAllCities() async {
    List<CityInfo> updatedCities = await widget.databaseHelper!.getCityInfos();
    setState(() {
      widget.allCities = updatedCities;
    });
  }

  Drawer menuDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('Menu')),
          if (widget.allCities != null)
            for (int i = 0; i < widget.allCities!.length; i++)
              ListTile(
                title: Text(
                    '${widget.allCities![i].city}, ${widget.allCities![i].state}'),
                onTap: () {
                  Navigator.pop(context);
                  widget.currentCity = widget.allCities![i].id;
                },
              ),
          ListTile(
            title: Text('Add New City'),
            onTap: () {
              Navigator.pop(context);
              newCityNavigate(context);
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget weatherAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(widget.title),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: () {
            updateAllCities();
          },
          icon: const Icon(Icons.update),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allInitialized()) {
      if (widget.allCities!.isNotEmpty) {
        return Scaffold(
          appBar: weatherAppBar(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SingleChildScrollView(
            child: WeatherInfo(
              databaseHelper: widget.databaseHelper!,
              currentCity: widget.currentCity!,
            ),
          ),
          drawer: menuDrawer(),
        );
      } else {
        return Scaffold(
          appBar: weatherAppBar(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Text(
            'No Cities...',
            textAlign: TextAlign.center,
          ),
          drawer: menuDrawer(),
        );
      }
    } else {
      return Scaffold(
        appBar: weatherAppBar(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Text(
          'Loading...',
          textAlign: TextAlign.center,
        ),
        drawer: menuDrawer(),
      );
    }
  }
}

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({
    super.key,
    required this.databaseHelper,
    required this.currentCity,
  });

  final DatabaseHelper databaseHelper;
  final int currentCity;

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  int? _currentTemp;
  List<int>? _daily;
  List<int>? _hourly;

  @override
  initState() {
    super.initState();

    _currentTemp = 0;
    _daily = List<int>.filled(14, 0);
    _hourly = List<int>.filled(24, 0);

    updateWeatherValues();
    setState(() {});
  }

  bool isInitialized() {
    return (_currentTemp != null && _daily != null && _hourly != null);
  }

  Future<void> dbSnackbar() async {
    // final List<CityInfo> result = await widget.databaseHelper.getCityInfos();
    CityForecast? cf;
    WeatherException? we;
    (cf, we) = await widget.databaseHelper.getCityForecast(widget.currentCity);
    if (!mounted) return;

    if (cf != null) {
      final SnackBar snackBar = SnackBar(
        content: Text(cf.toString()),
        // content: Column(
        //   children: [
        //     for (int i = 0; i < result.length; i++) Text(result[i].toString()),
        //   ],
        // ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print(we.toString());
    }
  }

  Future<void> updateWeatherValues() async {
    CityForecast? cityForecast;
    WeatherException? we;
    (cityForecast, we) =
        await widget.databaseHelper.getCityForecast(widget.currentCity);
    if (cityForecast != null) {
      setState(() {
        _currentTemp = cityForecast!.temperature;
        _daily = cityForecast.dailyForecast;
        _hourly = cityForecast.hourlyForecast;
      });
    } else {
      exceptionSnackBar(context, we!.toString(), 'updateWeatherValues');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: CurrentWeather(currentTemp: _currentTemp!),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Hourly(hourly: _hourly!),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Daily(forecast: _daily!),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                dbSnackbar();
              },
              child: const Text('db'),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text('Loading Forecast...'),
      );
    }
  }
}

class CurrentWeather extends StatefulWidget {
  const CurrentWeather({
    super.key,
    required this.currentTemp,
  });

  final int currentTemp;

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Picture',
            style: TextStyle(fontSize: 32.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '${widget.currentTemp.toString()}°',
            style: TextStyle(fontSize: 80.0),
          ),
        ),
      ],
    );
  }
}

class Hourly extends StatefulWidget {
  const Hourly({super.key, required this.hourly});

  final List<int> hourly;

  @override
  State<Hourly> createState() => _HourlyState();
}

class _HourlyState extends State<Hourly> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // for (var temp in hourly)
          for (int i = 0; i < widget.hourly.length; i++)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    // '$tmpCounter',
                    '$i',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '${widget.hourly[i]}°',
                    // "$temp",
                    style: TextStyle(fontSize: 24.0),
                  ),
                  Text(
                    '0%',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

class Daily extends StatefulWidget {
  const Daily({super.key, required this.forecast});

  final List<int> forecast;

  @override
  State<Daily> createState() => _DailyState();
}

class _DailyState extends State<Daily> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // for (var [a, e] in forecast)
        for (int i = 0; i < widget.forecast.length; i += 2)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${i}day',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '0%',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  'A / E',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '${widget.forecast[i]}° / ${widget.forecast[i + 1]}°',
                  style: TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          )
      ],
    );
  }
}

class NewCityPage extends StatefulWidget {
  const NewCityPage({super.key});

  @override
  State<NewCityPage> createState() => _NewCityPageState();
}

class _NewCityPageState extends State<NewCityPage> {
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  String? validatorFunction(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    double? isDouble = double.tryParse(value);
    if (isDouble == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Add City'),
        centerTitle: true,
      ),
      body: Form(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter Latitude',
                ),
                controller: latitudeController,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter Longitude',
                ),
                controller: longitudeController,
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  double? lat = double.tryParse(latitudeController.text);
                  double? lon = double.tryParse(longitudeController.text);
                  if (lat != null && lon != null) {
                    Navigator.pop(context, [lat, lon]);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: const Text('Add City'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
