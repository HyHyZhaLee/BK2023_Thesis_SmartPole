import 'dart:convert';

import 'package:flutter_app/AppFunction/global_helper_function.dart';
import 'mqtt_helper.dart';
import 'global_variables.dart';
import 'package:flutter_app/provider/pole_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/AppFunction/json_helper.dart';

class MqttManager {
  /* MQTT information:
    MQTT_PORT_FOR_ANDROID = 1883
    MQTT_PORT_FOR_WEB = 8084
    MQTT_SERVER = "mqtt.ohstem.vn"
    MQTT_USERNAME = "BK_SmartPole"
    MQTT_PASSWORD = " "
    MQTT_TOPIC = "BK_SmartPole/feeds/V20"
 */

  MqttManager() {
    String randomClientId =
        "Smartpole_0002_${DateTime.now().millisecondsSinceEpoch}";
    global_mqttHelper =
        MQTTHelper(MQTT_SERVER, randomClientId, MQTT_USERNAME, MQTT_PASSWORD);
    global_mqttHelper.onConnectedCallback = () {
      print("MQTT Connected");
      global_mqttHelper.subscribe(MQTT_TOPIC, _handleReceivedMessage);
    };
    global_mqttHelper.initializeMQTTClient();
  }

  void _handleReceivedMessage(String topic, dynamic message) {
    print("Received message on topic $topic: $message");

    try {
      // Decode the message
      final decodedMessage = json.decode(message);
      print("Decoded message: $decodedMessage");

      // Update the provider using the global context
      BuildContext? context = GlobalHelper.getContext();
      if (context != null) {
        if (isValidStationInfoJson(message)) {
          final poleProvider =
              Provider.of<PoleProvider>(context, listen: false);
          if (decodedMessage['action'] == "control light") {
            Map<String, dynamic> data = decodedMessage['data'];
            poleProvider.setDimmingOfDeviceId(
                data['to'], double.parse(data['dimming']));
          }
        }
        // poleProvider.updatePoleData(decodedMessage);
      } else {
        print("Context is null, unable to update provider.");
      }
    } catch (e) {
      print("Error decoding message: $e");
    }
  }
}
