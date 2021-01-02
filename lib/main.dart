import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var styles=GoogleFonts.ubuntu(
    fontSize: 17,
    color: Colors.black.withOpacity(0.5),
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  Widget body() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Abhishek Bapu Ove",style: styles,),
        ),
        FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "lat:${snapshot.data.latitude.toString()},long:${snapshot.data.longitude.toString()}",
                        overflow: TextOverflow.ellipsis,
                        style: styles,
                      ),
                    ),
                    FutureBuilder(
                      builder:
                          (BuildContext context, AsyncSnapshot<Temp> snapshot) {
                        if (snapshot.hasData)
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Current Temperature is ${snapshot.data.currentTemp}",
                                  overflow: TextOverflow.ellipsis,
                                  style: styles,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Temperature after one hour will be ${snapshot.data.nextHourTemp}",
                                  overflow: TextOverflow.ellipsis,
                                  style: styles,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Temperature after one day will be ${snapshot.data.nextDayTemp}",
                                  overflow: TextOverflow.ellipsis,
                                  style: styles,
                                ),
                              ),
                            ],
                          );
                        return CircularProgressIndicator();
                      },
                      future: fetchTemperature(snapshot.data.latitude.toString(),
                          snapshot.data.longitude.toString()),
                    )
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
          future: _determinePosition(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("S4S Test"),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          body(),
        ],
      ),
    );
  }
}

class Temp {
  final String currentTemp, nextHourTemp, nextDayTemp;

  Temp({this.currentTemp, this.nextHourTemp, this.nextDayTemp});

  factory Temp.fromJson(Map<String, dynamic> json) {
    return Temp(
      currentTemp: json['current']['temp'].toString(),
      nextHourTemp: json['hourly'][1]['temp'].toString(),
      nextDayTemp: json['daily'][1]['temp']['day'].toString(),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permantly denied, we cannot request permissions.');
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error(
          'Location permissions are denied (actual value: $permission).');
    }
  }

  return await Geolocator.getCurrentPosition();
}

Future<Temp> fetchTemperature(String lat, String long) async {
  final response = await http.get(
      'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$long&appid=df1e864e1422bd31a181524824d17711&units=metric');
  if (response.statusCode == 200)
    return Temp.fromJson(jsonDecode(response.body));
  else
    throw Exception('Failed to load album');
}
