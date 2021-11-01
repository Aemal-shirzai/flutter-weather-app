import 'dart:ui';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawa/screens/search.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flash/flash.dart';
class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // location and permission
  final apiKey = "f7c1edb5ebe2f20e207df9df6eab5fa2";
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  double lat;
  double lon;
  Map weatherData = {
    "countryName": "",
    "cityName" : '',
    "cityTemprature": '',
    "description": '',
    "humidity": '',
    "tempMin": '',
    "tempMax": '',
  };
  bool isDataAvailible = false;
  bool isError = false;
  FlashController<dynamic> currentSnackBar;


  Future<bool> _checkLocationAccess() async {

    bool res = await _isPrefsDataAvailible();
    if(!res){
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          setState(() {
            isError = true;
          });
          _showBasicsFlash(
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
        setState(() {
          isError = true;
        });
        _showBasicsFlash(
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

  Future<void> _determineLocation() async{

    setState(() {
      isDataAvailible = false;
      isError = false;
      if (currentSnackBar != null) {
        currentSnackBar.dismiss();
      }
    });
    bool _locationAccess = await _checkLocationAccess();
    if (_locationAccess == false) {
      return null;
    }

    bool res = await _isPrefsDataAvailible();
    if(!res){
      LocationData _locationData = await location.getLocation();
      lat = _locationData.latitude;
      lon = _locationData.longitude;
    }else {
      Map _locationData = await _getPrefsData();
      lat = _locationData['lat'];
      lon = _locationData['lon'];
    }
    await _setPrefsData();
    http.Response response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric"));
    Map jsonBody = convert.jsonDecode(response.body);
    setState(() {
      weatherData["cityName"] = jsonBody['name'];
      weatherData["countryName"] = jsonBody['sys']["country"];
      weatherData["cityTemprature"] = jsonBody['main']['temp'].round().toString();  
      weatherData["description"] = jsonBody["weather"][0]["description"];
      weatherData["humidity"] = jsonBody["main"]["humidity"].toString();
      weatherData["tempMin"] = jsonBody['main']['temp_min'].round().toString();
      weatherData["tempMax"] = jsonBody['main']['temp_max'].round().toString();
      isDataAvailible = true;
      isError = false;
    });
  
  }
  
  // Shared Prefrences
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<void> _setPrefsData() async {
    final SharedPreferences prefsObj = await _prefs;
    prefsObj.setDouble('lat', lat);
    prefsObj.setDouble('lon', lon);
  }
  Future<Map> _getPrefsData() async {
    final SharedPreferences prefsObj = await _prefs;
    return {
      "lat": prefsObj.getDouble('lat'),
      "lon": prefsObj.getDouble('lon')
    };
  }
  Future<bool> _isPrefsDataAvailible() async {
    final SharedPreferences prefsObj = await _prefs;
    if (prefsObj.getDouble('lat') == null || prefsObj.getDouble('lon') == null){
      return false;
    }
    return true;
  }
  Future<void> _clearPref() async {
    final SharedPreferences prefsObj = await _prefs;
    await prefsObj.clear();
  }
  
  void _showBasicsFlash({
    Duration duration,
    flashStyle = FlashBehavior.fixed,
    String content,
    Icon icon
  }) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        currentSnackBar = controller;
        return Flash(
          controller: controller,
          margin: EdgeInsets.only(top: 25, left: 12, right: 12),
          backgroundColor: Colors.lightBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          enableVerticalDrag: false,
          behavior: flashStyle,
          position: FlashPosition.top,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            icon: icon,
            content: Container(
              child: Text(
                content,
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _determineLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/04.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: isDataAvailible && !isError,
                child: Expanded(
                  child: Column(
                    children: [    
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    color: Colors.grey.withOpacity(0.2),
                                    padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top:12),
                                    child: Text(
                                      weatherData["cityName"] + "-" + weatherData["countryName"],
                                      style: Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                  Container(
                                    child: RichText(
                                        text: TextSpan(
                                          text: weatherData["cityTemprature"],
                                          style: Theme.of(context).textTheme.headline1,
                                          children: const <TextSpan>[
                                            TextSpan(
                                              text: '\u00B0', 
                                              style: TextStyle(
                                                fontWeight:  FontWeight.normal,
                                                fontSize: 100,
                                                fontFeatures: [
                                                  FontFeature.enable('sups')
                                                ],
                                              ),
                                            ),
                                           
                                        
                                          ],
                                        ),
                                      ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(top: 30, right: 10),
                                color: Colors.grey.withOpacity(0.2),
                                child: RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                     weatherData["description"],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: IconButton(
                                  tooltip: "Current Location",
                                  icon: Icon(FontAwesomeIcons.locationArrow),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () async {
                                    await _determineLocation();
                                  },
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  tooltip: "Clear Prefrences",
                                  icon: Icon(FontAwesomeIcons.trashRestoreAlt),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () async {
                                    await _clearPref(); 
                                  },
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  tooltip: "Search Locations",
                                  icon: Icon(FontAwesomeIcons.search),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return SearchScreen();
                                      }),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          width: double.infinity,
                          margin: EdgeInsets.all(15),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: IntrinsicHeight (
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weatherData["humidity"] + "%",
                                          style: Theme.of(context).textTheme.headline5,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Humidity",
                                          style: Theme.of(context).textTheme.headline6,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 0.5,
                                  width: 10,
                                  color: Colors.white,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weatherData["tempMin"] + " \u00B0",
                                          style: Theme.of(context).textTheme.headline5,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Min Temp",
                                          style: Theme.of(context).textTheme.headline6,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 0.5,
                                  width: 10,
                                  color: Colors.white,
                                  
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weatherData["tempMax"] + " \u00B0",
                                          style: Theme.of(context).textTheme.headline5,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Max Temp",
                                          style: Theme.of(context).textTheme.headline6,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !isDataAvailible && !isError,
                child: Container(
                  width: 100,
                  child: LoadingIndicator(
                    colors: [Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.indigo,
                      Colors.purple,],
                    indicatorType: Indicator.ballTrianglePathColoredFilled,
                  ),
                )
              ),
              Visibility(
                visible: !isDataAvailible && isError,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      _determineLocation();
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 80,
                          color: Colors.white,
                        ),
                        Text(
                          "Reload",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
