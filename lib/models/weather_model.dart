class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final DateTime sunrise;
  final DateTime sunset;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000, isUtc: true),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000, isUtc: true),
    );
  }
}
