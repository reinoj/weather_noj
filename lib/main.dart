import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:weather_noj/city.dart';
import 'package:weather_noj/database.dart';
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
      home: HomePage(title: 'WeatherNoj'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    databaseHelper.initDB().whenComplete(() async {
      setState(() {});
    });
  }

  Future<void> newCityNavigate(BuildContext context) async {
    final List<double> result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const NewCityPage()));

    if (!mounted) return;

    Points points = await fetchPoints(result[0], result[1]);
    databaseHelper.insertCityInfo(
      CityInfoCompanion(
        city: points.properties.relativeLocation.properties.city,
        state: points.properties.relativeLocation.properties.state,
        latitude: result[0],
        longitude: result[1],
        gridId: points.properties.gridId,
        gridX: points.properties.gridX,
        gridY: points.properties.gridY,
        time: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: WeatherInfo(databaseHelper: databaseHelper),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
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
      ),
    );
  }
}

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key, required this.databaseHelper});

  final DatabaseHelper databaseHelper;

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  final int _currentTemp = 0;

  final List<List<int>> _forecast = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [4, 5],
    [5, 6],
    [6, 7],
  ];

  final List<int> _hourly = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
  ];

  Future<void> dbSnackbar() async {
    final List<CityInfo> result = await widget.databaseHelper.getCityInfos();

    if (!mounted) return;

    final SnackBar snackBar = SnackBar(
        content: Column(
      children: [
        for (int i = 0; i < result.length; i++) Text(result[i].toString())
      ],
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
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
              child: CurrentWeather(currentTemp: _currentTemp),
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
              child: Hourly(hourly: _hourly),
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
              child: Forecast(forecast: _forecast),
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
  }
}

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({
    super.key,
    required this.currentTemp,
  });

  final int currentTemp;

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
            '${currentTemp.toString()}°',
            style: TextStyle(fontSize: 80.0),
          ),
        ),
      ],
    );
  }
}

class Hourly extends StatelessWidget {
  const Hourly({super.key, required this.hourly});

  final List<int> hourly;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // for (var temp in hourly)
          for (int i = 0; i < hourly.length; i++)
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
                    '${hourly[i]}°',
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

class Forecast extends StatelessWidget {
  const Forecast({super.key, required this.forecast});

  final List<List<int>> forecast;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // for (var [a, e] in forecast)
        for (int i = 0; i < forecast.length; i++)
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
                  '${forecast[i][0]}° / ${forecast[i][1]}°',
                  // "$a / $e",
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
