class WeatherResponse {
  Weather weather;
  String cityName;

  WeatherResponse({this.weather});

  WeatherResponse.fromJson(Map<String, dynamic> json) {
    if (json['forecast'] != null) {
      var cityName = json['location']['name'];
      Weather newWeather = new Weather.fromJson(json, cityName);
      weather = newWeather;
    }
  }
}

class Weather {
  double maxTempFirstDay;
  double maxTempSecondDay;
  double maxTempThirdDay;
  String cityName;

  Weather(
      {this.maxTempFirstDay, this.maxTempSecondDay, this.maxTempThirdDay, this.cityName});

  Weather.fromJson(Map<String, dynamic> json, String city) {
      cityName = city;
      maxTempFirstDay = json['forecast']['forecastday'][0]['day']['avgtemp_c'];
      maxTempSecondDay = json['forecast']['forecastday'][1]['day']['avgtemp_c'];
      maxTempThirdDay = json['forecast']['forecastday'][2]['day']['avgtemp_c'];
  }
}

