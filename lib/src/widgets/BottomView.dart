import 'package:flutter/material.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/widgets/TodayCard.dart';

import 'dart:developer' as developer;

class BottomView extends StatelessWidget {
  final List<Weather> weatherList;

  const BottomView({super.key, required this.weatherList});

  @override
  Widget build(BuildContext context) {
    // Get today's date without time (just year, month, day)
    final today = DateTime.now();
    
    developer.log('Today - Day: ${today.day} - Month: ${today.month} - Year: ${today.year}');
    developer.log('Other - Day: ${weatherList[0].date.day} - Month: ${weatherList[0].date.month} - Year: ${weatherList[0].date.year}');

    final filteredWeatherList = weatherList.length > 8 ? weatherList.sublist(0, 8) : weatherList;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(children: [
        Row(
          children: [
            Row(
              children: [
                // const SizedBox(width: 4),
                Text(
                  "Today",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  // "7 days",
                  "",
                  style: const TextStyle(
                    color: Color.fromARGB(137, 255, 255, 255),
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                // const Icon(Icons.chevron_right_rounded,
                //     color: Color.fromARGB(137, 255, 255, 255), size: 30),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredWeatherList.asMap().entries.map((entry) {
              final index = entry.key;
              final weather = entry.value;

              return TodayCard(
                weather: weather,
                highlighted: index == 0, // only first card is highlighted
              );
            }).toList(),
          ),
        )
      ]),
    );
  }
}
