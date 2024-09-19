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

  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    try {
      Weather w = await _wf.currentWeatherByCityName("Cagayan de Oro");
      setState(() {
        _weather = w;
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
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height:
            MediaQuery.of(context).size.height * 0.2, // Adjust height as needed
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          _locationHeader(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_weatherIcon(), _currentTemp()],
          ),
          const SizedBox(
            height: 10,
          ),
          _extraInfo()
        ]));
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "Unknown location",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              " ${DateFormat("M/d/y").format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30, // Adjust size as needed
          width: 50, // Adjust size as needed
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
          color: Colors.black, fontSize: 30, fontWeight: FontWeight.w500),
    );
  }

  Widget _extraInfo() {
    return Text(
      "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
      style: const TextStyle(color: Colors.white, fontSize: 15),
    );
  }
}
