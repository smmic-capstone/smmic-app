import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/services/api_key.dart';
import 'package:smmic/utils/logs.dart';
import 'package:weather/weather.dart';

class WeatherComponentsWidget extends StatefulWidget {
  const WeatherComponentsWidget({super.key});

  @override
  State<WeatherComponentsWidget> createState() =>
      _WeatherComponentsWidgetState();
}

class _WeatherComponentsWidgetState extends State<WeatherComponentsWidget> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  final Logs _logs = Logs(tag: 'WeatherWidget');
  
  Weather? _weather;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Weather>?> _getWeather() async {
    List<Weather>? weatherObj;
    try {
      weatherObj = await _wf.fiveDayForecastByCityName("Cagayan de Oro");
    } catch (e) {
      _logs.error(message: 'Unable to retrieve weather data -> $e');
    }
    return weatherObj;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Weather>?>(
        future: _getWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildRow(null);
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              // TODO: assign to provider
              return _buildRow(snapshot.data);
            }
          }
          return Text('cant get data????');
        }
    );
  }

  Widget _buildRow(List<Weather>? data) {
    List<(Temperature?, DateTime?, String?)> weatherSubList = data != null
        ? data.take(3).toList().map((weather) => (weather.temperature, weather.date, weather.weatherIcon)).toList()
        : List.generate(3, (_) => (Temperature(00.00), DateTime.now(), 'unavailable'));

    if (weatherSubList.length % 2 == 0) {
      throw Exception('Weather sublist has to be odd!');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...weatherSubList.indexed.map((tuple) => _buildReading(
            tuple.$2.$1?.celsius ?? 00.00,
            tuple.$2.$2 ?? DateTime.now(),
            tuple.$2.$3 ?? '',
            weatherSubList.length ~/ 2 == tuple.$1
                ? true
                : false)
        )
      ],
    );
  }

  Widget _buildReading(double? temperature, DateTime? timestamp, String iconId, bool isMiddle) {
    int hour = timestamp?.hour ?? DateTime.now().hour;
    String hourStr = '${hour % 12 == 0 ? 12 : hour % 12} ${hour >= 12 ? "PM" : "AM"}';

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(temperature ?? '??').toString().split('.').first.substring(0, 2)}°C',
            style: TextStyle(
              fontSize: isMiddle ? 22 : 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: Colors.white
            ),
          ),
          const SizedBox(height: 10),
          _generateIcon(
            sizeMultiplier: isMiddle ? 1.3 : null,
            iconId,
            context.watch<UiProvider>().isDark,
          ),
          const SizedBox(height: 10),
          Text(
            hourStr,
            style: TextStyle(
                fontSize: isMiddle ? 22 : 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Colors.white
            ),
          )
        ],
      ),
    );
  }

// takes the weather icon id from the weather data
// see https://openweathermap.org/weather-conditions for official docs
//
SvgPicture _generateIcon(String iconId, bool darkMode, {double? sizeMultiplier}) {
  String iconName = 'rain';
  double finalSize = 30;
  double sizeModifier =  sizeMultiplier ?? 1;

  // daytime colors
  // 0 dark mode, 1 light mode
  List<Color> dayTime = const [
    Color.fromRGBO(255, 232, 62, 1),
    Color.fromRGBO(255, 237, 38, 1),
  ];

  List<Color> nightTime = const [
    Color.fromRGBO(98, 245, 255, 1),
    Color.fromRGBO(47, 86, 161, 1.0)
  ];

  Color finalColor = Colors.black;

  // TODO: idea, make this a map for efficiency
  switch (iconId) {
    case '01d':
      iconName = 'clear_day';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '01n':
      iconName = 'clear_night';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '02d':
      iconName = 'few_clouds_day';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '02n':
      iconName = 'few_clouds_night';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '03d':
      iconName = 'cloudy';
      finalColor = dayTime[darkMode ? 0 : 1];
      finalSize = 25;
    case '03n':
      iconName = 'cloudy';
      finalColor = nightTime[darkMode ? 0 : 1];
      finalSize = 25;
    case '04d':
      iconName = 'clouds_broken';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '04n':
      iconName = 'clouds_broken';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '09d':
      iconName = 'shower_rain';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '09n':
      iconName = 'shower_rain';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '10d':
      iconName = 'rain';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '10n':
      iconName = 'rain';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '11d':
      iconName = 'thunderstorm';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '11n':
      iconName = 'thunderstorm';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '13d':
      iconName = 'snow';
      finalColor = dayTime[darkMode ? 0 : 1];
    case '13n':
      iconName = 'snow';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '50d':
      iconName = 'mist';
      finalColor = nightTime[darkMode ? 0 : 1];
    case '50n':
      iconName = 'mist';
      finalColor = nightTime[darkMode ? 0 : 1];
    default:
      iconName = 'disconnected';
      finalColor = const Color.fromRGBO(245, 245, 245, 1);
  }

  return SvgPicture.asset(
    'assets/icons/$iconName.svg',
    clipBehavior: Clip.antiAlias,
    colorFilter: ColorFilter.mode(
        finalColor,
        BlendMode.srcATop
    ),
    width: finalSize * sizeModifier,
    height: finalSize * sizeModifier,
  );}

  Widget _buildUi() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height:MediaQuery.of(context).size.height * 0.2,
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          _locationHeader(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _weatherIcon(),
              _currentTemp()
            ],
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
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black
      ),
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
      style: const TextStyle(color: Colors.black, fontSize: 15),
    );
  }
}