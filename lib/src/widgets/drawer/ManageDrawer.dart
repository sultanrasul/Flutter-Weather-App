import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/src/models/daily_forecast.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/services/weather_service.dart';
import 'package:weather_app/src/widgets/WeatherSurface.dart';
import 'dart:developer' as developer;

import 'package:weather_app/src/widgets/drawer/CityCard.dart';

class ManageDrawer extends StatefulWidget {
  final List<Weather> weatherList;
  final VoidCallback? onBackPressed;
  final int selectedCity;
  final ValueChanged<int> onCitySelected;
  final Function(Weather)? onAddCityCallback;

  const ManageDrawer({
    super.key,
    required this.weatherList,
    required this.selectedCity,
    required this.onCitySelected,
    this.onBackPressed,
    this.onAddCityCallback,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  });

  @override
  State<ManageDrawer> createState() => _ManageDrawerState();
}

class _ManageDrawerState extends State<ManageDrawer> {
  late List<Weather> _weatherList;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _weatherList = List.from(widget.weatherList); // local copy for reordering
  }

  Future<void> loadPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return WeatherSurface(
      highlighted: true,
      borderRadius: BorderRadius.circular(22),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                ),
              ),

              SizedBox(height: height * 0.05),

              // 🏙 Manage title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    'Manage cities',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 📍 Reorderable Cities list
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: _weatherList.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final Weather item = _weatherList.removeAt(oldIndex);
                      _weatherList.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final weather = _weatherList[index];
                    return CityCard(
                      key: ValueKey(weather), // ✅ every item needs a unique Key
                      weather: weather,
                      isSelected: index == widget.selectedCity,
                      onTap: () {
                        widget.onCitySelected(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ➕ Floating button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: FloatingActionButton(
            onPressed: () => _showAddCitySheet(context),
            shape: const CircleBorder(),
            backgroundColor: const Color.fromARGB(181, 0, 0, 0),
            child: const Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCitySheet(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.black87,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add a new city',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
                onSubmitted: (value) async {
                  if (value.isEmpty) return;
                  await _addCity(value, context);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final value = controller.text.trim();
                  if (value.isEmpty) return;
                  await _addCity(value, context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Text(
                    'Add City',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addCity(String city, BuildContext context) async {
    try {
      final result = await WeatherService.fetchWeatherForecast(city);

      final Weather weather = result.weatherList.first;

      widget.onAddCityCallback?.call(weather);

      Navigator.pop(context);

      setState(() {
        _weatherList.add(weather);
      });
    } catch (e) {
      developer.log('Failed to load weather for $city: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('City not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
