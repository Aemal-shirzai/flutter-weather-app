import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawa/screens/search.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:hawa/components/customStore.dart';
import 'package:hawa/components/flashMessage.dart' as flash_message;
import 'package:hawa/components/locationManager.dart';
import 'package:connectivity/connectivity.dart';
import 'package:hawa/models/weatherModel.dart';


class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  WeatherBase weatherBase = WeatherBase();
  String _connectionStatus = 'Unknown';
  String _prevConnectionStatus = 'Unknown';
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Location location = Location();
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

  Future<bool> _updateConnectionStatus(ConnectivityResult result) async {
    var connectivityResult = result;
    setState(() {
      this._prevConnectionStatus =  this._connectionStatus;
      this._connectionStatus = connectivityResult.toString();
      try{
        flash_message.currentSnackBar.dismiss();
      } catch(e) {}
    });
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      if (this._prevConnectionStatus == 'ConnectivityResult.none') {
        _getData ();
        flash_message.showBasicsFlash(
          context: context,
          duration: Duration(seconds: 2),
          content: "Connection Restored Seccessfully.", 
          icon: Icon(
            Icons.check,
            size: 40,
            color: Colors.white,
          ),
        );
      }
    } else {
      setState(() {
        this.isError = true;
        this.isDataAvailible = false;
      });
      flash_message.showBasicsFlash(
        context: context,
        content: "OOPS!. You Are Not Connected to Internet.", 
        icon: Icon(
          Icons.signal_cellular_connected_no_internet_4_bar,
          size: 40,
          color: Colors.white,
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return Future.value(false);
    }

    if (!mounted) {
      return Future.value(false);
    }

    return _updateConnectionStatus(result);
  }


  Future<void> _getData() async{

    setState(() {
      isDataAvailible = false;
      isError = false;
      try{
        flash_message.currentSnackBar.dismiss();
      } catch(e) {}
    });
    
    if (this._connectionStatus == 'Unknown' || this._connectionStatus == 'ConnectivityResult.none') {
      setState(() {
        this.isError = true;
        initConnectivity();
      });
      return null;
    }
    
    Map _locationData = await determineLocation(context, _prefs, location);
    if (!_locationData['status']) {
      setState(() {
        this.isError = true;
      });
      return null;
    }

    setState(() {
      weatherBase.setValues(
        cityName: _locationData['name'],
        countryName: _locationData['sys']["country"],
        cityTemprature: _locationData['main']['temp'].round(),
        description: _locationData["weather"][0]["description"],
        humidity: _locationData["main"]["humidity"],
        tempMin: _locationData['main']['temp_min'].round(),
        tempMax: _locationData['main']['temp_max'].round()
      );
      weatherData =  weatherBase.getValues();
      isDataAvailible = true;
      isError = false;
    });

  } 

  Future<void> setupConfigurations() async {
      await initConnectivity();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
      _getData();
  }

  @override
  void initState() {
   setupConfigurations();
    super.initState();
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/03.jpg"),
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
                                          text: weatherData["cityTemprature"].toString(),
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
                                    await _getData();
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
                                    await clearPref(_prefs); 
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
                                          weatherData["humidity"].toString() + "%",
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
                                          weatherData["tempMin"].toString() + " \u00B0",
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
                                          weatherData["tempMax"].toString() + " \u00B0",
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
                      _getData();
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
