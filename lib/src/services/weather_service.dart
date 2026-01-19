import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/daily_forecast.dart';
import 'dart:developer' as developer;

class WeatherForecastResult {
  final List<Weather> weatherList;
  final List<DailyForecast> dailyForecasts;

  WeatherForecastResult({
    required this.weatherList,
    required this.dailyForecasts,
  });
}

class WeatherService {
  static const _apiKey = 'f831ea411b2ed1667ff737debbebd382';

  /// Returns a tuple: [List<Weather>, List<DailyForecast>]
  static Future<WeatherForecastResult> fetchWeatherForecast({String? city, double? lat, double? lon}) async {
    assert(city != null || (lat != null && lon != null), 'Either city or lat/lon must be provided');

    final queryParameters = <String, String>{'appid': _apiKey, 'units': 'metric'};

    if (city != null) {
      queryParameters['q'] = city;
    } else {
      queryParameters['lat'] = lat!.toString();
      queryParameters['lon'] = lon!.toString();
    }

    final uri = Uri.https('api.openweathermap.org', '/data/2.5/forecast', queryParameters);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather');
    }

    final data = json.decode(response.body);
    final cityName = data['city']['name'];
    final countryName = data['city']['country'];
    final List<dynamic> forecastList = data['list'];

    // Convert each forecast item into a Weather object
    final List<Weather> weatherList = forecastList.map((item) => Weather.fromForecastJson(item, cityName, countryName)).toList();

    // Build DailyForecast list
    final List<DailyForecast> dailyForecasts = _buildDailyForecasts(weatherList);

    return WeatherForecastResult(
      weatherList: weatherList,
      dailyForecasts: dailyForecasts,
    );
  }

  static List<DailyForecast> _buildDailyForecasts(List<Weather> forecasts) {
    final Map<String, List<Weather>> grouped = {};

    // Group by date
    for (final w in forecasts) {
      final dayKey = w.date.toIso8601String().split('T')[0]; // yyyy-MM-dd
      grouped.putIfAbsent(dayKey, () => []).add(w);
    }

    final List<DailyForecast> daily = [];
    grouped.forEach((day, items) {
      final minTemp = items.map((e) => e.temp).reduce((a, b) => a < b ? a : b);
      final maxTemp = items.map((e) => e.temp).reduce((a, b) => a > b ? a : b);
      final rainChance = items.map((e) => e.precipitation).reduce((a, b) => a > b ? a : b);

      // Most frequent icon
      final iconCounts = <String, int>{};
      for (var item in items) {
        iconCounts[item.icon] = (iconCounts[item.icon] ?? 0) + 1;
      }
      final icon = iconCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      // ✅ Most frequent condition
      final conditionCounts = <String, int>{};
      for (final item in items) {
        conditionCounts[item.condition] = (conditionCounts[item.condition] ?? 0) + 1;
      }
      final condition = conditionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      daily.add(DailyForecast(date: items.first.date, minTemp: minTemp, maxTemp: maxTemp, rainChance: rainChance, icon: icon, condition: condition));
    });

    daily.sort((a, b) => a.date.compareTo(b.date));
    return daily;
  }

  static Future<List<Weather>> fetchCurrentWeatherForCities(List<String> cities) async {
    final List<Weather> results = [];

    for (final city in cities) {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?q=$city&units=metric&appid=$_apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) {
        developer.log('Failed to load weather for $city');
        continue;
      }
      final data = json.decode(response.body);
      results.add(Weather.fromCurrentJson(data));
    }

    return results;
  }
}
