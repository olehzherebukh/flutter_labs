import 'package:weather_app/blocs/weather_bloc.dart';
import 'package:weather_app/models/weather_response.dart';
import 'package:weather_app/networking/api_response.dart';
import 'package:weather_app/view/address_search.dart';
import 'package:weather_app/models/place_service.dart';
import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherBloc _bloc;
  List<String> cities = new List<String>();


  @override
  void initState() {
    super.initState();
    _bloc = WeatherBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Weather',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {return _bloc.refreshWeathers();},
        child: StreamBuilder<ApiResponse<List<Weather>>>(
          stream: _bloc.weatherListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  final newList = snapshot.data.data;
                  return WeatherList(weatherList: newList);
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () => setState(() {
                      _bloc.clearWeather();
                      _bloc.updateWeathers();
                    })
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Suggestion result = await showSearch(
            context: context,
            delegate: AddressSearch(),
          );
          if (result != null) {
            setState(() {
              _bloc.addPlace(result.name);
              _bloc.fetchWeatherList();
              _bloc.clearWeather();
            });
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class WeatherList extends StatelessWidget {
  final List<Weather> weatherList;

  const WeatherList({Key key, this.weatherList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: weatherList.length, // the length
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Row(
                        children: <Widget>[
                          Expanded(child: Text('${weatherList[index].cityName.toString() ?? ""}')),
                          Expanded(child: Text('${weatherList[index].maxTempFirstDay.toString() + "°C" ?? ""}')),
                          Expanded(child: Text('${weatherList[index].maxTempSecondDay.toString() + "°C" ?? ""}')),
                          Expanded(child: Text('${weatherList[index].maxTempThirdDay.toString() + "°C" ?? ""}')),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Oops, something wen wrong!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.redAccent,
            child: Text(
              'Retry',
              style: TextStyle(
                  ),
            ),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}
