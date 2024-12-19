import 'dart:convert';

bool isValidJson(String jsonString) {
  try {
    jsonDecode(jsonString); // Try to decode the string as JSON.
    return true; // If no error, it's a valid JSON.
  } on FormatException {
    return false; // If error, it's not a valid JSON.
  }
}

bool isValidStationInfoJson(String jsonString) {
  if (!isValidJson(jsonString))
    return false; // First, check if it's valid JSON.

  try {
    var json = jsonDecode(jsonString);
    // Check for necessary keys and types; you might need to adjust these checks based on your actual requirements.
    bool hasValidKeys = json is Map<String, dynamic> &&
        json.containsKey('station_id') &&
        json.containsKey('station_name') &&
        json.containsKey('action') &&
        json.containsKey('device_id') &&
        json.containsKey('data') &&
        json['data'] is Map<String, dynamic> &&
        json['data'].containsKey('from') &&
        json['data'].containsKey('to') &&
        json['data'].containsKey('dimming');

    return hasValidKeys;
  } catch (e) {
    return false; // In case of any other error during checks.
  }
}
