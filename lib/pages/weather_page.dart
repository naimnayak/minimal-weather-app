import 'package:flutter/material.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/services/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService('4385f0100a5ab1e34991330346f53145');
  Weather? _currentWeather;
  Weather? _selectedCityWeather;
  bool _isLoading = true;
  bool _isDaytime = true;
  String? _error;

  final List<String> _cities = ['Bangalore', 'Chennai', 'Delhi', 'Kolkata'];

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocationWeather();
  }

  Future<void> _fetchCurrentLocationWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _currentWeather = weather;
        _selectedCityWeather = null;
        _isLoading = false;
        _isDaytime = _calculateDaytime(weather);
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _fetchWeatherForCity(String cityName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _selectedCityWeather = weather;
        _isLoading = false;
        _isDaytime = _calculateDaytime(weather);
      });
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    setState(() {
      _isLoading = false;
      _error = 'Error loading weather: ${error.toString()}';
    });
  }

  bool _calculateDaytime(Weather weather) {
    DateTime now = DateTime.now();
    return now.isAfter(weather.sunrise ?? DateTime(0)) && now.isBefore(weather.sunset ?? DateTime(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.lightBlue,
      ),
      drawer: _buildCityDrawer(),
      backgroundColor: Colors.lightBlue[100],
      body: Center(
        child: _isLoading
            ? _buildLoadingIndicator()
            : _error != null
            ? _buildErrorIndicator()
            : _buildWeatherCard(_selectedCityWeather ?? _currentWeather),
      ),
      floatingActionButton: _selectedCityWeather != null
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _isLoading = true; // Show loading indicator immediately
          });
          _fetchCurrentLocationWeather().then((_) {
            setState(() {
              _isLoading = false; // Hide loading indicator
            });
          });
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.home),
      )
          : null,
    );
  }

  Widget _buildCityDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Select a City',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _cities.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final city = _cities[index];
                return ListTile(
                  title: Text(city),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _fetchWeatherForCity(city);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/sun.json', height: 150),
        const SizedBox(height: 16),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text('Loading City...'),
      ],
    );
  }

  Widget _buildErrorIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 100),
        const SizedBox(height: 16),
        Text(_error!, style: const TextStyle(fontSize: 18, color: Colors.red)),
      ],
    );
  }

  Widget _buildWeatherCard(Weather? weather) {
    if (weather == null) {
      return const Text('Error loading weather');
    }

    bool isDaytime = _calculateDaytime(weather);

    return SizedBox(
      width: 250,
      height: 350,
      child: Card(
        elevation: 4,
        color: Colors.purple[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(weather.cityName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Lottie.asset(
                _getWeatherAnimation(weather, isDaytime),
                height: 100,
              ),
              Text('${weather.temperature.round()}°C', style: const TextStyle(fontSize: 18)),
              Text(weather.mainCondition),
              isDaytime ? const Text('Daytime') : const Text('Nighttime'),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeatherAnimation(Weather weather, bool isDaytime) {
    switch (weather.mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return isDaytime ? 'assets/sun.json' : 'assets/night.json';
      default:
        return isDaytime ? 'assets/sun.json' : 'assets/night.json';
    }
  }
}
