import 'package:flutter/material.dart';

import 'package:flutter_app/pages/home_page.dart';
import 'package:flutter_app/pages/light_control_page.dart';
import 'package:flutter_app/pages/lighting_schedule_page.dart';
import 'package:flutter_app/pages/security_cameras_page.dart';
import 'package:flutter_app/pages/advertisement_schedule_page.dart';
import 'package:flutter_app/pages/environmental_sensors_page.dart';
import 'package:flutter_app/pages/historical_data_page.dart';

class PageControllerProvider extends ChangeNotifier {
  int _selectedIndex = 1;
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const HomePage(),
    const LightControlPage(),
    const LightingSchedulePage(),
    const SecurityCamerasPage(),
    const AdvertisementSchedulePage(),
    const EnvironmentalSensorsPage(),
    const HistoricalDataPage(),
    const HomePage(),
  ];

  int get selectedIndex => _selectedIndex;
  List<Widget> get pages => _pages;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
