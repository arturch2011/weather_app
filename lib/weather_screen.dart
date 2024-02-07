import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'hour_card.dart';
import 'info_item.dart';
import 'secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Cotia';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openKey'),
      );

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];

          final currentTempK = currentWeatherData['main']['temp'] - 273.15;
          final currentTemp = currentTempK.toStringAsFixed(2);
          final weatherMain = currentWeatherData['weather'][0]['main'];
          final pressureMain =
              currentWeatherData['main']['pressure'].toString();
          final speedMain = currentWeatherData['wind']['speed'].toString();
          final humidityMain =
              currentWeatherData['main']['humidity'].toString();

          IconData getWeatherIcon(String weatherData) {
            final mainWeather = weatherData;

            if (mainWeather == 'Clouds') {
              return Icons.cloud;
            } else if (mainWeather == 'Rain') {
              return Icons.cloud;
            } else if (mainWeather == 'Snow') {
              return Icons.cloudy_snowing;
            } else {
              return Icons.sunny;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              '$currentTemp °C',
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Icon(getWeatherIcon(weatherMain), size: 64),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(weatherMain, style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              //line cards

              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: 8,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final hourlyForecast = data['list'][index + 1];
                    final time = DateTime.parse(hourlyForecast['dt_txt']);
                    final hourlyTempC = hourlyForecast['main']['temp'] - 273.15;
                    return HourCard(
                      time: DateFormat.Hm().format(time),
                      icon:
                          getWeatherIcon(hourlyForecast['weather'][0]['main']),
                      temp: '${hourlyTempC.toStringAsFixed(0)} °C',
                    );
                  },
                ),
              ),
              //adition information
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoItem(
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      content: humidityMain),
                  InfoItem(
                      icon: Icons.air, title: 'Wind Speed', content: speedMain),
                  InfoItem(
                      icon: Icons.beach_access,
                      title: 'Pressure',
                      content: pressureMain),
                ],
              ),
            ]),
          );
        },
      ),
    );
  }
}
