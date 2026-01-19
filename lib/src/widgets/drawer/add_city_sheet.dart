import 'package:flutter/material.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/services/weather_service.dart';
import 'dart:developer' as developer;
import 'package:toastification/toastification.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class AddCitySheet extends StatefulWidget {
  final Function(Weather) onAddCity;

  const AddCitySheet({super.key, required this.onAddCity});

  @override
  State<AddCitySheet> createState() => _AddCitySheetState();
}

class _AddCitySheetState extends State<AddCitySheet> {
  Future<Position?> getLocation() async {
    // 1️⃣ Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Location services are disabled.');
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        context: context,
        title: const Text('Location Disabled'),
        description: const Text('Please enable location services.'),
      );
      return null;
    }

    // 2️⃣ Check current permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      developer.log('User denied location permission.');
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
        title: const Text('Permission Denied'),
        description: const Text('Cannot access location without permission.'),
      );
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log('Location permissions are permanently denied.');
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
        title: const Text('Permission Denied Forever'),
        description: const Text('Go to settings to allow location access.'),
      );
      return null;
    }

    // 3️⃣ Permissions OK → get location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    developer.log('Location -> Lat: ${position.latitude}, Lon: ${position.longitude}');
    return position;
  }

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.location_city,
                      color: Colors.white70,
                    ),
                    hintText: 'Enter city name',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  onSubmitted: (value) async {
                    if (value.trim().isEmpty || _isLoading) return;
                    await _addCity(city: value.trim());
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                width: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final value = _controller.text.trim();
                          if (value.isEmpty) return;
                          await _addCity(city: value);
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.add,
                          size: 26,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                width: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final position = await getLocation();
                          if (position == null) return; // Permission denied or service off

                          await _addCity(
                            lat: position.latitude,
                            lon: position.longitude,
                          );
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.location_pin, size: 26, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Future<void> _addCity({String? city, double? lon, double? lat}) async {
    assert(city != null || (lat != null && lon != null), 'Either city or lat/lon must be provided');
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await WeatherService.fetchWeatherForecast(city: city, lon: lon, lat: lat);
      final Weather weather = result.weatherList.first;
      widget.onAddCity(weather);
      Navigator.pop(context);

    } catch (e) {
      developer.log('Failed to load weather for $city: $e');
      toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.center,
          context: context,
          title: Text(
            'City not found',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          description: Text(
            'City not found. Check the spelling or try another city.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          autoCloseDuration: const Duration(milliseconds: 5000));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
