import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/drawer.dart';
import 'package:smmic/components/grid/gridbox.dart';
import 'package:smmic/models/weather_models.dart';
import 'package:smmic/provide/provide.dart';
import 'package:smmic/services/weather_service.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  //apikey
  final _weatherService = WeatherService('87a2c9524ad0fc56ed05b7132b780f41');
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    // get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }

    // any errors
    catch (e) {
      print(e);
    }
  }

  //weather animation

  //init state
  @override
  void initState() {
    super.initState();

    //fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DASHBOARD',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ComponentDrawer(),
      body: Consumer<UiProvider>(
        builder: (BuildContext context, UiProvider uiProvider, Widget? child) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  height: 150,
                  width: 350,
                  decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage('assets/background2.jpg'),
                          fit: BoxFit.cover),
                      color: uiProvider.isDark ? Colors.black12 : Colors.white,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 6))
                      ]),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //city name
                        Text(_weather?.cityName ?? "Loading.."),

                        // temperature
                        Text('${_weather?.temperature.round()}∘C')
                      ],
                    ),
                  ),
                ),
              ),
              const MyGridBox()
            ],
          );
        },
      ),
    );
  }
}
