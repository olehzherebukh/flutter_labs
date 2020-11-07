import 'package:weather_app/networking/api_base_helper.dart';
import 'package:weather_app/models/weather_response.dart';
import 'package:weather_app/apiKey.dart';

class WeatherRepository {
  final String _apiKey = apiKey;

  ApiBaseHelper _helper = ApiBaseHelper();

  List<Weather> weatherList = new List<Weather>();

  Future<List<Weather>> fetchWeatherList(String cityName) async {
    final response = await _helper.get(cityName, "$_apiKey");
    weatherList.add(WeatherResponse.fromJson(response).weather);
    return weatherList;
  }
}