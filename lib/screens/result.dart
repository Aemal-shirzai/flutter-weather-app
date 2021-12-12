import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:hawa/components/constants.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:hawa/components/customStore.dart';
import 'package:hawa/components/flashMessage.dart';
import 'package:hawa/components/locationManager.dart';
import 'package:hawa/models/weatherModel.dart';
import 'package:hawa/components/connectivityManager.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  WeatherBase weatherBase = WeatherBase();
  ConnectivityManager connectivityManager;
  PreferencesManager preferencesManager;
  FlashMessageManager flashMessageManager = FlashMessageManager();
  LocationManager locationManager;
  bool isDataAvailible = false;
  bool isError = false;
  Map weatherData = {
    "countryName": "",
    "cityName" : '',
    "cityTemprature": '',
    "description": '',
    "humidity": '',
    "tempMin": '',
    "tempMax": '',
  };


  Future<void> getData({cityName: false}) async{
    
    this.toggleIsError(isError: false, dismissMessage: true);
    if (connectivityManager.hasValidConnection() == false) {return null;}
    Map _locationData = {};
    if (cityName != false){
      _locationData = await locationManager.determineLocation(searchBy: searchType.byCity, cityName: cityName);
    } else {
      _locationData = await locationManager.determineLocation();
    }
    if (!_locationData['status']) {
      this.toggleIsError();
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
      toggleIsError(isError: false, isDataAvailible: true);
    });
  }

  void toggleIsError({isError: true, isDataAvailible: false, dismissMessage: false}){
    setState(() {
      this.isError = isError;
      this.isDataAvailible = isDataAvailible;
      if (dismissMessage) {flashMessageManager.dismissFlashMessage();}
    });
  }
  Future<void> setupConfigurations() async {
    preferencesManager = PreferencesManager(context: context, flashController: this.flashMessageManager);
    locationManager = LocationManager(context: context, flashController: this.flashMessageManager, preferencesManager: this.preferencesManager);
    connectivityManager = ConnectivityManager(context: context, onConnectionRestore: getData, onConnectionLost: toggleIsError, flashController: flashMessageManager);
    await connectivityManager.initConnectivity(subscribeConnection: true);
    getData();
  }
  @override
  void initState() {
    setupConfigurations();
    super.initState();
  }
  @override
  void dispose() {
    connectivityManager.unsubscribeConnectivity();
    super.dispose();
  }

  SolidController _controller = SolidController();
  FloatingSearchBarController _controller_search = FloatingSearchBarController();
  List history = [
    "Kabul", "London", "Welcome"
  ];
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: Container(
          width: 200,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                // currentAccountPicture: CircleAvatar(
                //   backgroundImage: NetworkImage(
                //       'https://images.unsplash.com/photo-1485290334039-a3c69043e517?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYyOTU3NDE0MQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=300'),
                // ),
                accountEmail: Text('weatherapp@abc.com'),
                accountName: Text(
                  'Weather App',
                  style: TextStyle(fontSize: 24.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                ),
                margin: EdgeInsets.only(bottom:4),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.locationArrow),
                title: const Text(
                  'My Location',
                  style: TextStyle(fontSize: 20.0),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await getData();
                },
              ),
              const Divider(
                height: 10,
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.trashRestoreAlt),
                title: const Text(
                  'Clear Cache',
                  style: TextStyle(fontSize: 20.0),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await preferencesManager.clearPref();
                },
              ),
            ],
          ),
          
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/04.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
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
                      child: BouncingWidget(
                        duration: Duration(milliseconds: 200),
                        scaleFactor: 1.5,
                        onPressed: () {
                          getData();
                        },
                        child: Container(
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            // visible: isDataAvailible && !isError,
            visible: true,
            child: FloatingSearchBar(
              hint: 'Search City Name...',
              controller: _controller_search,
              clearQueryOnClose: false,
              scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
              transitionDuration: const Duration(milliseconds: 800),
              transitionCurve: Curves.easeInOut,
              physics: const BouncingScrollPhysics(),
              axisAlignment: isPortrait ? 0.0 : -1.0,
              openAxisAlignment: 0.0,
              width: isPortrait ? 600 : 500,
              debounceDelay: const Duration(milliseconds: 500),
              onQueryChanged: (query) {
                print("?????????????????????????????????????????????????????? $query");
                // Call your model, bloc, controller here.
              },
              onSubmitted: (query) async {
                _controller_search.close();
                await getData(cityName: query);
              },
              // Specify a custom transition to be used for
              // animating between opened and closed stated.
              transition: CircularFloatingSearchBarTransition(),
              actions: [
                FloatingSearchBarAction(
                  showIfOpened: false,
                  child: CircularButton(
                    icon: const Icon(Icons.place),
                    onPressed: () {},
                  ),
                ),
                FloatingSearchBarAction.searchToClear(
                  showIfClosed: false,
                ),
              ],
              builder: (context, transition) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Material(
                    color: Colors.white,
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: history.map((city) {
                          return GestureDetector(
                            onTap: () => _controller_search.query = city,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(
                                color: Colors.grey[350]
                              ),),
                              ),
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              height: 50, 
                              child: Text(
                                city,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // bottomSheet: Visibility(
      //   visible: isDataAvailible && !isError,
      //   child: SolidBottomSheet(
      //     controller: _controller,
      //     draggableBody: true,
      //     headerBar: Container(
      //       decoration:  BoxDecoration(
      //         color: Color.fromRGBO(35, 39, 66, 0.8),
      //       ),
      //       height: 45,
      //       child: Center(
      //         child: Column(
      //           children: [
      //             Icon(Icons.keyboard_arrow_up, color: Colors.white,),
      //             Text("Swip Up For More..", style: TextStyle(color: Colors.white),),
      //           ],
      //         ),
      //       ),
      //     ),
      //     body: Container(
      //       color: Colors.white,
      //       height: 30,
      //       child: Center(
      //         child: Text(
      //           "Hello! I'm a bottom sheet :D",
      //           style: Theme.of(context).textTheme.headline1,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
