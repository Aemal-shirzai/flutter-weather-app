import 'package:flutter/material.dart';
import 'package:hawa/components/customStore.dart';
import 'package:location/location.dart';
import 'package:hawa/components/flashMessage.dart';
import 'package:hawa/components/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class LocationManager {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  BuildContext context;
  FlashMessageManager flashController;
  PreferencesManager preferencesManager;
  Location location = Location();

  LocationManager({this.context, this.flashController, this.preferencesManager});

  Future<bool> checkLocationAccess() async {
    bool res = await this.preferencesManager.isLocationCachedDataAvailible();
    if(!res){
      _serviceEnabled = await this.location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await this.location.requestService();
        if (!_serviceEnabled) {
          flashController.showBasicsFlash(
            context: this.context,
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

    _permissionGranted = await this.location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await this.location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        flashController.showBasicsFlash(
          context: this.context,
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


  Future<dynamic> determineLocation({searchBy: searchType.byGeo, cityName: false}) async{
    String searchQuery = '';
    Map jsonBody = {};
    
    if (searchBy == searchType.byGeo) {
      double lat;
      double lon;
      bool _locationAccess = await checkLocationAccess();
      if (_locationAccess == false) {
        return {'status': false};
      }
      bool res = await this.preferencesManager.isLocationCachedDataAvailible();
      if(!res){
        LocationData _locationData = await this.location.getLocation();
        lat = _locationData.latitude;
        lon = _locationData.longitude;
      }else {
        Map _locationData = await this.preferencesManager.getLocationCachedData();
        lat = _locationData['lat'];
        lon = _locationData['lon'];
      }
      await this.preferencesManager.setLocationCachedData({'lat': lat, 'lon': lon});
      searchQuery = 'lat=$lat&lon=$lon';
    } else {
      searchQuery = 'q=$cityName';
    }

    
    try {
      http.Response response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?$searchQuery&appid=$KApiKey&units=metric")).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        jsonBody = convert.jsonDecode(response.body);
      } else if(response.statusCode == 404) {
        return {'status': false};
      } else {
        return {'status': false};
      }
    } catch(e) {
      flashController.showBasicsFlash(
        context: this.context,
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
}

  