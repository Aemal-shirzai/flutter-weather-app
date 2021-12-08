import 'package:flutter/material.dart';
import 'package:hawa/components/customStore.dart';
import 'package:location/location.dart';
import 'package:hawa/components/flashMessage.dart' as flash_message;
import 'package:hawa/components/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

bool _serviceEnabled;
PermissionStatus _permissionGranted;

Future<bool> checkLocationAccess(context, prefs, location) async {
  bool res = await isPrefsDataAvailible(prefs);
  if(!res){
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        flash_message.showBasicsFlash(
          context: context,
          content: "The Application Needs to User Location For First Time.", 
          icon: Icon(
            Icons.gps_not_fixed_sharp,
            size: 40,
            color: Colors.white,
          ),
        );
        return false;
      }
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      flash_message.showBasicsFlash(
        context: context,
        content: "The Application Needs Permission for Location.", 
        icon: Icon(
          Icons.perm_device_information,
          size: 40,
          color: Colors.white,
        ),
      );
      return false;
    }
  }
  return true;
}


Future<dynamic> determineLocation(context, prefs, location, {searchBy: searchType.byGeo}) async{
  String searchQuery = '';
  Map jsonBody = {};
  
  if (searchBy == searchType.byGeo) {
    double lat;
    double lon;
    bool _locationAccess = await checkLocationAccess(context, prefs, location);
    if (_locationAccess == false) {
      return {'status': false};
    }
    bool res = await isPrefsDataAvailible(prefs);
    if(!res){
      LocationData _locationData = await location.getLocation();
      lat = _locationData.latitude;
      lon = _locationData.longitude;
    }else {
      Map _locationData = await getPrefsData(prefs);
      lat = _locationData['lat'];
      lon = _locationData['lon'];
    }
    await setPrefsData(prefs, {'lat': lat, 'lon': lon});
    searchQuery = 'lat=$lat&lon=$lon';
  } else {
    searchQuery = 'q=London';
  }
  
  try {
    http.Response response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?$searchQuery&appid=$KApiKey&units=metric")).timeout(Duration(seconds: 15));
    jsonBody = convert.jsonDecode(response.body);
  } catch(e) {
    flash_message.showBasicsFlash(
      context: context,
      content: "OOPS!. Could Not Load Data Please check You Have Proper Internet Connection.", 
      icon: Icon(
        Icons.signal_cellular_connected_no_internet_4_bar,
        size: 40,
        color: Colors.white,
      ),
    );
    return {'status': false};
  }
  jsonBody['status'] = true;
  return jsonBody;
  
}
  