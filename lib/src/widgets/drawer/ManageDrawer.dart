import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/src/models/daily_forecast.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/services/weather_service.dart';
import 'package:weather_app/src/widgets/WeatherSurface.dart';
import 'dart:developer' as developer;
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:weather_app/src/widgets/drawer/CityCard.dart';

class ManageDrawer extends StatefulWidget {
  final List<Weather> weatherList;
  final VoidCallback? onBackPressed;
  final int selectedCity;
  final ValueChanged<int> onCitySelected;
  final Function(Weather)? onAddCityCallback;
  final Function(int index)? onSetDefaultCity;
  final Function(int index)? onDeleteCity;

  const ManageDrawer({super.key, required this.weatherList, required this.selectedCity, required this.onCitySelected, this.onBackPressed, this.onAddCityCallback, required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, required this.onSetDefaultCity, required this.onDeleteCity});

  @override
  State<ManageDrawer> createState() => _ManageDrawerState();
}

class _ManageDrawerState extends State<ManageDrawer> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
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

              SizedBox(height: height * 0.01),

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

              // 📍 Cities list
              Expanded(
                child: ListView.builder(
                  itemCount: widget.weatherList.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final weather = widget.weatherList[index];
                    return Slidable(
                      key: ValueKey(weather),
                      startActionPane: ActionPane(
                        extentRatio: 0.65,
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(
                          closeOnCancel: true,
                          confirmDismiss: () async {
                            widget.onSetDefaultCity?.call(index);

                            // 👇 FORCE the slidable to snap closed
                            Slidable.of(context)?.close();

                            return false; // prevent removal
                          },
                          onDismissed: () {},
                        ),
                        children: [
                          SlidableAction(
                            flex: 2,
                            onPressed: (_) {
                              widget.onSetDefaultCity?.call(index);
                            },
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            icon: Icons.settings,
                            label: 'Set Default City',
                          ),
                          SlidableAction(
                            flex: 1,
                            onPressed: (_) {
                              widget.onDeleteCity?.call(index);
                            },
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: CityCard(
                        key: ValueKey(weather), // ✅ every item needs a unique Key
                        weather: weather,
                        isSelected: index == widget.selectedCity,
                        onTap: () {
                          widget.onCitySelected(index);
                          Navigator.pop(context);
                        },
                      ),
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
        widget.weatherList.add(weather);
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
