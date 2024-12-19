import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AppFunction/getXController.dart';
import 'package:flutter_app/AppFunction/global_variables.dart';
import 'package:flutter_app/model/pole.dart';

class PoleProvider extends ChangeNotifier {
  final List<PoleInfor> _poles = [];
  PoleInfor? _selectedPole;

  List<PoleInfor> getPoles() => _poles;

  void initializePoles() {
    _poles.add(PoleInfor(
        poleName: "Nema 02",
        poleId: "NEMA_0002",
        stationId: "AIR_0002",
        dimmingData: 0.0,
        isSwitch: false));
    _poles.add(PoleInfor(
        poleName: "Nema 03",
        poleId: "NEMA_0003",
        stationId: "AIR_0002",
        dimmingData: 0.0,
        isSwitch: false));
    _poles.add(PoleInfor(
        poleName: "Nema 04",
        poleId: "NEMA_0004",
        stationId: "AIR_0002",
        dimmingData: 0.0,
        isSwitch: false));
    _poles.add(PoleInfor(
      poleName: "Nema 05",
      poleId: "NEMA_0005",
      stationId: "AIR_0002",
      dimmingData: 0.0,
      isSwitch: false,
    ));
    _poles.add(PoleInfor(
        poleName: "Nema 06",
        poleId: "NEMA_0006",
        stationId: "AIR_0002",
        dimmingData: 0.0,
        isSwitch: false));

    _selectedPole = _poles.first;
  }

  bool isPolesEmpty() {
    return _poles.isEmpty;
  }

  PoleInfor getPoleAt(int index) {
    // if (_poles.length == 0) {
    //   return null;
    // }
    return _poles[index];
  }

  int getPolesListLength() {
    print(_poles.length);
    return _poles.length;
  }

  String getSelectedName() {
    return _selectedPole!.poleName;
  }

  PoleInfor getSelectedPole() {
    return _selectedPole!;
  }

  String getSelectedPoleID() {
    return _selectedPole!.poleId;
  }

  String getSelectedStationID() {
    return _selectedPole!.stationId;
  }

  double getSelectedDiming() {
    return _selectedPole!.dimmingData;
  }

  double getDimmingAt(int index) {
    return _poles[index].dimmingData;
  }

  bool getIsSwitchAt(int index) {
    return _poles[index].isSwitch;
  }

  bool getSelectedIsSwitch() {
    return _selectedPole!.isSwitch;
  }

  void setSelectedPoleName(String poleName) {
    _selectedPole?.poleName = poleName;
    notifyListeners();
  }

  void setSelectedStationID(String stationId) {
    _selectedPole?.stationId = stationId;
    notifyListeners();
  }

  void setSelectedPole(PoleInfor pole) {
    _selectedPole = pole;
    notifyListeners();
  }

  void setSelectedStation(String station) {
    _selectedPole?.stationId = station;
    notifyListeners();
  }

  void setSelectedDimming(double dimming) {
    if (dimming < 0.0) {
      dimming = 0.0;
    }
    if (dimming > 100.0) {
      dimming = 100.0;
    }
    if (dimming == 0.0) {
      _selectedPole?.isSwitch = false;
    } else {
      _selectedPole?.isSwitch = true;
    }
    _selectedPole?.dimmingData = dimming;
    notifyListeners();
  }

  void setDimmingOf(String poleName, double value) {
    PoleInfor? foundPole =
        _poles.firstWhereOrNull((pole) => pole.poleName == poleName);
    if (foundPole != null) {
      if (foundPole.dimmingData != value) {
        foundPole.dimmingData = value;
        foundPole.isSwitch = value == 0.0 ? false : true;
      }
    } else {
      print("Pole not found!");
    }
    notifyListeners();
  }

  void setDimmingOfDeviceId(String deviceId, double value) {
    PoleInfor? foundPole =
        _poles.firstWhereOrNull((pole) => pole.poleId == deviceId);
    if (foundPole != null) {
      foundPole.dimmingData = value;
      foundPole.isSwitch = value == 0.0 ? false : true;
    } else {
      print("Pole not found!");
    }
    notifyListeners();
  }

  void setSwitchStateOf(String switchName, bool value) {
    PoleInfor? foundPole =
        _poles.firstWhereOrNull((pole) => pole.poleName == switchName);
    if (foundPole != null) {
      if (foundPole.isSwitch != value) {
        foundPole.isSwitch = value;
        foundPole.dimmingData = value ? 50.0 : 0.0;
      }
    } else {
      print("Pole not found!");
    }
    notifyListeners();
  }

  void setToggleSwitchOf(String switchName) {
    PoleInfor? foundPole =
        _poles.firstWhereOrNull((pole) => pole.poleName == switchName);
    if (foundPole != null) {
      foundPole.isSwitch = !foundPole.isSwitch;
      foundPole.dimmingData = foundPole.isSwitch ? 50.0 : 0.0;
    } else {
      print("Pole not found!");
    }
    notifyListeners();
  }

  void setSelectedSwitch(bool switchState) {
    if (switchState) {
      _selectedPole?.dimmingData = 50.0;
      _selectedPole?.isSwitch = true;
    } else {
      _selectedPole?.dimmingData = 0.0;
      _selectedPole?.isSwitch = false;
    }
    notifyListeners();
  }

  void addPole(PoleInfor pole) {
    _poles.add(pole);
    notifyListeners();
  }

  void removePole(PoleInfor pole) {
    _poles.remove(pole);
    notifyListeners();
  }

  void publishControlSignalOf(String poleName) {
    PoleInfor? foundPole =
        _poles.firstWhereOrNull((pole) => pole.poleName == poleName);

    if (foundPole != null) {
      var message = jsonEncode(
        {
          "station_id": foundPole.stationId,
          "station_name": foundPole.stationId,
          "action": "control light",
          "device_id": foundPole.poleId,
          "data": {
            "from": "WEB_APP",
            "to": foundPole.poleId,
            "dimming": foundPole.dimmingData.toString(),
          }
        },
      );

      global_mqttHelper.publish(MQTT_TOPIC, message);
    } else {
      print("Pole is not found");
    }
  }

  void publishColtrolSignal() {
    var message = jsonEncode(
      {
        "station_id": "${getSelectedStationID()}",
        "station_name": "${getSelectedStationID()}",
        "action": "control light",
        "device_id": "${getSelectedPoleID()}",
        "data": {
          "from": "WEB_APP",
          "to": "${getSelectedPoleID()}",
          "dimming": "${getSelectedDiming()}",
        }
      },
    );

    global_mqttHelper.publish(MQTT_TOPIC, message);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
