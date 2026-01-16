import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'dart:developer' as developer;

class WeatherService {
  static const _apiKey = 'f831ea411b2ed1667ff737debbebd382';

  static Future<List<Weather>> fetchWeatherForecast(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast'
      '?q=$city&units=metric&appid=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather');
    }

    final data = json.decode(response.body);
    final cityName = data['city']['name'];
    final countryName = data['city']['country'];
    final List<dynamic> forecastList = data['list'];

    // Convert each forecast item into a Weather object
    final List<Weather> weatherList = forecastList
        .map((item) => Weather.fromForecastJson(item, cityName, countryName))
        .toList();


    return weatherList;
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
