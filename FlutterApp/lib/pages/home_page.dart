import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để sử dụng SystemSound
import 'package:flutter_app/provider/pole_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Để sử dụng Provider
import 'dart:convert'; // Để encode dữ liệu JSON
import '../AppFunction/global_variables.dart';
import '../AppFunction/global_helper_function.dart'; // Để dùng getCurrentTimestamp()
import '../widgets/dropdown_button_widget.dart';
import '../provider/page_controller_provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Để sử dụng SVG
import 'package:flutter_app/model/pole.dart';
// import 'package:flutter_app/widgets/line_chart_temp_homepage.dart';
import 'package:flutter_app/widgets/temperature_line_chart.dart';
import '../AppFunction/mqtt_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _humidityValue = '80'; // Thông tin độ ẩm
  String _temperatureValue = '20'; // Thông tin nhiệt độ
  String _pm10 = '100'; // Thông tin hạt bụi mịn bán kính 10
  String _pm2_5 = '100';
  String _airPressure = "0";
  String _ambientLight = "0";
  String _noise = "0";

  String _selectedHistoryShow = "temperature";
  String _unitDataShow = "℃";

  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  late MqttManager mqttManager;

  @override
  void initState() {
    super.initState(); // Example method to load initial brightness data
    // Defer MQTT initialization until after the first frame
    // MqttManager(); // Now it's safe to use context

    listenForLastestDataAirSensor("temperature", "°C");
    listenForLastestDataAirSensor("humidity", "%");
    listenForLastestDataAirSensor("PM10", "μg/m³");
    listenForLastestDataAirSensor("PM2_5", "μg/m³");
    listenForLastestDataAirSensor("air_pressure", "Pa");
    listenForLastestDataAirSensor("ambient_light", "lux");
    listenForLastestDataAirSensor("noise", "dB");
  }

  // Future<void> _loadInitialBrightness() async {
  //   final provider = Provider.of<PoleProvider>(context, listen: false);
  //   String deviceID = provider.getSelectedPoleID();

  //   try {
  //     DatabaseEvent event = await global_databaseReference
  //         .child(deviceID)
  //         .child("Newest data")
  //         .once();

  //     if (event.snapshot.value != null && event.snapshot.value is Map) {
  //       final data = event.snapshot.value as Map<dynamic, dynamic>;
  //       provider.setSelectedDimming((data['brightness'] ?? 0).toDouble());
  //       print(
  //           'Initial brightness for $deviceID: ${provider.getSelectedDiming().toString()}');
  //     }
  //   } catch (e) {
  //     print('Failed to load initial brightness: $e');
  //   }
  // }

  // void _publishBrightness(double value, String deviceID) {
  //   final provider = Provider.of<PoleProvider>(context, listen: false);
  //   provider.setSelectedDimming(value);

  //   var message = jsonEncode({
  //     "station_id": "SmartPole_0002",
  //     "station_name": "Smart Pole 0002",
  //     "timestamp": getCurrentTimestamp(),
  //     "action": "control light",
  //     "device_id": deviceID,
  //     "data": value.round().toString()
  //   });

  //   // Gửi dữ liệu qua MQTT
  //   global_mqttHelper.publish(MQTT_TOPIC, message);

  //   // Cập nhật dữ liệu lên Firebase
  //   global_databaseReference.child(deviceID).child("Newest data").set({
  //     "brightness": value.round(),
  //     "timestamp": getCurrentTimestamp(),
  //   });
  // }

  void listenForLastestDataAirSensor(String dataName, String dataUnit) {
    final provider = Provider.of<PoleProvider>(context, listen: false);
    String deviceID = provider.getSelectedPoleID();
    String stationID = provider.getSelectedStationID();

    global_databaseReference
        .child(deviceID)
        .child(stationID)
        .child(dataName)
        .child(today)
        .orderByKey()
        .limitToLast(1)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> dataValue =
            event.snapshot.value as Map<dynamic, dynamic>;
        String latestKey = dataValue.keys.first;
        double latestValue = dataValue[latestKey];
        setState(() {
          if (dataName == 'temperature') {
            _temperatureValue = "$latestValue$dataUnit";
          } else if (dataName == 'humidity') {
            _humidityValue = "$latestValue$dataUnit";
          } else if (dataName == 'PM10') {
            _pm10 = "$latestValue $dataUnit";
          } else if (dataName == 'PM2_5') {
            _pm2_5 = "$latestValue $dataUnit";
          } else if (dataName == 'air_pressure') {
            _airPressure = "$latestValue $dataUnit";
          } else if (dataName == 'ambient_light') {
            _ambientLight = "$latestValue";
          } else if (dataName == 'noise') {
            _noise = "$latestValue $dataUnit";
          } else {
            print("Wrong data name");
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Phần bên trái - Hình ảnh và slider
                Expanded(
                  flex: 45,
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFE6E5F2), width: 1),
                      borderRadius: BorderRadius.circular(28),
                      color: const Color(0xFFFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.only(left: 40, bottom: 10),
                          child: const Text(
                            'SMART POLE DASHBOARD',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // Background Image
                              Positioned.fill(
                                child: Image.asset(
                                  'lib/assets/SmartPole_pic_with_arrow.png',
                                  height: 747,
                                ),
                              ),
                              // Slider
                              Positioned(
                                left: 70,
                                top: 335,
                                bottom: 0,
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.blue,
                                      inactiveTrackColor:
                                          const Color(0xFFF4EEF4),
                                      trackShape:
                                          const RoundedRectSliderTrackShape(),
                                      trackHeight: 45.0,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 25),
                                      overlayColor: Colors.blue.withAlpha(10),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 60),
                                    ),
                                    child: Consumer<PoleProvider>(
                                      builder: (context, polesList, child) {
                                        return Slider(
                                          value: polesList.getSelectedDiming(),
                                          min: 0,
                                          max: 100,
                                          onChanged: (value) {
                                            polesList.setSelectedDimming(value);
                                          },
                                          onChangeEnd: (value) {
                                            polesList.setSelectedDimming(value);
                                            // Need a MQTT send function
                                            polesList.publishColtrolSignal();
                                            // ====================================
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // Các nút
                              Positioned(
                                top: 0,
                                left: 70,
                                child: _buildChoosingPoleDropdownButton(),
                              ),
                              Positioned(
                                top: 0,
                                right: 110,
                                child: _buildButton("NEMA - ESP32", context,
                                    pageIndex: 2),
                              ),
                              Positioned(
                                top: 130,
                                left: 70,
                                child: _buildButton("CAMERA", context,
                                    pageIndex: 4),
                              ),
                              Positioned(
                                top: 130,
                                right: 110,
                                child: _buildButton("AIR SENSOR", context,
                                    pageIndex: 7),
                              ),
                              Positioned(
                                top: 335,
                                right: 110,
                                child: _buildButton("SCREEN", context,
                                    pageIndex: 5),
                              ),
                              Positioned(
                                top: 500,
                                right: 110,
                                child: _buildButton("CHARGER", context,
                                    pageIndex: 7),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Right part - Placeholder for additional UI
                Expanded(
                  flex: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE6E5F2), width: 1),
                      borderRadius: BorderRadius.circular(28),
                      color: Color(0xFFF5F5F5),
                    ),
                    padding: const EdgeInsets.only(left: 44, right: 31),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Physical information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight
                                          .w600, // Đặt fontWeight bên trong TextStyle
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      print('Refresh button pressed');
                                      //TODO: Refresh button pressed
                                    },
                                    icon: Image.asset(
                                        'lib/assets/icons/refresh_icon.png',
                                        height: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 18,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFFE6E5F2), width: 1),
                                      borderRadius: BorderRadius.circular(28),
                                      color: Color(0xFF3ACBE9),
                                    ),
                                    child: Consumer<PoleProvider>(
                                      builder: (context, polesList, child) {
                                        return buildSwitchPoleWidget(
                                          isOn: polesList
                                              .getSelectedIsSwitch(), // Initial state
                                          onToggle: (bool value) {
                                            // Handle the toggle logic here
                                            polesList.setSelectedSwitch(value);
                                            // Need a public to server MQTT
                                            polesList.publishColtrolSignal();
                                            // ==========================
                                            print(
                                                "Streetlight toggled: $value");
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFFE6E5F2), width: 1),
                                      borderRadius: BorderRadius.circular(28),
                                      color: Color(0xFFF2946D),
                                    ),
                                    child: buildEnvShowWidget(
                                      label: "Temperature",
                                      value: _temperatureValue,
                                      icon: Icons.thermostat,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFFE6E5F2), width: 1),
                                      borderRadius: BorderRadius.circular(28),
                                      color: Color(0xFF6F5CEA),
                                    ),
                                    child: buildEnvShowWidget(
                                      label: "Humidity",
                                      value: _humidityValue,
                                      icon: Icons.opacity,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          flex: 33,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE6E5F2), width: 1),
                              borderRadius: BorderRadius.circular(28),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // Align text
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Align the column vertically
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(50, 0, 40, 0),
                                  child: Text(
                                    'Air quality',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 80),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center, // Align text
                                            mainAxisAlignment: MainAxisAlignment
                                                .center, // Align the column vertically
                                            children: [
                                              buildEnvSensorInfo(
                                                  'lib/assets/svg/air-pressure.svg',
                                                  _airPressure,
                                                  'Air pressure'),
                                              buildEnvSensorInfo(
                                                  'lib/assets/svg/brightness.svg',
                                                  _ambientLight,
                                                  'Luminous'),
                                              buildEnvSensorInfo(
                                                  'lib/assets/svg/sound.svg',
                                                  _noise,
                                                  'Noise'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        width: 30,
                                        thickness: 5,
                                        color: Colors.black,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 80),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center, // Align text
                                            mainAxisAlignment: MainAxisAlignment
                                                .center, // Align the column vertically
                                            children: [
                                              buildAirQualityInfo(
                                                'lib/assets/svg/pm1_0.svg',
                                                '5 μg/m³',
                                              ),
                                              buildAirQualityInfo(
                                                'lib/assets/svg/pm2_5.svg',
                                                _pm2_5,
                                              ),
                                              buildAirQualityInfo(
                                                'lib/assets/svg/pm4_0.svg',
                                                '6 μg/m³',
                                              ),
                                              buildAirQualityInfo(
                                                'lib/assets/svg/pm10.svg',
                                                _pm10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'History graph',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight
                                          .w600, // Đặt fontWeight bên trong TextStyle
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: DropdownButtonWidget(
                                    label: "Temperature",
                                    onOptionSelected:
                                        handleHistoryChartSelection,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFE6E5F2), width: 1),
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xFFFFFFFF),
                            ),
                            child: Consumer<PoleProvider>(
                              builder: (context, polesList, child) {
                                return LineChartWidget(
                                  key: ValueKey(_selectedHistoryShow),
                                  deviceId: polesList.getSelectedPoleID(),
                                  stationId: polesList.getSelectedStationID(),
                                  sensorType: _selectedHistoryShow,
                                  unitData: _unitDataShow,
                                  color: Colors.redAccent,
                                ); // LineChart
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } // Widget build

  Widget buildSwitchPoleWidget({
    required bool isOn,
    required Function(bool) onToggle,
  }) =>
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'lib/assets/svg/lamp.svg',
                  width: 45,
                  height: 45,
                  // ignore: deprecated_member_use
                  color: Colors.white,
                ),
                SizedBox(width: 20),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isOn, // Pass the toggle state
                  onChanged: onToggle, // Callback for switch toggling
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.black54, // Color when ON
                  inactiveThumbColor: Colors.white70, // Color when OFF
                  inactiveTrackColor: Colors.grey, // Background when OFF
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                'Street light',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildEnvShowWidget({
    required String label,
    required String value,
    required IconData icon,
  }) =>
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 45,
                ),
                SizedBox(
                  width: 40,
                ),
                Text(
                  '$value',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildEnvSensorInfo(
    String iconPath,
    String value,
    String label,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 140,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Align text
                mainAxisAlignment:
                    MainAxisAlignment.center, // Align the column vertically
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    color: Colors.black,
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ), // Column
            ), // Sized Box
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ), // Row
      );

  Widget buildAirQualityInfo(
    String svgPath,
    String value,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 40,
              height: 40,
              // color: Colors.black,
            ),
            SizedBox(
              width: 30,
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  void handleHistoryChartSelection(String newSelection) {
    setState(() {
      if (newSelection == "Temperature") {
        _selectedHistoryShow = "temperature";
        _unitDataShow = "℃";
      } else if (newSelection == "Humidity") {
        _selectedHistoryShow = "humidity";
        _unitDataShow = "%";
      } else if (newSelection == "Luminous") {
        _selectedHistoryShow = "ambient_light";
        _unitDataShow = "";
      }
    });
  }

  Widget _buildChoosingPoleDropdownButton() {
    return Consumer<PoleProvider>(
      builder: (context, polesInfor, child) {
        return Container(
          width: 150,
          height: 53,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFEDEEF4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<PoleInfor>(
            value: polesInfor.getSelectedPole(),
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: const SizedBox(),
            isExpanded: true,
            items: polesInfor
                .getPoles()
                .map<DropdownMenuItem<PoleInfor>>((PoleInfor pole) {
              return DropdownMenuItem<PoleInfor>(
                value: pole,
                child: Text(
                  pole.poleName,
                  style: TextStyle(
                    color: PRIMARY_BLACK_COLOR,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            onChanged: (PoleInfor? newValue) {
              polesInfor.setSelectedPole(newValue!);
            },
          ),
        );
      },
    );
  }

  // Nút bấm
  Widget _buildButton(String label, BuildContext context, {int pageIndex = 1}) {
    return Consumer<PageControllerProvider>(
      builder: (context, pageControllerProvider, child) {
        return SizedBox(
          width: 201,
          height: 53,
          child: ElevatedButton(
            onPressed: () {
              pageControllerProvider.setIndex(pageIndex);
              pageControllerProvider.pages
                  .elementAt(pageControllerProvider.selectedIndex);
              print('$label button pressed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9D9D9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: PRIMARY_BLACK_COLOR,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  } // build
}
