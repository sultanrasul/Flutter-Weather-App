class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double rainChance; // 0-1
  final String icon;
  final String condition;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.rainChance,
    required this.icon,
    required this.condition,
  });
}
