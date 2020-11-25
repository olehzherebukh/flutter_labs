import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/networking/api_response.dart';
import 'package:weather_app/repository/weather_repository.dart';
import 'package:weather_app/models/weather_response.dart';
import 'package:weather_app/models/place_service.dart';
import 'package:weather_app/view/weather_list.dart';

class WeatherBloc {
  WeatherRepository _weatherRepository;

  List<String> cities = [];

  void addPlace(String name) {
    if (cities.contains(name)) {

    } else {
      cities.add(name);
    }
  }

  PlaceApiProvider placeApiProvider = new PlaceApiProvider();


  StreamController _weatherListController;

  StreamSink<ApiResponse<List<Weather>>> get weatherListSink =>
      _weatherListController.sink;

  Stream<ApiResponse<List<Weather>>> get weatherListStream =>
      _weatherListController.stream;

  WeatherBloc() {
    _weatherListController = StreamController<ApiResponse<List<Weather>>>();
    _weatherRepository = WeatherRepository();
    fetchWeatherList();
  }

  List<Weather> weather;

  fetchWeatherList() async {
    weatherListSink.add(ApiResponse.loading('Fetching weather'));
    try {
      if (cities.length == 0) {
        weatherListSink.add(null);
      } else {
        for (int i = 0; i < cities.length; i ++){
          weather = await _weatherRepository.fetchWeatherList(cities[i]);
        }
        weatherListSink.add(ApiResponse.completed(weather));
      }
    } catch (e) {
      weatherListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  clearWeather() {
    if (weather != null) {
      weather.clear();
    }
  }

  refreshWeathers() {
    clearWeather();
    fetchWeatherList();
  }

  updateWeathers() {
    cities.remove(cities.last);
    fetchWeatherList();
  }

  dispose() {
    _weatherListController?.close();
  }
}