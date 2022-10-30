import 'dart:async';
import 'dart:math';

import 'package:compass/widgets/compass_dial_painter.dart';
import 'package:compass/widgets/compass_letters_painter.dart';
import 'package:compass/widgets/compass_ticks_painter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionStream;
  LocationSettings _locationSettings =
      LocationSettings(distanceFilter: 1, accuracy: LocationAccuracy.best);
  int _currentHeading = 0;
  String _currentPostition = '';

  // function to convert degrees to radians
  double degreesToRadians(double degrees) {
    double radians = degrees * pi / 180;
    return radians;
  }

  @override
  void initState() {
    setupCompass();
    super.initState();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (_positionStream == null) {
          setupCompass();
        } else {
          _positionStream?.resume();
        }

        break;

      case AppLifecycleState.paused:
        _positionStream?.pause();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void setupCompass() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      _positionStream =
          Geolocator.getPositionStream().listen((Position position) {
        print(position);
        setState(() {
          _currentHeading = position.heading!.toInt();
          _currentPostition =
              'Lat: ${position.latitude}, Long: ${position.longitude}';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                CustomPaint(
                  painter: CompassTicksPainter(),
                ),
                CustomPaint(
                  painter: CompassLettersPainter(),
                ),
                AnimatedRotation(
                  duration: Duration(milliseconds: 10),
                  turns: _currentHeading / 360,
                  child: CustomPaint(
                    painter: CompassDialPainter(),
                  ),
                ),
              ]),
            ),
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentHeading.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 50,
                    ),
                  ),
                  Center(
                    child: Text(
                      '°',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                _currentPostition,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
