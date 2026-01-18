import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/src/models/weather.dart';

import 'package:weather_app/src/widgets/WeatherSurface.dart';

class TodayCard extends StatelessWidget {
  final Weather weather;
  final bool highlighted;

  const TodayCard(
      {super.key, required this.weather, required this.highlighted});

  bool get isCurrentBlock {
    final now = DateTime.now();
    final start = weather.date;
    final end = start.add(const Duration(hours: 3));
    return now.isAfter(start) && now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 80,
        height: 120,
        child: WeatherSurface(
          highlighted: highlighted, // 👈 HERE
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Center(
                  child: Text(
                    "${weather.temp.round()}°",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          isCurrentBlock ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // controls how dominant the icon is
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset('assets/icons/${weather.icon}.png'),
                  ),
                ),
                Text(
                  weather.condition,
                  style: TextStyle(
                    color: const Color.fromARGB(198, 255, 255, 255),
                    fontSize: 13,
                    fontWeight:
                        isCurrentBlock ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(weather.date),
                  style: TextStyle(
                    color: const Color.fromARGB(138, 255, 255, 255),
                    fontSize: 11,
                    fontWeight:
                        isCurrentBlock ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
