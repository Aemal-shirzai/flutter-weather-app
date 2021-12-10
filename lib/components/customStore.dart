import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {

  Future<SharedPreferences> prefs;
  SharedPreferences _prefsObj;
  
  
  PreferencesManager() {
    this.prefs = SharedPreferences.getInstance();
    setupObj();
  }

  Future<void> setupObj() async {
    this._prefsObj = await this.prefs;
  }

  Future<void> setPrefsData(data) async {
    this._prefsObj.setDouble('lat', data['lat']);
    this._prefsObj.setDouble('lon', data['lon']);
  }
  Future<Map> getPrefsData() async {
    return {
      "lat": this._prefsObj.getDouble('lat'),
      "lon": this._prefsObj.getDouble('lon')
    };
  }
  Future<bool> isPrefsDataAvailible() async {
    if (this._prefsObj.getDouble('lat') == null || this._prefsObj.getDouble('lon') == null){
      return false;
    }
    return true;
  }
  Future<void> clearPref() async {
    await this._prefsObj.clear();
  }
}
