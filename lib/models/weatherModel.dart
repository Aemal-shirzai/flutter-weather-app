class WeatherBase {

  String _cityName;
  String _countryName;
  int _cityTemprature;
  String _description;
  int _humidity;
  int _tempMin;
  int _tempMax;


  void setValues({cityName, countryName, cityTemprature, description, humidity, tempMin, tempMax}) {
    this._cityName = cityName;
    this._countryName = countryName;
    this._cityTemprature = cityTemprature;
    this._description = description;
    this._humidity = humidity;
    this._tempMin = tempMin;
    this._tempMax = tempMax;
  }

  Map getValues() {
    return {
      "cityName": this._cityName,
      "countryName": this._countryName,
      "cityTemprature": this._cityTemprature,
      "description": this._description,
      "humidity": this._humidity,
      "tempMin": this._tempMin,
      "tempMax": this._tempMax,
    };
  }


}