import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/drawer.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/services/api_key.dart';
import 'package:weather/weather.dart';

class ForcastPage extends StatefulWidget {
  const ForcastPage({super.key});

  @override
  State<ForcastPage> createState() => _ForcastPageState();
}

class _ForcastPageState extends State<ForcastPage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  List<Weather>? _forecast;
  Weather? _currentWeather;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    try {
      List<Weather> forecast =
          await _wf.fiveDayForecastByCityName("Cagayan de Oro");

      Weather currentWeather =
          await _wf.currentWeatherByCityName("Cagayan de Oro");

      setState(() {
        _forecast = forecast;
        _currentWeather = currentWeather;
      });
    } catch (e) {
      print("error fetching weather");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "8 days forecast",
          style: TextStyle(
              color: context.watch<UiProvider>().isDark
                  ? Colors.white
                  : Colors.black),
        ),
      ),
      drawer: const ComponentDrawer(),
      body: Consumer<UiProvider>(
        builder: (BuildContext context, UiProvider uiProvider, Widget? child) {
          return _build();
        },
      ),
    );
  }

  Widget _build() {
    if (_forecast == null || _currentWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _containerBox(),
          _forecastUi(),
        ],
      ),
    );
  }

  Widget _forecastUi() {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling of ListView inside SingleChildScrollView
      shrinkWrap: true,
      itemCount: _forecast!.length,
      itemBuilder: (context, index) {
        return _forecastItem(_forecast![index]);
      },
    );
  }

  Widget _forecastItem(Weather weather) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _dateTimeInfo(weather),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(flex: 1, child: _weatherIcon(weather)),
                Flexible(flex: 1, child: _currentTemp(weather)),
              ],
            ),
            const SizedBox(height: 10),
            _extraInfo(weather),
          ],
        ),
      ),
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
          style: TextStyle(
            color: context.watch<UiProvider>().isDark
                ? Colors.white
                : Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
        Text(
          DateFormat("h:mm a").format(localTime),
          style: TextStyle(
              color: context.watch<UiProvider>().isDark
                  ? Colors.white
                  : Colors.black,
              fontSize: MediaQuery.of(context).size.width * 0.035),
        )
      ],
    );
  }

  Widget _weatherIcon(Weather weather) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.1, // Responsive size
          width: MediaQuery.of(context).size.width * 0.1,
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
          style: TextStyle(
            color: context.watch<UiProvider>().isDark
                ? Colors.white
                : Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
      ],
    );
  }

  Widget _CurrentWeatherIcon(Weather weather) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "http://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png"),
                fit: BoxFit.cover),
          ),
        ),
        Text(weather.weatherDescription ?? '',
            style: TextStyle(
                color: context.watch<UiProvider>().isDark
                    ? Colors.white
                    : Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.035,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _currentTemp(Weather weather) {
    return Text(
      "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: TextStyle(
          color:
              context.watch<UiProvider>().isDark ? Colors.white : Colors.black,
          fontSize: MediaQuery.of(context).size.width * 0.08,
          fontWeight: FontWeight.w500),
    );
  }

  Widget _extraInfo(Weather weather) {
    return Text(
      "Humidity: ${weather.humidity?.toStringAsFixed(0)}%",
      style: TextStyle(
        color: context.watch<UiProvider>().isDark ? Colors.white : Colors.black,
        fontSize: MediaQuery.of(context).size.width * 0.04,
      ),
    );
  }

  Widget _currentWeatherUi() {
    return Column(
      children: [
        _locationHeader(),
        _CurrentWeatherIcon(_currentWeather!),
        _currentTemp(_currentWeather!),
        const SizedBox(height: 20),
        _extraInfo(_currentWeather!)
      ],
    );
  }

  Widget _locationHeader() {
    return Text(
      _currentWeather?.areaName ?? "Unkown",
      style: TextStyle(
          color:
              context.watch<UiProvider>().isDark ? Colors.white : Colors.black),
    );
  }

  Widget _containerBox() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2))]),
      child: _currentWeatherUi(),
    );
  }
}
