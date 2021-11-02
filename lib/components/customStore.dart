import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setPrefsData(prefs ,data) async {
  final SharedPreferences prefsObj = await prefs;
  prefsObj.setDouble('lat', data['lat']);
  prefsObj.setDouble('lon', data['lon']);
}
Future<Map> getPrefsData(prefs) async {
  final SharedPreferences prefsObj = await prefs;
  return {
    "lat": prefsObj.getDouble('lat'),
    "lon": prefsObj.getDouble('lon')
  };
}
Future<bool> isPrefsDataAvailible(prefs) async {
  final SharedPreferences prefsObj = await prefs;
  if (prefsObj.getDouble('lat') == null || prefsObj.getDouble('lon') == null){
    return false;
  }
  return true;
}
Future<void> clearPref(prefs) async {
  final SharedPreferences prefsObj = await prefs;
  await prefsObj.clear();
}