// import 'package:flutter/material.dart';

// List<String> poles = [
//   'NEMA_0002',
//   'NEMA_0003',
//   'NEMA_0004',
//   'NEMA_0005',
//   'NEMA_0006',
// ];

List<double> dimmingData = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
];

List<String> stations = [
  'AIR_0002',
  'AIR_0003',
];

class PoleInfor {
  String poleName;
  String poleId;
  String stationId;
  double dimmingData;
  bool isSwitch;

  PoleInfor({
    required this.poleName,
    required this.poleId,
    this.stationId = "AIR_0002",
    required this.dimmingData,
    required this.isSwitch,
  });

  void displayInfor() {
    print(
        "PoleID = $poleId, Stration ID = $stationId, Dimming Data = $dimmingData");
  }
}
