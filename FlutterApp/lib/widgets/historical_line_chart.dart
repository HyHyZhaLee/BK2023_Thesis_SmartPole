import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../AppFunction/global_variables.dart';

class HistoricalLineChartWidget extends StatefulWidget {
  final String deviceId;
  final String stationId;
  final String sensorType;
  final String unitData;
  final Color color;
  final String date;

  HistoricalLineChartWidget({
    Key? key,
    required this.deviceId,
    required this.stationId,
    required this.sensorType,
    required this.unitData,
    Color? color,
    String? date,
  })  : color = color ?? Colors.redAccent, // Correct default assignment
        date = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        super(key: key);

  @override
  _HistoricalLineChartWidgetState createState() =>
      _HistoricalLineChartWidgetState();
}

class _HistoricalLineChartWidgetState extends State<HistoricalLineChartWidget> {
  List<FlSpot> _spots = [];
  double? _minValue;
  double? _maxValue;

  @override
  void initState() {
    super.initState();

    global_databaseReference
        .child(widget.deviceId != "NEMA_0002" ? "NEMA_0002" : "NEMA_0002")
        .child(widget.stationId)
        .child(widget.sensorType)
        .child(widget.date)
        .orderByKey()
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final dataMap = Map<String, double>.from(event.snapshot.value as Map);
        List<FlSpot> spots = [];
        double minValue = dataMap.entries.first.value;
        double maxValue = dataMap.entries.first.value;
        dataMap.forEach((key, value) {
          minValue = minValue > value ? value : minValue;
          maxValue = maxValue < value ? value : maxValue;
          // Convert time string (HH:mm:ss) to minutes since midnight
          spots.add(FlSpot(_convertTimeToFloat(key), value));
        });
        setState(() {
          _spots = spots; // Ensure the spots are ordered by time
          _minValue = minValue - 5.0;
          _maxValue = maxValue + 5.0;
        });
      }
    });
  }

  double _convertTimeToFloat(String time) {
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return hours * 60.0 +
        minutes +
        seconds / 60.0; // Convert time to total minutes
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      child: Container(
        height: 700,
        width: 1600, // Set a fixed width for the container that holds the chart
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          child: LineChart(
            LineChartData(
              minY: _minValue,
              maxY: _maxValue,
              lineTouchData: LineTouchData(
                touchTooltipData:
                    LineTouchTooltipData(getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y}', // Display y value
                      TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold), // Customize text style here
                    );
                  }).toList();
                }),
              ),
              gridData: FlGridData(
                show: false,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1.0,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1.0,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 10, // Show label every 5 intervals
                    getTitlesWidget: (value, meta) {
                      // Convert minutes since midnight back to time format
                      int totalMinutes = value.toInt();
                      int hours = totalMinutes ~/ 60;
                      int minutes = totalMinutes % 60;
                      // Show label only at specific minute marks each hour
                      if (minutes == 0 || minutes == 30) {
                        // Adjust these values for your specific needs
                        String formattedTime =
                            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
                        return Text(formattedTime,
                            style:
                                TextStyle(color: Colors.black, fontSize: 10));
                      }
                      return Text(
                          ''); // Return an empty Text widget for other minutes
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '${value.toInt()} ${widget.unitData}', // Append '°C' to the y-value
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _spots,
                  isCurved: false,
                  color: widget.color, // Line color
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true, // Set to true if you want to show dots
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 1, // Dot size
                        color: widget.color, // Dot color
                        strokeWidth: 0, // No border
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: widget.color.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
