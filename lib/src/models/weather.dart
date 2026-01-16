class Weather {
  final String city;
  final double temp;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final DateTime date;
  final double precipitation;
  final String country;

  Weather({
    required this.city,
    required this.temp,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.date,
    required this.precipitation, 
    required this.country,
  });

  factory Weather.fromForecastJson(Map<String, dynamic> json, String city, String country) {
    return Weather(
      city: city,
      country: country,
      temp: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      precipitation: json["pop"].toDouble(),
      date: DateTime.parse(json['dt_txt']),
    );
  }

  factory Weather.fromCurrentJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      country: json['sys']["country"],
      temp: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      precipitation: 0.0, // not provided by current weather
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

}
