import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSliderWidget extends StatefulWidget {
  final double initialSliderValue;
  final Function(double) onSliderValueChanged;
  final Function(double)
      onSliderValueChangedEnd; // To handle slider value end change
  final Function() onSwitchValueToggle; // To handle switch value change
  final String deviceName; // To display device name dynamically
  final Color activeTrackColor; // To set slider active track color dynamically

  const CustomSliderWidget({
    super.key,
    this.initialSliderValue = 0,
    required this.onSliderValueChanged,
    required this.onSliderValueChangedEnd,
    required this.onSwitchValueToggle,
    this.deviceName = "Light Brightness", // Default device name
    this.activeTrackColor = Colors.blue, // Default color for active track
  });

  @override
  _CustomSliderWidgetState createState() => _CustomSliderWidgetState();
}

class _CustomSliderWidgetState extends State<CustomSliderWidget> {
  late double _currentSliderValue;
  late bool _isSwitched;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialSliderValue;
    _isSwitched = _currentSliderValue > 0;
  }

  void _updateSliderValue(double value) {
    setState(() {
      _currentSliderValue = value;
      _isSwitched = value > 0; // Update the switch state based on slider value
      print("Slider Value Updated: $_currentSliderValue");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          Text(
            widget.deviceName,
            style: const TextStyle(
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _isSwitched ? '${_currentSliderValue.round()}%' : 'Off',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _isSwitched ? Colors.black : Colors.grey,
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: widget.activeTrackColor,
                  inactiveTrackColor: const Color(0xFFF4EEF4),
                  trackShape: const RoundedRectSliderTrackShape(),
                  trackHeight: 70.0,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 35),
                  overlayColor: Colors.blue.withAlpha(10),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 60),
                ),
                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    _updateSliderValue(value);
                    widget.onSliderValueChanged(value);
                  },
                  onChangeEnd: widget.onSliderValueChangedEnd,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          IconButton(
            icon: Icon(
              Icons.power_settings_new,
              color: _isSwitched
                  ? widget.activeTrackColor
                  : const Color(0xFFF4EEF4),
              size: 90.0,
            ),
            onPressed: () {
              setState(() {
                _isSwitched = !_isSwitched; // Toggle the state of the switch
                _currentSliderValue = _isSwitched
                    ? _currentSliderValue
                    : 0; // Set slider to 0 if switched off
              });
              widget.onSwitchValueToggle();
            },
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
