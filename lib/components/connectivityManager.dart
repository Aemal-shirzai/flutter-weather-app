import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hawa/components/flashMessage.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityManager {
  
  final Connectivity connectivity = Connectivity();
  BuildContext context;
  String connectionStatus = 'Unknown';
  String prevConnectionStatus = 'Unknown';
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Function onConnectionRestore;
  Function onConnectionLost;
  FlashMessageManager flashController;

  ConnectivityManager({this.context, this.onConnectionRestore, this.onConnectionLost, this.flashController});

  Future<bool> updateConnectionStatus(ConnectivityResult result) async {
    var connectivityResult = result;
    this.prevConnectionStatus =  this.connectionStatus;
    this.connectionStatus = connectivityResult.toString();
    flashController.dismissFlashMessage();
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      if (this.prevConnectionStatus == 'ConnectivityResult.none') {
        onConnectionRestore();
        flashController.showBasicsFlash(
          context: this.context,
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
      onConnectionLost();
      flashController.showBasicsFlash(
        context: this.context,
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

  Future<bool> initConnectivity({bool subscribeConnection: false}) async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return Future.value(false);
    }
    Future<bool> finalResult =  updateConnectionStatus(result);
    if (subscribeConnection == true) {
      subscribeConnectivity();
    }
    return finalResult;
  }

  void subscribeConnectivity() {
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  }
  void unsubscribeConnectivity() {
    _connectivitySubscription.cancel();
  }

  bool hasValidConnection() {
    if (this.connectionStatus == 'Unknown' || this.connectionStatus == 'ConnectivityResult.none') {
      this.onConnectionLost();
      this.initConnectivity();
      return false;
      }
    return true;
  }

}