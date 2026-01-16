import 'package:flutter/material.dart';

class WeatherSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool highlighted; // 👈 NEW

  const WeatherSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    this.margin,
    this.highlighted = false, // default = normal
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        // subtle outer tint for highlighted
        color: highlighted
            ? const Color.fromARGB(94, 35, 118, 206)
            : const Color.fromARGB(0, 255, 255, 255),
        borderRadius: borderRadius,
        border: !highlighted ? Border.all(color: const Color.fromARGB(40, 255, 255, 255)) : null
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // MAIN BACKGROUND
            Container(
              decoration: BoxDecoration(
                gradient: highlighted ? _highlightGradient : null,
                borderRadius: borderRadius,
              ),
            ),

            // GLOW (only when highlighted)
            if (highlighted)
              Container(
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 0.8,
                    colors: [
                      Color(0xFF4FC3F7),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: borderRadius,
                ),
              ),

            child,
          ],
        ),
      ),
    );
  }
}

const _highlightGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF3FA9F5),
    Color(0xFF1E78D6),
    Color(0xFF0D47A1),
  ],
);
