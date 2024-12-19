import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/historical_line_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/provider/pole_provider.dart';
import 'package:provider/provider.dart';

class HistoricalDataPage extends StatefulWidget {
  const HistoricalDataPage({super.key});

  @override
  _HistoricalDataPageState createState() => _HistoricalDataPageState();
}

class _HistoricalDataPageState extends State<HistoricalDataPage> {
  DateTime _lineChartDate = DateTime.now();
  String _lineChartData = 'Air pressure';
  String _fireChild = 'air_pressure';
  String _unitDataShow = 'Pa';

  List<String> dropdownOptions = [
    'Air pressure',
    'Brightness',
    'Humidity',
    'Noise',
    'Temperature',
    'PM10',
    'PM2.5',
  ];

  void handleLineChartInfor(String lineChartData) {
    if (lineChartData == 'Air pressure') {
      setState(() {
        _fireChild = 'air_pressure';
        _unitDataShow = 'Pa';
      });
    } else if (lineChartData == 'Brightness') {
      setState(() {
        _fireChild = 'ambient_light';
        _unitDataShow = 'Lux';
      });
    } else if (lineChartData == 'Humidity') {
      setState(() {
        _fireChild = 'humidity';
        _unitDataShow = '%';
      });
    } else if (lineChartData == 'Noise') {
      setState(() {
        _fireChild = 'noise';
        _unitDataShow = 'dB';
      });
    } else if (lineChartData == 'Temperature') {
      setState(() {
        _fireChild = 'temperature';
        _unitDataShow = '℃';
      });
    } else if (lineChartData == 'PM10') {
      setState(() {
        _fireChild = 'PM10';
        _unitDataShow = 'µg/m3';
      });
    } else if (lineChartData == 'PM2.5') {
      setState(() {
        _fireChild = 'PM2_5';
        _unitDataShow = 'µg/m3';
      });
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lineChartDate,
      firstDate: DateTime(2024, 12, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lineChartDate) {
      setState(() {
        _lineChartDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historical data',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            color: Colors.white,
            onPressed: _pickDate,
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            height: 36,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFEDEEF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _lineChartData,
              icon: const Icon(Icons.arrow_circle_down),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                setState(() {
                  _lineChartData = newValue!;
                  handleLineChartInfor(newValue);
                });
              },
              items:
                  dropdownOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: 30,
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE6E5F2), width: 1),
            borderRadius: BorderRadius.circular(14),
            color: Color(0xFFFFFFFF),
          ),
          child: Consumer<PoleProvider>(
            builder: (context, polesList, child) {
              return HistoricalLineChartWidget(
                key: ValueKey([_lineChartData, _lineChartDate]),
                deviceId: polesList.getSelectedPoleID(),
                stationId: polesList.getSelectedStationID(),
                sensorType: _fireChild,
                unitData: _unitDataShow,
                color: Colors.redAccent,
                date: DateFormat('yyyy-MM-dd').format(_lineChartDate),
              );
            },
          ),
        ),
      ),
    );
  }
}
