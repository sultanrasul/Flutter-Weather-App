import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/src/models/daily_forecast.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/services/weather_service.dart';
import 'package:weather_app/src/widgets/WeatherSurface.dart';
import 'dart:developer' as developer;
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:weather_app/src/widgets/drawer/CityCard.dart';
import 'package:weather_app/src/widgets/drawer/add_city_sheet.dart';

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
                            // Prevent full swipe dismissal
                            return false;
                          }, onDismissed: () {  },
                        ),
                        children: [
                          SlidableAction(
                            flex: 2,
                            onPressed: (_) {
                              widget.onSetDefaultCity?.call(index);
                              // Close the slidable smoothly
                              Slidable.of(context)?.close();
                            },
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            icon: Icons.settings,
                            label: 'Set Default City',
                          ),
                          SlidableAction(
                            flex: 1,
                            onPressed: (_) {
                              // Delete the city
                              widget.onDeleteCity?.call(index);

                              // Close the slidable smoothly
                              Slidable.of(context)?.close();
                            },
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                backgroundColor: Colors.black87,
                builder: (context) {
                  return AddCitySheet(
                    onAddCity: (weather) {
                      widget.onAddCityCallback?.call(weather);
                    },
                  );
                },
              );
            },
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
}
