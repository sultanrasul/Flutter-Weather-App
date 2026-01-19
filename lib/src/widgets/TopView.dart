import 'package:flutter/material.dart';
import 'package:weather_app/src/models/weather.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/src/widgets/WeatherSurface.dart';

class TopView extends StatelessWidget {
  final Weather weather;

  const TopView({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40), // slightly bigger radius
            bottomRight: Radius.circular(40),
          ),
          color: Color.fromARGB(94, 35, 118, 206)),
      child: WeatherSurface(
        highlighted: true,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded,
                            color: Colors.white, size: 27),
                        onPressed: () {
                          Scaffold.of(context)
                              .openDrawer(); // opens the drawer from WeatherView
                        },
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "${weather.city},",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          weather.country,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white, size: 27),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // 🌤 Weather content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status tag
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 12, vertical: 5),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: Colors.white.withOpacity(0.4),
                    //     ),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Container(
                    //         width: 6,
                    //         height: 6,
                    //         decoration: const BoxDecoration(
                    //           color: Colors.greenAccent,
                    //           shape: BoxShape.circle,
                    //         ),
                    //       ),
                    //       const SizedBox(width: 6),
                    //       const Text(
                    //         'Updated',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Weather icon (max size without overflow)

                    Expanded(
                      flex: 1, // controls how dominant the icon is
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.asset('assets/icons/${weather.icon}.png'),
                      ),
                    ),

                    // Temperature
                    Text(
                      '${weather.temp.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Condition
                    Text(
                      weather.condition,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),

                    // Date
                    Text(
                      DateFormat('EEEE, d MMM').format(weather.date),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Divider(
                      color: Colors.white.withOpacity(0.3),
                      indent: 40,
                      endIndent: 40,
                    ),

                    const SizedBox(height: 10),

                    // Bottom stats
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _WeatherStat(
                              icon: Icons.air,
                              label:
                                  '${(weather.windSpeed * 2.23694).round()} mph',
                              type: 'Wind',
                            ),
                          ),
                          Expanded(
                            child: _WeatherStat(
                              icon: Icons.water_drop,
                              label: '${weather.humidity}%',
                              type: 'Humidity',
                            ),
                          ),
                          Expanded(
                            child: _WeatherStat(
                              icon: Icons.cloud,
                              label:
                                  '${(weather.precipitation * 100).round()}%',
                              type: 'Chance of rain',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;

  const _WeatherStat({
    required this.icon,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(type,
            style: const TextStyle(
                color: Color.fromARGB(118, 255, 255, 255), fontSize: 12))
      ],
    );
  }
}
