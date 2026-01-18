import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/services/weather_service.dart';
import 'package:weather_app/src/widgets/BottomView.dart';
import 'package:weather_app/src/widgets/drawer/ManageDrawer.dart';
import 'package:weather_app/src/widgets/TopView.dart';
import 'dart:developer' as developer;

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late Future<WeatherForecastResult> weatherFuture;
  late Future<List<Weather>> drawerWeatherFuture;
  late List<String> cities = ["London"];
  late SharedPreferences prefs;
  int selectedCity = 0;

  @override
  void initState() {
    super.initState();

    cities = ["London"]; // safe default

    weatherFuture = WeatherService.fetchWeatherForecast(cities[selectedCity]);
    drawerWeatherFuture = WeatherService.fetchCurrentWeatherForCities(cities);

    _loadSavedCities(); // async update later
  }

  Future<void> _loadSavedCities() async {
    prefs = await SharedPreferences.getInstance();

    final savedCities = prefs.getStringList("cities");

    if (savedCities == null || savedCities.isEmpty) {
      await prefs.setStringList("cities", cities); // persist default
      return;
    }

    setState(() {
      cities = savedCities;
      weatherFuture = WeatherService.fetchWeatherForecast(cities[selectedCity]);
      drawerWeatherFuture = WeatherService.fetchCurrentWeatherForCities(cities);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey, // attach the key here
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<WeatherForecastResult>(
          future: weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text(
                'Error loading weather: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    // Bottom view (always visible)
                    SizedBox(
                      height: height * 0.73,
                      child: FutureBuilder(
                        future: weatherFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          // return BottomView(weatherList: snapshot.data);
                          return TopView(weather: snapshot.data!.weatherList[0]);
                        },
                      ),
                    ),

                    // Top view as draggable
                    DraggableScrollableSheet(
                      snap: true,
                      snapSizes: [0.27, 0.82],
                      snapAnimationDuration: Duration(milliseconds: 240),
                      initialChildSize: 0.27, // starting height (25% of screen)
                      minChildSize: 0.27, // minimum height (only handle visible)
                      maxChildSize: 0.82, // max height (expanded)
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: FutureBuilder(
                              future: weatherFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();

                                return Column(
                                  children: [
                                    // small handle
                                    Container(
                                      width: 50,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white38,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),

                                    // actual top view
                                    BottomView(weatherForecastResult: snapshot.data!)
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        drawer: FutureBuilder<List<Weather>>(
          future: drawerWeatherFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Drawer(
                backgroundColor: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            return ManageDrawer(
              scaffoldMessengerKey: scaffoldMessengerKey,
              selectedCity: selectedCity,
              weatherList: snapshot.data!,
              onCitySelected: (index) {
                setState(() {
                  selectedCity = index;
                  weatherFuture = WeatherService.fetchWeatherForecast(cities[selectedCity]);
                });
              },
              onAddCityCallback: (weather) async {
                cities.add(weather.city);
                await prefs.setStringList("cities", cities);

                setState(() {
                  drawerWeatherFuture = WeatherService.fetchCurrentWeatherForCities(cities);
                });
              },
              onSetDefaultCity: (int index) async {
                if (index == 0) return; // already default

                setState(() {
                  final city = cities.removeAt(index);
                  cities.insert(0, city);

                  selectedCity = 0;

                  weatherFuture = WeatherService.fetchWeatherForecast(cities[selectedCity]);
                  drawerWeatherFuture = WeatherService.fetchCurrentWeatherForCities(cities);
                });

                await prefs.setStringList("cities", cities);
                
                HapticFeedback.heavyImpact();

                await Future.delayed(const Duration(milliseconds: 150));

                HapticFeedback.heavyImpact();

                Navigator.of(context).pop();

                developer.log("Default city set to: ${cities.first}");
              },
              onDeleteCity: (int index) async {
                if (cities.length <= 1) {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text("You must have at least one city"),
                    ),
                  );
                  return;
                }

                setState(() {
                  cities.removeAt(index);

                  // Fix selected city index
                  if (selectedCity >= cities.length) {
                    selectedCity = cities.length - 1;
                  }

                  weatherFuture = WeatherService.fetchWeatherForecast(cities[selectedCity]);
                  drawerWeatherFuture = WeatherService.fetchCurrentWeatherForCities(cities);
                });

                await prefs.setStringList("cities", cities);

                HapticFeedback.heavyImpact();

                await Future.delayed(const Duration(milliseconds: 150));

                HapticFeedback.heavyImpact();

                Navigator.of(context).pop();
                developer.log("City deleted at index: $index");
              },
            );
          },
        ),
      ),
    );
  }
}
