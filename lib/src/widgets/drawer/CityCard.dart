import 'package:flutter/material.dart';
import 'package:weather_app/src/models/weather.dart';


/// Sub-widget for a single city card
class CityCard extends StatelessWidget {
  final Weather weather;
  final bool isSelected;
  final VoidCallback onTap;

  const CityCard({
    super.key,
    required this.weather,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22.5),
          child: InkWell(
            borderRadius: BorderRadius.circular(22.5),
            onTap: onTap,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 35),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white12,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(22.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // City + country
                  Row(
                    children: [
                      Text(
                        '${weather.city},',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        weather.country,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  // Temp + icon
                  Row(
                    children: [
                      Text(
                        '${weather.temp.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        "assets/icons/${weather.icon}.png",
                        width: 45,
                        height: 45,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}