import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hawa/components/flashMessage.dart';
class PreferencesManager {

  Future<SharedPreferences> prefs;
  SharedPreferences _prefsObj;
  BuildContext context;
  FlashMessageManager flashController;
  
  PreferencesManager({this.context, this.flashController}) {
    this.prefs = SharedPreferences.getInstance();
    setupObj();
  }

  Future<void> setupObj() async {
    this._prefsObj = await this.prefs;
  }

  
  // Search History data Caching 
  Future<void> setCachedHistoryData(data) async {
    List<String> historyData = await this.getCachedHistoryData();
    if (historyData == null) {
      this._prefsObj.setStringList("searchHistory", []);
    }

    if (historyData.contains(data['query'])) {
      historyData.remove(data['query']);
    }
    historyData.insert(0, data['query']);
    this._prefsObj.setStringList("searchHistory", historyData);
  }

  Future<List<String>> getCachedHistoryData() async {
    return  this._prefsObj.getStringList('searchHistory') ?? [];
  }

  Future<bool> isHistoryCachedDataAbailible() async {
    if (this._prefsObj.getDouble('lat') == null || this._prefsObj.getDouble('lon') == null){
      return false;
    }
    return true;
  }
  Future<void> clearCachedHistoryData() async {
    this._prefsObj.remove('searchHistory');
    flashController.showBasicsFlash(
      context: this.context,
      duration: Duration(seconds: 2),
      content: "Search History Cleared!", 
      icon: Icon(
        Icons.check,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  // Location Data Caching
  Future<void> setLocationCachedData(data) async {
    this._prefsObj.setDouble('lat', data['lat']);
    this._prefsObj.setDouble('lon', data['lon']);
  }
  Future<Map> getLocationCachedData() async {
    return {
      "lat": this._prefsObj.getDouble('lat'),
      "lon": this._prefsObj.getDouble('lon')
    };
  }
  Future<bool> isLocationCachedDataAvailible() async {
    if (this._prefsObj.getDouble('lat') == null || this._prefsObj.getDouble('lon') == null){
      return false;
    }
    return true;
  }
  Future<void> clearLocationCachedData() async {
    // await this._prefsObj.clear();
    this._prefsObj.remove('lat');
    this._prefsObj.remove('lon');
    flashController.showBasicsFlash(
      context: this.context,
      duration: Duration(seconds: 2),
      content: "Location Cache Cleared", 
      icon: Icon(
        Icons.check,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
