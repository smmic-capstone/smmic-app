import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smmic/services/api_key.dart';
import 'package:weather/weather.dart';

class WeatherComponentsWidget extends StatefulWidget {
  const WeatherComponentsWidget({super.key});

  @override
  State<WeatherComponentsWidget> createState() =>
      _WeatherComponentsWidgetState();
}

class _WeatherComponentsWidgetState extends State<WeatherComponentsWidget> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _currentWeather;
  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    try {
      // Fetch current weather
      Weather currentWeather =
          await _wf.currentWeatherByCityName("Cagayan de Oro");

      setState(() {
        _currentWeather = currentWeather;
      });
    } catch (e) {
      print("Error fetching weather");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildUi();
  }

  Widget _buildUi() {
    if (_currentWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _locationHeader(),
          _currentWeatherUi(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(_currentWeather?.areaName ?? "Unknown location",
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black));
  }

  Widget _currentWeatherUi() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _weatherIcon(_currentWeather!),
            _currentTemp(_currentWeather!),
          ],
        ),
        const SizedBox(height: 10),
        _extraInfo(_currentWeather!)
      ],
    );
  }

  DateTime convertToLocalTime(DateTime utcTime, {int offsetInHours = 8}) {
    return utcTime.add(Duration(hours: offsetInHours));
  }

  Widget _dateTimeInfo(Weather weather) {
    DateTime utcTime = weather.date!;
    DateTime localTime = convertToLocalTime(utcTime, offsetInHours: 8);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat("EEEE, MMM d").format(localTime),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          DateFormat("h:mm a").format(localTime),
        )
      ],
    );
  }

  Widget _weatherIcon(Weather weather) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50, // Adjust size as needed
          width: 50, // Adjust size as needed
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "http://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          weather.weatherDescription ?? "",
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    );
  }

  Widget _currentTemp(Weather weather) {
    return Text(
      "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
          color: Colors.black, fontSize: 30, fontWeight: FontWeight.w500),
    );
  }

  Widget _extraInfo(Weather weather) {
    return Text(
      "Humidity: ${weather.humidity?.toStringAsFixed(0)}%",
      style: const TextStyle(color: Colors.black, fontSize: 15),
    );
  }
}
