import 'dart:async';
import 'dart:math';

import 'package:compass/screens/info_screen.dart';
import 'package:compass/widgets/compass_letters_painter.dart';
import 'package:compass/widgets/compass_ticks_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  StreamSubscription<Position>? _locationStream;
  final LocationSettings _locationSettings = const LocationSettings(
      distanceFilter: 1, accuracy: LocationAccuracy.best);
  StreamSubscription<CompassEvent>? _compassStream;
  int _currentHeading = 0;
  int _currentAltitude = 0;
  double _currentLatitude = 0;
  double _currentLongitude = 0;
  double _accuracy = 0;

  // function to convert degrees to radians
  double degreesToRadians(double degrees) {
    double radians = degrees * pi / 180;
    return radians;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setupCompass();
    super.initState();
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_locationStream == null || _compassStream == null) {
          setupCompass();
        } else {
          await Permission.locationWhenInUse.status.then((value) {
            if (value.isGranted) {
              _locationStream?.resume();
              _compassStream?.resume();
            } else {
              setupCompass();
            }
          });
        }

        break;

      case AppLifecycleState.paused:
        _locationStream?.pause();
        _compassStream?.pause();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void setupCompass() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      // Gives Altitude and Positioning
      _locationStream = _locationStream ??
          Geolocator.getPositionStream(locationSettings: _locationSettings)
              .listen((Position position) {
            setState(() {
              _currentAltitude = position.altitude.toInt();
              _currentLatitude =
                  kDebugMode ? 26.357891974667538 : position.latitude;
              _currentLongitude =
                  kDebugMode ? 127.78374690360789 : position.longitude;
              _accuracy = position.accuracy;
            });
          });

      // Gives Compass Heading
      _compassStream = _compassStream ??
          FlutterCompass.events?.listen((CompassEvent event) {
            setState(() {
              _currentHeading = event.heading?.toInt() ?? 0;
            });
          });
    }
  }

  //  get compass direction from degrees
  String getDirectionFromDegrees(double degrees) {
    List<String> directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];
    int index = ((degrees + 22.5) / 45).floor();
    return directions[index];
  }

  // convert decimal degrees to degrees minutes seconds
  String convertToDMS(double input, bool isLat) {
    double degrees = input.floorToDouble();
    double minutesNotTruncated = (input - degrees) * 60;
    double minutes = minutesNotTruncated.floorToDouble();
    double seconds = ((minutesNotTruncated - minutes) * 60).floorToDouble();
    return "${degrees.toInt().abs()}°${minutes.toInt()}'${seconds.toInt()}'' ${isLat ? (degrees < 0 ? "S" : "N") : (degrees < 0 ? "W" : "E")}";
  }

  // convert m to ft
  int metersToFeet(double meters) {
    return (meters * 3.28084).toInt();
  }

  @override
  Widget build(BuildContext context) {
    var bottomTextStyle =
        const TextStyle(fontWeight: FontWeight.w300, fontSize: 24);
    var degreesTextStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.black,
      fontSize: 50,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(fit: StackFit.expand, children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 1),
                        turns: -_currentHeading / 360,
                        child: CustomPaint(
                          painter: CompassTicksPainter(),
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 10),
                        turns: -_currentHeading / 360,
                        child: CustomPaint(
                          painter: CompassLettersPainter(),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _currentHeading.toString(),
                                textAlign: TextAlign.end,
                                style: degreesTextStyle,
                              ),
                            ),
                            Text(
                              '°',
                              style: degreesTextStyle,
                            ),
                            Expanded(
                              child: Text(
                                getDirectionFromDegrees(
                                    _currentHeading.toDouble()),
                                style: degreesTextStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        convertToDMS(_currentLatitude, true).toString(),
                        textAlign: TextAlign.end,
                        style: bottomTextStyle,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        convertToDMS(_currentLongitude, false).toString(),
                        style: bottomTextStyle,
                      ),
                    )
                  ],
                ),
                Text(
                  '${_currentAltitude.toString()}m Elevation',
                  style: bottomTextStyle,
                ),
                Text(
                  '${_accuracy.toInt()}m Accuracy',
                  style: bottomTextStyle,
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => InfoScreen(),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
