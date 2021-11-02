import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawa/screens/search.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:hawa/components/customStore.dart';
import 'package:hawa/components/flashMessage.dart' as flash_message;
import 'package:hawa/components/locationManager.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
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
  Future<void> _getData() async{
    setState(() {
      isDataAvailible = false;
      isError = false;
      try{
        flash_message.currentSnackBar.dismiss();
      } catch(e) {}
    });
    Map _locationData = await determineLocation(context, _prefs, location);
    if (!_locationData['status']) {
      setState(() {
        this.isError = true;
      });
      return null;
    }

    setState(() {
      weatherData["cityName"] = _locationData['name'];
      weatherData["countryName"] = _locationData['sys']["country"];
      weatherData["cityTemprature"] = _locationData['main']['temp'].round().toString();  
      weatherData["description"] = _locationData["weather"][0]["description"];
      weatherData["humidity"] = _locationData["main"]["humidity"].toString();
      weatherData["tempMin"] = _locationData['main']['temp_min'].round().toString();
      weatherData["tempMax"] = _locationData['main']['temp_max'].round().toString();
      isDataAvailible = true;
      isError = false;
    });

  } 



  @override
  void initState() {
    _getData();
    super.initState();
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
