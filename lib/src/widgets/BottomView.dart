import 'package:flutter/material.dart';
import 'package:weather_app/src/models/daily_forecast.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:weather_app/src/services/weather_service.dart';
import 'package:weather_app/src/widgets/TodayCard.dart';
import 'package:intl/intl.dart';

import 'dart:developer' as developer;

class BottomView extends StatelessWidget {
  // final List<Weather> weatherForecastResult;
  final WeatherForecastResult weatherForecastResult;

  const BottomView({super.key, required this.weatherForecastResult});

  @override
  Widget build(BuildContext context) {
    final List<Weather> filteredWeatherList = weatherForecastResult.weatherList.length > 8 ? weatherForecastResult.weatherList.sublist(0, 8) : weatherForecastResult.weatherList;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TODAY HEADER ─────────────────────────────
          Row(
            children: const [
              Text(
                "Today",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── TODAY HOURLY CARDS ───────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filteredWeatherList.asMap().entries.map((entry) {
                final index = entry.key;
                final weather = entry.value;

                return TodayCard(
                  weather: weather,
                  highlighted: index == 0,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ── DAILY FORECAST LIST ──────────────────────
          Column(
            children: weatherForecastResult.dailyForecasts.map((forecast) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // DAY
                    SizedBox(
                      width: 40,
                      child: Text(
                        DateFormat('EEE').format(forecast.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                
                    const SizedBox(width: 40),
                
                    // ICON + CONDITION (FIXED WIDTH)
                    SizedBox(
                      width: 160,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              "assets/icons/${forecast.icon}.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              forecast.condition,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    const Spacer(),
                
                    // TEMPERATURES
                    SizedBox(
                      width: 95,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              "+${forecast.maxTemp.round()}°",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "+${forecast.minTemp.round()}°",
                              style: const TextStyle(
                                color: Color.fromARGB(183, 255, 255, 255),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
